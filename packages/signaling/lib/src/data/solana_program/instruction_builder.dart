import 'dart:typed_data';

import 'package:signaling/src/data/solana_program/borsh_writer.dart';
import 'package:signaling/src/data/solana_program/signaling_program_constants.dart';
import 'package:signaling/src/domain/room_creation_params.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';

Ed25519HDPublicKey get _programId => Ed25519HDPublicKey.fromBase58(SignalingProgramConstants.programId);
Ed25519HDPublicKey get _systemProgramId => Ed25519HDPublicKey.fromBase58(SignalingProgramConstants.systemProgramId);

Future<Ed25519HDPublicKey> deriveRoomPda(
  Ed25519HDPublicKey host,
  int roomNonce,
) => Ed25519HDPublicKey.findProgramAddress(
  seeds: [
    'room'.codeUnits,
    host.bytes,
    ByteArray.u64(roomNonce).toList(),
  ],
  programId: _programId,
);

Future<Ed25519HDPublicKey> deriveSlotPda(
  Ed25519HDPublicKey roomPda,
  int slotNonce,
) => Ed25519HDPublicKey.findProgramAddress(
  seeds: [
    'slot'.codeUnits,
    roomPda.bytes,
    ByteArray.u64(slotNonce).toList(),
  ],
  programId: _programId,
);

Future<Ed25519HDPublicKey> _deriveUserPda(Ed25519HDPublicKey host) => Ed25519HDPublicKey.findProgramAddress(
  seeds: ['user'.codeUnits, host.bytes],
  programId: _programId,
);

/// Derives the singleton `ProgramConfig` PDA (seed `[b"config"]`, no extra
/// seeds). Public so the chain gateway can read `service_wallet` from it.
Future<Ed25519HDPublicKey> deriveConfigPda() => Ed25519HDPublicKey.findProgramAddress(
  seeds: ['config'.codeUnits],
  programId: _programId,
);

Future<Instruction> buildCreateRoom({
  required Ed25519HDPublicKey host,
  required int roomNonce,
  RoomCreationParams params = const RoomCreationParams.p2pFree(),
}) async {
  final roomPda = await deriveRoomPda(host, roomNonce);
  final userPda = await _deriveUserPda(host);

  final data = ByteArray.merge([
    ByteArray(SignalingProgramConstants.discCreateRoom),
    bString(params.title),
    ByteArray.u8(params.category),
    ByteArray.u8(params.accessMode),
    ByteArray.u8(params.connectionMode),
    ByteArray.u64(params.pricePerMinute),
    ByteArray.u64(params.pricePerSession),
    ByteArray.u64(SignalingProgramConstants.depositLamports),
    ByteArray.u64(roomNonce),
  ]);

  return Instruction(
    programId: _programId,
    accounts: [
      AccountMeta.writeable(pubKey: host, isSigner: true),
      AccountMeta.writeable(pubKey: userPda, isSigner: false),
      AccountMeta.writeable(pubKey: roomPda, isSigner: false),
      AccountMeta.readonly(pubKey: _systemProgramId, isSigner: false),
    ],
    data: data,
  );
}

Future<Instruction> buildOpenConnectSlot({
  required Ed25519HDPublicKey host,
  required Ed25519HDPublicKey roomPda,
  required int slotNonce,
}) async {
  final slotPda = await deriveSlotPda(roomPda, slotNonce);

  final data = ByteArray.merge([
    ByteArray(SignalingProgramConstants.discOpenSlot),
    ByteArray.u64(slotNonce),
    ByteArray.u64(SignalingProgramConstants.depositLamports),
    ByteArray.u64(SignalingProgramConstants.expiresInSec),
  ]);

  return Instruction(
    programId: _programId,
    accounts: [
      AccountMeta.writeable(pubKey: host, isSigner: true),
      AccountMeta.readonly(pubKey: roomPda, isSigner: false),
      AccountMeta.writeable(pubKey: slotPda, isSigner: false),
      AccountMeta.readonly(pubKey: _systemProgramId, isSigner: false),
    ],
    data: data,
  );
}

Future<Instruction> buildClaimConnectSlot({
  required Ed25519HDPublicKey viewer,
  required Ed25519HDPublicKey slotPda,
  required Ed25519HDPublicKey roomPda,
}) async {
  final data = ByteArray.merge([
    ByteArray(SignalingProgramConstants.discClaimSlot),
    ByteArray.u64(SignalingProgramConstants.depositLamports),
  ]);

  return Instruction(
    programId: _programId,
    accounts: [
      AccountMeta.writeable(pubKey: viewer, isSigner: true),
      AccountMeta.writeable(pubKey: slotPda, isSigner: false),
      AccountMeta.readonly(pubKey: roomPda, isSigner: false),
      AccountMeta.readonly(pubKey: _systemProgramId, isSigner: false),
    ],
    data: data,
  );
}

List<Instruction> buildWriteOffer({
  required Ed25519HDPublicKey host,
  required Ed25519HDPublicKey slotPda,
  required Uint8List encryptedPayload,
}) => _buildChunkedWrite(
  disc: SignalingProgramConstants.discWriteOffer,
  signer: host,
  slotPda: slotPda,
  payload: encryptedPayload,
);

List<Instruction> buildWriteAnswer({
  required Ed25519HDPublicKey viewer,
  required Ed25519HDPublicKey slotPda,
  required Uint8List encryptedPayload,
}) => _buildChunkedWrite(
  disc: SignalingProgramConstants.discWriteAnswer,
  signer: viewer,
  slotPda: slotPda,
  payload: encryptedPayload,
);

List<Instruction> _buildChunkedWrite({
  required List<int> disc,
  required Ed25519HDPublicKey signer,
  required Ed25519HDPublicKey slotPda,
  required Uint8List payload,
}) {
  final chunks = <Uint8List>[];
  for (int i = 0; i < payload.length; i += SignalingProgramConstants.chunkSize) {
    chunks.add(payload.sublist(i, (i + SignalingProgramConstants.chunkSize).clamp(0, payload.length)));
  }
  if (chunks.isEmpty) chunks.add(Uint8List(0));

  return List.generate(chunks.length, (i) {
    final isLast = i == chunks.length - 1;
    final data = ByteArray.merge([
      ByteArray(disc),
      bVec([]), // protected_key: empty (we embed key in URL)
      bVec(chunks[i]), // data chunk
      ByteArray.u8(isLast ? 1 : 0), // finalize flag
    ]);

    return Instruction(
      programId: _programId,
      accounts: [
        AccountMeta.writeable(pubKey: signer, isSigner: true),
        AccountMeta.writeable(pubKey: slotPda, isSigner: false),
        AccountMeta.readonly(pubKey: _systemProgramId, isSigner: false),
      ],
      data: data,
    );
  });
}

Instruction buildConfirmConnection({
  required Ed25519HDPublicKey signer,
  required Ed25519HDPublicKey slotPda,
}) => Instruction(
  programId: _programId,
  accounts: [
    AccountMeta.writeable(pubKey: signer, isSigner: true),
    AccountMeta.writeable(pubKey: slotPda, isSigner: false),
    AccountMeta.readonly(pubKey: _systemProgramId, isSigner: false),
  ],
  data: ByteArray(SignalingProgramConstants.discConfirmConnection),
);

/// `close_connect_slot` — host reclaims the slot deposit. The program skims 1%
/// to [serviceWallet] and refunds the rest to host + viewer. `data` is the
/// discriminator only. Account order is load-bearing (a wrong order/flag loses
/// funds); see `reference/program-client.js`.
///
/// [viewer] must be the slot's claimer; for an unclaimed slot the caller passes
/// [host] as the placeholder (matching the web client).
Instruction buildCloseConnectSlot({
  required Ed25519HDPublicKey host,
  required Ed25519HDPublicKey slotPda,
  required Ed25519HDPublicKey viewer,
  required Ed25519HDPublicKey configPda,
  required Ed25519HDPublicKey serviceWallet,
}) => Instruction(
  programId: _programId,
  accounts: [
    AccountMeta.writeable(pubKey: host, isSigner: true),
    AccountMeta.writeable(pubKey: slotPda, isSigner: false),
    AccountMeta.writeable(pubKey: viewer, isSigner: false),
    AccountMeta.readonly(pubKey: configPda, isSigner: false),
    AccountMeta.writeable(pubKey: serviceWallet, isSigner: false),
  ],
  data: ByteArray(SignalingProgramConstants.discCloseConnectSlot),
);

/// `end_room` — host marks the room not-live. `data` is the discriminator only.
/// Note the asymmetry with [buildCloseRoom]: here `host` is **read-only**.
Future<Instruction> buildEndRoom({
  required Ed25519HDPublicKey host,
  required Ed25519HDPublicKey roomPda,
}) async {
  final userPda = await _deriveUserPda(host);

  return Instruction(
    programId: _programId,
    accounts: [
      AccountMeta.readonly(pubKey: host, isSigner: true),
      AccountMeta.writeable(pubKey: userPda, isSigner: false),
      AccountMeta.writeable(pubKey: roomPda, isSigner: false),
    ],
    data: ByteArray(SignalingProgramConstants.discEndRoom),
  );
}

/// `close_room` — host reclaims the room rent after `end_room`. `data` is the
/// discriminator only. Note the asymmetry with [buildEndRoom]: here `host` is
/// **writable** because it receives the reclaimed rent.
Future<Instruction> buildCloseRoom({
  required Ed25519HDPublicKey host,
  required Ed25519HDPublicKey roomPda,
}) async {
  final userPda = await _deriveUserPda(host);

  return Instruction(
    programId: _programId,
    accounts: [
      AccountMeta.writeable(pubKey: host, isSigner: true),
      AccountMeta.writeable(pubKey: userPda, isSigner: false),
      AccountMeta.writeable(pubKey: roomPda, isSigner: false),
    ],
    data: ByteArray(SignalingProgramConstants.discCloseRoom),
  );
}
