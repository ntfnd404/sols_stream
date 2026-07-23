import 'package:signaling/signaling.dart';
import 'package:signaling_solana/src/data/solana_program/connect_slot_mapper.dart';
import 'package:signaling_solana/src/data/solana_program/program_config_mapper.dart';
import 'package:signaling_solana/src/data/solana_program/sols_stream_account_decoder.dart';
import 'package:signaling_solana/src/data/solana_program/sols_stream_instruction_factory.dart';
import 'package:signaling_solana/src/data/solana_program/sols_stream_owned_account_loader.dart';
import 'package:signaling_solana/src/data/solana_program/user_account.dart';
import 'package:signaling_solana/src/generated/sols_stream_solana.dart';
import 'package:solana/encoder.dart' show Instruction;
import 'package:solana/solana.dart';
import 'package:solana_wallet/solana_signer.dart';

// User account Borsh layout (after 8-byte discriminator):
// [32] authority | [4+n] nickname | [1] role | [32] room | [32] connected_to
// [8] last_heartbeat | [8] expires_at | [8] turn_expires_at | [4] stream_count

/// Solana implementation of [SignalingChainGateway].
///
/// Signs via the wallet's [SolanaSigner] port; reads chain accounts via its own
/// injected [RpcClient] — it does not borrow the wallet's transport.
final class SolanaSignalingChainGateway implements SignalingChainGateway {
  final SignalingDiagnostics diagnostics;
  final SolanaSigner _signer;
  final SolanaSigner _cleanupSigner;
  final SolsStreamInstructionFactory _instructions;
  final SolsStreamAccountDecoder _accounts;
  final SolsStreamOwnedAccountLoader _accountLoader;
  Ed25519HDPublicKey? _cachedConfigPda;

  SolanaSignalingChainGateway(
    this._signer,
    RpcClient reader, {
    required this._cleanupSigner,
    SolsStreamInstructionFactory? instructionFactory,
    SolsStreamAccountDecoder accountDecoder = const SolsStreamAccountDecoder(),
    this.diagnostics = noOpSignalingDiagnostics,
  }) : _instructions = instructionFactory ?? SolsStreamInstructionFactory(),
       _accounts = accountDecoder,
       _accountLoader = SolsStreamOwnedAccountLoader(reader);

  @override
  Future<SlotAddresses> openSignalingSlot({
    required int slotNonce,
    RoomCreationParams room = const RoomCreationParams.p2pFree(),
    int expiresInSeconds = 120,
  }) async {
    diagnostics('chain.slot_open.started');
    final host = _signer.publicKey;

    // Mirrors JS startAdvertising:
    // 1. Ensure user is Idle (create_user if missing, cleanup stale role).
    // 2. Re-read stream_count AFTER cleanup (JS re-fetches userData after
    //    endRoom/leaveRoom so nonce is always fresh).
    await _prepareHostUser(host);
    await _ensureTurnEntitlement(host);
    final roomNonce = await readStreamCount();
    diagnostics('chain.room_nonce.read');

    final roomPda = await _instructions.deriveRoomPda(host, roomNonce);
    final slotPdaKey = await _instructions.deriveSlotPda(roomPda, slotNonce);

    // create_room and open_slot are sent in separate confirmed transactions,
    // matching the reference web client's sequencing. Bundling them in one tx
    // trips the program's create_room authorization check (same as bundling
    // create_user with create_room).
    await _send(
      'chain.room_create',
      [
        await _instructions.createRoom(
          host: host,
          roomNonce: roomNonce,
          params: room,
        ),
      ],
    );
    await _send(
      'chain.slot_create',
      [
        await _instructions.openConnectSlot(
          host: host,
          roomPda: roomPda,
          slotNonce: slotNonce,
          expiresInSeconds: expiresInSeconds,
        ),
      ],
    );
    diagnostics('chain.slot_open.completed');

    return SlotAddresses(
      roomPda: roomPda.toBase58(),
      slotPda: slotPdaKey.toBase58(),
      roomNonce: roomNonce,
    );
  }

  @override
  Future<void> endRoom(String roomPda) async {
    await _cleanupSigner.signAndSend([
      await _instructions.endRoom(
        host: _signer.publicKey,
        roomPda: Ed25519HDPublicKey.fromBase58(roomPda),
      ),
    ]);
  }

  @override
  Future<void> closeRoom(String roomPda) async {
    await _cleanupSigner.signAndSend([
      await _instructions.closeRoom(
        host: _signer.publicKey,
        roomPda: Ed25519HDPublicKey.fromBase58(roomPda),
      ),
    ]);
  }

  @override
  Future<void> claimSlot({required String slotPda, required String roomPda}) async {
    await _signer.signAndSend([
      await _instructions.claimConnectSlot(
        viewer: _signer.publicKey,
        slotPda: Ed25519HDPublicKey.fromBase58(slotPda),
        roomPda: Ed25519HDPublicKey.fromBase58(roomPda),
      ),
    ]);
  }

  @override
  Future<ConnectSlotData?> fetchSlot(String slotPda) async {
    final bytes = await _accountLoader.load(
      slotPda,
      accountName: SolsStreamConnectSlotAccount.name,
    );
    if (bytes == null) return null;

    final account = _accounts.decodeConnectSlot(bytes);

    return ConnectSlotMapper.toDomain(account);
  }

  @override
  Future<ProgramConfig?> fetchConfig() async {
    final configPda = await _instructions.deriveConfigPda();
    final bytes = await _accountLoader.load(
      configPda.toBase58(),
      accountName: SolsStreamProgramConfigAccount.name,
    );
    if (bytes == null) return null;

    final account = _accounts.decodeProgramConfig(bytes);

    return ProgramConfigMapper.toDomain(account);
  }

  @override
  Future<void> confirmConnection(String slotPda) async {
    await _signer.signAndSend([
      await _instructions.confirmConnection(
        signer: _signer.publicKey,
        slotPda: Ed25519HDPublicKey.fromBase58(slotPda),
      ),
    ]);
  }

  @override
  Future<void> sendHeartbeat() async {
    _cachedConfigPda ??= await _instructions.deriveConfigPda();
    final configPda = _cachedConfigPda!;
    final ix = await _instructions.heartbeat(
      signer: _signer.publicKey,
      configPda: configPda,
    );

    await _signer.signAndSend([ix]);
  }

  @override
  Future<int> readStreamCount() async {
    final user = await _fetchUser(_signer.publicKey);

    return user?.streamCount ?? 0;
  }

  Future<void> _ensureTurnEntitlement(Ed25519HDPublicKey host) async {
    final user = await _fetchUser(host);
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    if (user != null && user.hasActiveTurnEntitlement(nowSeconds: nowSeconds)) {
      diagnostics('chain.turn_entitlement.active');

      return;
    }
    diagnostics('chain.turn_entitlement.purchase_required');

    final config = await fetchConfig();
    if (config == null) {
      throw StateError('ProgramConfig unavailable; cannot purchase TURN entitlement before create_room.');
    }

    _cachedConfigPda ??= await _instructions.deriveConfigPda();
    final ix = await _instructions.purchaseTurn(
      buyer: host,
      serviceWallet: Ed25519HDPublicKey(config.serviceWallet),
      configPda: _cachedConfigPda!,
    );
    await _send('chain.turn_entitlement.purchase', [ix]);
  }

  /// Ensures the host User PDA exists and is in `Idle` role before `create_room`.
  ///
  /// Mirrors JS `startAdvertising` (host.js:1006–1039):
  /// 1. PDA missing → `create_user`.
  /// 2. role = Host (1) → `end_room`, fallback `close_room` (best-effort).
  /// 3. role = Viewer (2) or Relay (3) → `leave_room` (best-effort).
  /// 4. Re-reads user state after cleanup; throws [StateError] if still not Idle
  ///    (gives a clear message instead of a cryptic 6002 from `create_room`).
  Future<void> _prepareHostUser(Ed25519HDPublicKey host) async {
    final user = await _fetchUser(host);

    if (user == null) {
      diagnostics('chain.user.missing');
      await _send(
        'chain.user_create',
        [await _instructions.createUser(authority: host)],
      );

      return;
    }

    if (user.isIdle) {
      diagnostics('chain.user.idle');

      return;
    }
    diagnostics('chain.user.cleanup_required role=${user.role}');

    final roomPda = Ed25519HDPublicKey(user.room.bytes);

    if (user.isHost) {
      // Host: end_room resets role to Idle; close_room reclaims rent.
      try {
        await _cleanupSigner.signAndSend([
          await _instructions.endRoom(host: host, roomPda: roomPda),
        ]);
      } catch (_) {
        // Room may already be ended or garbage-collected.
        try {
          await _cleanupSigner.signAndSend([
            await _instructions.closeRoom(host: host, roomPda: roomPda),
          ]);
        } catch (_) {}
      }
      try {
        await _cleanupSigner.signAndSend([
          await _instructions.closeRoom(host: host, roomPda: roomPda),
        ]);
      } catch (_) {}
    } else {
      // Viewer (2) or Relay (3): leave_room resets role to Idle.
      try {
        await _cleanupSigner.signAndSend([
          await _instructions.leaveRoom(viewer: host, roomPda: roomPda),
        ]);
      } catch (_) {}
    }

    // Re-read to verify the cleanup succeeded. If still not Idle, throw a clear
    // error rather than letting create_room fail with the cryptic 6002.
    final fresh = await _fetchUser(host);
    if (fresh != null && !fresh.isIdle) {
      throw StateError(
        'Previous stream session is still active on-chain (role=${fresh.role}). '
        'Wait ~2 min for it to expire and try again.',
      );
    }
  }

  Future<UserAccount?> _fetchUser(Ed25519HDPublicKey host) async {
    final userPda = await _instructions.deriveUserPda(host);
    final bytes = await _accountLoader.load(
      userPda.toBase58(),
      accountName: SolsStreamUserAccount.name,
    );
    if (bytes == null) return null;

    return _accounts.decodeUserProjection(bytes);
  }

  Future<String> _send(
    String operation,
    List<Instruction> instructions,
  ) async {
    diagnostics('$operation.started');
    try {
      final signature = await _signer.signAndSend(instructions);
      diagnostics('$operation.confirmed');

      return signature;
    } on Object catch (error) {
      diagnostics('$operation.failed type=${error.runtimeType}');
      rethrow;
    }
  }
}
