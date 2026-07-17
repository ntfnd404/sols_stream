import 'dart:convert';
import 'dart:typed_data';

import 'package:signaling/signaling.dart';
import 'package:signaling_solana/src/data/solana_program/signaling_protocol_constants.dart';
import 'package:signaling_solana/src/data/solana_program/sols_stream_wire_adapter.dart';
import 'package:signaling_solana/src/generated/sols_stream_solana.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';

final class SolsStreamInstructionFactory {
  final SolsStreamWireAdapter wireAdapter;

  static final BigInt _maxU64 = (BigInt.one << 64) - BigInt.one;

  final SolsStreamResolutionContext _context;

  SolsStreamInstructionFactory({
    SolsStreamPdaDeriver pdaDeriver = const SolanaPdaDeriver(),
    this.wireAdapter = const SolsStreamWireAdapter(),
  }) : _context = SolsStreamResolutionContext(pdaDeriver: pdaDeriver);

  Future<Ed25519HDPublicKey> deriveUserPda(
    Ed25519HDPublicKey authority,
  ) async {
    final accounts = await SolsStreamCreateUserAccountResolver(_context).resolve(
      args: SolsStreamCreateUserArgs(
        nickname: SignalingProtocolConstants.defaultNickname,
      ),
      overrides: SolsStreamCreateUserAccountOverrides(
        authority: _use(authority),
      ),
    );

    return wireAdapter.toSolanaAddress(accounts.user);
  }

  Future<Ed25519HDPublicKey> deriveRoomPda(
    Ed25519HDPublicKey host,
    int roomNonce,
  ) async {
    final args = _createRoomArgs(
      roomNonce,
      const RoomCreationParams.p2pFree(),
    );
    final accounts = await SolsStreamCreateRoomAccountResolver(_context).resolve(
      args: args,
      overrides: SolsStreamCreateRoomAccountOverrides(host: _use(host)),
    );

    return wireAdapter.toSolanaAddress(accounts.room);
  }

  Future<Ed25519HDPublicKey> deriveSlotPda(
    Ed25519HDPublicKey room,
    int slotNonce,
  ) async {
    final args = SolsStreamOpenConnectSlotArgs(
      slotNonce: _u64(slotNonce, 'slotNonce'),
      depositLamports: BigInt.from(SignalingProtocolConstants.depositLamports),
      expiresInSeconds: BigInt.from(SignalingProtocolConstants.expiresInSec),
    );
    final accounts = await SolsStreamOpenConnectSlotAccountResolver(_context).resolve(
      args: args,
      overrides: SolsStreamOpenConnectSlotAccountOverrides(
        host: _use(Ed25519HDPublicKey(List<int>.filled(32, 0))),
        room: _use(room),
      ),
    );

    return wireAdapter.toSolanaAddress(accounts.slot);
  }

  Future<Ed25519HDPublicKey> deriveConfigPda() async {
    final zero = Ed25519HDPublicKey(List<int>.filled(32, 0));
    final accounts = await SolsStreamHeartbeatAccountResolver(_context).resolve(
      args: const SolsStreamHeartbeatArgs(),
      overrides: SolsStreamHeartbeatAccountOverrides(viewer: _use(zero)),
    );

    return wireAdapter.toSolanaAddress(accounts.config);
  }

  Future<Instruction> createUser({
    required Ed25519HDPublicKey authority,
    String nickname = SignalingProtocolConstants.defaultNickname,
  }) async {
    final args = SolsStreamCreateUserArgs(nickname: nickname);
    final request = await SolsStreamCreateUserAccountResolver(_context).prepare(
      args: args,
      overrides: SolsStreamCreateUserAccountOverrides(
        authority: _use(authority),
      ),
    );

    return _instruction(request.instruction());
  }

  Future<Instruction> createRoom({
    required Ed25519HDPublicKey host,
    required int roomNonce,
    RoomCreationParams params = const RoomCreationParams.p2pFree(),
  }) async {
    final args = _createRoomArgs(roomNonce, params);
    final request = await SolsStreamCreateRoomAccountResolver(_context).prepare(
      args: args,
      overrides: SolsStreamCreateRoomAccountOverrides(host: _use(host)),
    );

    return _instruction(request.instruction());
  }

  Future<Instruction> openConnectSlot({
    required Ed25519HDPublicKey host,
    required Ed25519HDPublicKey roomPda,
    required int slotNonce,
    int expiresInSeconds = SignalingProtocolConstants.expiresInSec,
  }) async {
    final args = SolsStreamOpenConnectSlotArgs(
      slotNonce: _u64(slotNonce, 'slotNonce'),
      depositLamports: BigInt.from(SignalingProtocolConstants.depositLamports),
      expiresInSeconds: _u64(expiresInSeconds, 'expiresInSeconds'),
    );
    final request = await SolsStreamOpenConnectSlotAccountResolver(_context).prepare(
      args: args,
      overrides: SolsStreamOpenConnectSlotAccountOverrides(
        host: _use(host),
        room: _use(roomPda),
      ),
    );

    return _instruction(request.instruction());
  }

  Future<Instruction> claimConnectSlot({
    required Ed25519HDPublicKey viewer,
    required Ed25519HDPublicKey slotPda,
    required Ed25519HDPublicKey roomPda,
  }) async {
    final args = SolsStreamClaimConnectSlotArgs(
      depositLamports: BigInt.from(SignalingProtocolConstants.depositLamports),
    );
    final request = await SolsStreamClaimConnectSlotAccountResolver(_context).prepare(
      args: args,
      overrides: SolsStreamClaimConnectSlotAccountOverrides(
        viewer: _use(viewer),
        slot: _use(slotPda),
        room: _use(roomPda),
      ),
    );

    return _instruction(request.instruction());
  }

  Future<List<Instruction>> writeOffer({
    required Ed25519HDPublicKey host,
    required Ed25519HDPublicKey slotPda,
    required Uint8List encryptedPayload,
  }) => _chunkedWrite(
    signer: host,
    slotPda: slotPda,
    payload: encryptedPayload,
    offer: true,
  );

  Future<List<Instruction>> writeAnswer({
    required Ed25519HDPublicKey viewer,
    required Ed25519HDPublicKey slotPda,
    required Uint8List encryptedPayload,
  }) => _chunkedWrite(
    signer: viewer,
    slotPda: slotPda,
    payload: encryptedPayload,
    offer: false,
  );

  Future<List<Instruction>> writeOfferWithProtectedKey({
    required Ed25519HDPublicKey host,
    required Ed25519HDPublicKey slotPda,
    required Uint8List protectedKey,
    required Uint8List encryptedPayload,
  }) async => [
    await _write(
      signer: host,
      slotPda: slotPda,
      protectedKey: protectedKey,
      data: Uint8List(0),
      finalize: false,
      offer: true,
    ),
    ...await writeOffer(
      host: host,
      slotPda: slotPda,
      encryptedPayload: encryptedPayload,
    ),
  ];

  Future<List<Instruction>> writeAnswerWithProtectedKey({
    required Ed25519HDPublicKey viewer,
    required Ed25519HDPublicKey slotPda,
    required Uint8List protectedKey,
    required Uint8List encryptedPayload,
  }) async => [
    await _write(
      signer: viewer,
      slotPda: slotPda,
      protectedKey: protectedKey,
      data: Uint8List(0),
      finalize: false,
      offer: false,
    ),
    ...await writeAnswer(
      viewer: viewer,
      slotPda: slotPda,
      encryptedPayload: encryptedPayload,
    ),
  ];

  Instruction proof({
    required Ed25519HDPublicKey prover,
    required String slotPda,
  }) => Instruction(
    programId: wireAdapter.toSolanaAddress(SolsStreamProgram.programAddress),
    accounts: [AccountMeta.readonly(pubKey: prover, isSigner: true)],
    data: ByteArray(utf8.encode('proof:$slotPda')),
  );

  Future<Instruction> confirmConnection({
    required Ed25519HDPublicKey signer,
    required Ed25519HDPublicKey slotPda,
  }) async {
    final request = await SolsStreamConfirmConnectionAccountResolver(_context).prepare(
      args: const SolsStreamConfirmConnectionArgs(),
      overrides: SolsStreamConfirmConnectionAccountOverrides(
        signer: _use(signer),
        slot: _use(slotPda),
      ),
    );

    return _instruction(request.instruction());
  }

  Future<Instruction> closeConnectSlot({
    required Ed25519HDPublicKey host,
    required Ed25519HDPublicKey slotPda,
    required Ed25519HDPublicKey viewer,
    required Ed25519HDPublicKey configPda,
    required Ed25519HDPublicKey serviceWallet,
  }) async {
    final request = await SolsStreamCloseConnectSlotAccountResolver(_context).prepare(
      args: const SolsStreamCloseConnectSlotArgs(),
      overrides: SolsStreamCloseConnectSlotAccountOverrides(
        host: _use(host),
        slot: _use(slotPda),
        viewer: _use(viewer),
        config: _use(configPda),
        serviceWallet: _use(serviceWallet),
      ),
    );

    return _instruction(request.instruction());
  }

  Future<Instruction> endRoom({
    required Ed25519HDPublicKey host,
    required Ed25519HDPublicKey roomPda,
  }) async {
    final request = await SolsStreamEndRoomAccountResolver(_context).prepare(
      args: const SolsStreamEndRoomArgs(),
      overrides: SolsStreamEndRoomAccountOverrides(
        host: _use(host),
        room: _use(roomPda),
      ),
    );

    return _instruction(request.instruction());
  }

  Future<Instruction> leaveRoom({
    required Ed25519HDPublicKey viewer,
    required Ed25519HDPublicKey roomPda,
  }) async {
    final request = await SolsStreamLeaveRoomAccountResolver(_context).prepare(
      args: const SolsStreamLeaveRoomArgs(),
      overrides: SolsStreamLeaveRoomAccountOverrides(
        viewer: _use(viewer),
        room: _use(roomPda),
      ),
    );

    return _instruction(request.instruction());
  }

  Future<Instruction> closeRoom({
    required Ed25519HDPublicKey host,
    required Ed25519HDPublicKey roomPda,
  }) async {
    final request = await SolsStreamCloseRoomAccountResolver(_context).prepare(
      args: const SolsStreamCloseRoomArgs(),
      overrides: SolsStreamCloseRoomAccountOverrides(
        host: _use(host),
        room: _use(roomPda),
      ),
    );

    return _instruction(request.instruction());
  }

  Future<Instruction> purchaseTurn({
    required Ed25519HDPublicKey buyer,
    required Ed25519HDPublicKey serviceWallet,
    required Ed25519HDPublicKey configPda,
  }) async {
    final request = await SolsStreamPurchaseTurnAccountResolver(_context).prepare(
      args: const SolsStreamPurchaseTurnArgs(),
      overrides: SolsStreamPurchaseTurnAccountOverrides(
        buyer: _use(buyer),
        serviceWallet: _use(serviceWallet),
        config: _use(configPda),
      ),
    );

    return _instruction(request.instruction());
  }

  Future<Instruction> heartbeat({
    required Ed25519HDPublicKey signer,
    required Ed25519HDPublicKey configPda,
  }) async {
    final request = await SolsStreamHeartbeatAccountResolver(_context).prepare(
      args: const SolsStreamHeartbeatArgs(),
      overrides: SolsStreamHeartbeatAccountOverrides(
        viewer: _use(signer),
        config: _use(configPda),
      ),
    );

    return _instruction(request.instruction());
  }

  Future<List<Instruction>> _chunkedWrite({
    required Ed25519HDPublicKey signer,
    required Ed25519HDPublicKey slotPda,
    required Uint8List payload,
    required bool offer,
  }) {
    final chunks = <Uint8List>[];
    for (var offset = 0; offset < payload.length; offset += SignalingProtocolConstants.chunkSize) {
      chunks.add(
        payload.sublist(
          offset,
          (offset + SignalingProtocolConstants.chunkSize).clamp(
            0,
            payload.length,
          ),
        ),
      );
    }
    if (chunks.isEmpty) chunks.add(Uint8List(0));

    return Future.wait([
      for (var index = 0; index < chunks.length; index++)
        _write(
          signer: signer,
          slotPda: slotPda,
          protectedKey: Uint8List(0),
          data: chunks[index],
          finalize: index == chunks.length - 1,
          offer: offer,
        ),
    ]);
  }

  Future<Instruction> _write({
    required Ed25519HDPublicKey signer,
    required Ed25519HDPublicKey slotPda,
    required Uint8List protectedKey,
    required Uint8List data,
    required bool finalize,
    required bool offer,
  }) async {
    if (offer) {
      final args = SolsStreamWriteOfferArgs(
        hostProtectedKey: protectedKey,
        offerData: data,
        finalize: finalize,
      );
      final request = await SolsStreamWriteOfferAccountResolver(_context).prepare(
        args: args,
        overrides: SolsStreamWriteOfferAccountOverrides(
          host: _use(signer),
          slot: _use(slotPda),
        ),
      );

      return _instruction(request.instruction());
    }
    final args = SolsStreamWriteAnswerArgs(
      viewerProtectedKey: protectedKey,
      answerData: data,
      finalize: finalize,
    );
    final request = await SolsStreamWriteAnswerAccountResolver(_context).prepare(
      args: args,
      overrides: SolsStreamWriteAnswerAccountOverrides(
        viewer: _use(signer),
        slot: _use(slotPda),
      ),
    );

    return _instruction(request.instruction());
  }

  SolsStreamCreateRoomArgs _createRoomArgs(
    int roomNonce,
    RoomCreationParams params,
  ) => SolsStreamCreateRoomArgs(
    title: params.title,
    category: _roomCategory(params.category),
    accessMode: _accessMode(params.accessMode),
    connectionMode: _connectionMode(params.connectionMode),
    pricePerMinute: _u64(params.pricePerMinute, 'pricePerMinute'),
    pricePerSession: _u64(params.pricePerSession, 'pricePerSession'),
    depositLamports: BigInt.from(SignalingProtocolConstants.depositLamports),
    nonce: _u64(roomNonce, 'roomNonce'),
  );

  SolsStreamAccountOverride _use(Ed25519HDPublicKey address) =>
      SolsStreamAccountOverride.use(wireAdapter.toGeneratedAddress(address));

  Instruction _instruction(SolsStreamInstruction instruction) => wireAdapter.toSolanaInstruction(instruction);

  BigInt _u64(int value, String name) {
    final result = BigInt.from(value);
    if (result.isNegative || result > _maxU64) {
      throw ArgumentError.value(value, name, 'must fit an unsigned 64-bit integer');
    }

    return result;
  }

  SolsStreamRoomCategory _roomCategory(int value) => switch (value) {
    0 => const SolsStreamRoomCategoryGeneral(),
    1 => const SolsStreamRoomCategoryGaming(),
    2 => const SolsStreamRoomCategoryMusic(),
    3 => const SolsStreamRoomCategoryEducation(),
    4 => const SolsStreamRoomCategoryTech(),
    5 => const SolsStreamRoomCategoryArt(),
    6 => const SolsStreamRoomCategorySocial(),
    7 => const SolsStreamRoomCategoryOther(),
    _ => throw ArgumentError.value(value, 'category', 'unknown IDL enum variant'),
  };

  SolsStreamAccessMode _accessMode(int value) => switch (value) {
    0 => const SolsStreamAccessModePublic(),
    1 => const SolsStreamAccessModePrivate(),
    2 => const SolsStreamAccessModePaid(),
    _ => throw ArgumentError.value(value, 'accessMode', 'unknown IDL enum variant'),
  };

  SolsStreamConnectionMode _connectionMode(int value) => switch (value) {
    0 => const SolsStreamConnectionModeStream(),
    1 => const SolsStreamConnectionModeP2P(),
    _ => throw ArgumentError.value(value, 'connectionMode', 'unknown IDL enum variant'),
  };
}
