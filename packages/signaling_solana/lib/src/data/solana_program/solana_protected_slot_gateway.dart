import 'dart:convert';
import 'dart:typed_data';

import 'package:signaling/signaling.dart';
import 'package:signaling_solana/src/data/solana_program/connect_slot_mapper.dart';
import 'package:signaling_solana/src/data/solana_program/solana_rpc_read_error_classifier.dart';
import 'package:signaling_solana/src/data/solana_program/sols_stream_account_decoder.dart';
import 'package:signaling_solana/src/data/solana_program/sols_stream_account_integrity_exception.dart';
import 'package:signaling_solana/src/data/solana_program/sols_stream_instruction_factory.dart';
import 'package:signaling_solana/src/data/solana_program/sols_stream_owned_account_loader.dart';
import 'package:signaling_solana/src/generated/sols_stream_solana.dart';
import 'package:solana/dto.dart' show Encoding, ProgramDataFilter;
import 'package:solana/solana.dart';
import 'package:solana_wallet/solana_signer.dart';

/// Solana implementation of [ProtectedSlotGateway].
///
/// Signs via the wallet's [SolanaSigner]; reads chain accounts via its own
/// injected [RpcClient]. Discovery mirrors the web client `_tryConnectViaSlot`:
/// resolve the host's live room from its User PDA, then `getProgramAccounts`
/// filtered by the ConnectSlot discriminator and the room.
final class SolanaProtectedSlotGateway implements ProtectedSlotGateway {
  final SolanaSigner _signer;
  final RpcClient _reader;
  final SolsStreamInstructionFactory _instructions;
  final SolsStreamAccountDecoder _accounts;
  final SolsStreamOwnedAccountLoader _accountLoader;
  final SignalingDiagnostics _diagnostics;

  /// Minimum remaining TTL (seconds) for a slot to be worth claiming — a slot
  /// about to expire would lapse mid-handshake. Matches the web client's 30s.
  static const int _minTtlSeconds = 30;

  SolanaProtectedSlotGateway(
    this._signer,
    this._reader, {
    SolsStreamInstructionFactory? instructionFactory,
    SolsStreamAccountDecoder accountDecoder = const SolsStreamAccountDecoder(),
    this._diagnostics = noOpSignalingDiagnostics,
  }) : _instructions = instructionFactory ?? SolsStreamInstructionFactory(),
       _accounts = accountDecoder,
       _accountLoader = SolsStreamOwnedAccountLoader(_reader);

  @override
  Future<ProtectedSlotDiscoveryResult> discoverOpenSlot(
    String hostAddress,
  ) async {
    final host = _parseCanonicalAddress(hostAddress);
    final room = await _resolveLiveRoom(host);
    if (room == null) {
      return const ProtectedSlotUnavailable(
        ProtectedSlotUnavailableReason.noJoinableSlot,
      );
    }

    final accounts = await classifySolanaRpcRead(
      () => _reader.getProgramAccounts(
        SolsStreamProgram.programAddress.toBase58(),
        commitment: Commitment.confirmed,
        encoding: Encoding.base64,
        filters: [
          ProgramDataFilter.memcmp(
            offset: 0,
            bytes: SolsStreamConnectSlotAccount.discriminator,
          ),
          ProgramDataFilter.memcmp(offset: 8, bytes: room.bytes),
        ],
      ),
    );

    final now = BigInt.from(DateTime.now().millisecondsSinceEpoch ~/ 1000);
    var claimedByAnotherViewer = false;
    for (final acc in accounts) {
      final ConnectSlotData slot;
      try {
        final data = _accountLoader.dataFor(
          acc.account,
          accountName: SolsStreamConnectSlotAccount.name,
        );
        final account = _accounts.decodeScannedConnectSlot(data);
        if (account == null) continue;
        slot = ConnectSlotMapper.toDomain(account);
        if (!_sameBytes(slot.room, room.bytes) || !_sameBytes(slot.host, host.bytes)) {
          throw const SolsStreamAccountIntegrityException(
            accountName: SolsStreamConnectSlotAccount.name,
            message: 'slot does not match its discovered room and host',
          );
        }
      } on SolsStreamBorshException catch (error) {
        _diagnostics(
          'slot.discovery.skipped type=${error.runtimeType}',
        );
        continue;
      } on SolsStreamAccountIntegrityException catch (error) {
        _diagnostics(
          'slot.discovery.skipped type=${error.runtimeType}',
        );
        continue;
      }

      final access = classifyPeerSlotAccess(
        slot: slot,
        viewerPublicKey: _signer.publicKey.bytes,
        nowSeconds: now,
        minimumTtlSeconds: _minTtlSeconds,
      );
      if (access == PeerSlotAccess.claimedByAnotherViewer) {
        claimedByAnotherViewer = true;
        continue;
      }
      if (access != PeerSlotAccess.joinable) continue;

      return DiscoveredSlot(slotPda: acc.pubkey, roomPda: room.toBase58(), slot: slot);
    }

    return ProtectedSlotUnavailable(
      claimedByAnotherViewer
          ? ProtectedSlotUnavailableReason.claimedByAnotherViewer
          : ProtectedSlotUnavailableReason.noJoinableSlot,
    );
  }

  @override
  Future<String> buildSignedProof(String slotPda) {
    final ix = _instructions.proof(
      prover: _signer.publicKey,
      slotPda: slotPda,
    );

    return _signer.signForProof([ix]);
  }

  @override
  Future<void> writeOfferWithProtectedKey({
    required String slotPda,
    required String protectedKey,
    required Uint8List payload,
  }) async {
    final ixs = await _instructions.writeOfferWithProtectedKey(
      host: _signer.publicKey,
      slotPda: Ed25519HDPublicKey.fromBase58(slotPda),
      protectedKey: Uint8List.fromList(utf8.encode(protectedKey)),
      encryptedPayload: payload,
    );
    for (final ix in ixs) {
      await _signer.signAndSend([ix]);
    }
  }

  @override
  Future<void> writeAnswerWithProtectedKey({
    required String slotPda,
    required String protectedKey,
    required Uint8List payload,
  }) async {
    final ixs = await _instructions.writeAnswerWithProtectedKey(
      viewer: _signer.publicKey,
      slotPda: Ed25519HDPublicKey.fromBase58(slotPda),
      protectedKey: Uint8List.fromList(utf8.encode(protectedKey)),
      encryptedPayload: payload,
    );
    for (final ix in ixs) {
      await _signer.signAndSend([ix]);
    }
  }

  /// Reads [host]'s User PDA and returns its `room` pubkey, or `null` when the
  /// account is absent, the host is not a live Host, or the room is unset
  /// (all-zero) — i.e. nothing to join.
  Future<Ed25519HDPublicKey?> _resolveLiveRoom(Ed25519HDPublicKey host) async {
    final userPda = await _instructions.deriveUserPda(host);
    final data = await _accountLoader.load(
      userPda.toBase58(),
      accountName: SolsStreamUserAccount.name,
    );
    if (data == null) return null;

    final user = _accounts.decodeUserProjection(data);
    if (!user.isHost) return null;
    final roomBytes = user.room.bytes;
    if (roomBytes.every((b) => b == 0)) return null;

    return Ed25519HDPublicKey(roomBytes);
  }

  Ed25519HDPublicKey _parseCanonicalAddress(String value) {
    try {
      final key = Ed25519HDPublicKey.fromBase58(value);
      if (key.bytes.length != 32 || key.toBase58() != value) {
        throw const FormatException('Non-canonical Solana address.');
      }

      return key;
    } on Exception {
      throw const FormatException('Invalid Solana host address.');
    }
  }

  bool _sameBytes(List<int> first, List<int> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }

    return true;
  }
}
