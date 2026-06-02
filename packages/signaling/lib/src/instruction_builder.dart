import 'dart:typed_data';

import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';

// Anchor 8-byte discriminators from sols.stream program-client.js
const _discCreateRoom        = [130,166,32,2,247,120,178,53];
const _discOpenSlot          = [200,199,43,201,133,53,221,183];
const _discClaimSlot         = [110,60,180,109,39,35,5,140];
const _discWriteOffer        = [50,36,220,142,101,119,205,194];
const _discWriteAnswer       = [229,79,107,103,29,50,93,119];
const _discConfirmConnection = [219,162,27,145,211,2,134,122];

const _programIdStr   = '8rYyL3AY3cb4XrFWfUokXKwQb8uU48XvuLAHNxTgdmXw';
const _systemProgram  = '11111111111111111111111111111111';
const _depositLamports = 1000000;  // 0.001 SOL
const _expiresInSec    = 120;      // 2 min slot expiry
const _chunkSize       = 800;      // max bytes per write ix

Ed25519HDPublicKey get _programId =>
    Ed25519HDPublicKey.fromBase58(_programIdStr);
Ed25519HDPublicKey get _systemProgramId =>
    Ed25519HDPublicKey.fromBase58(_systemProgram);

// ── Borsh helpers (little-endian) ────────────────────────────────────────────

// Borsh string: u32-LE length prefix + UTF-8 bytes
ByteArray _bString(String s) => ByteArray.merge([
      ByteArray.u32(s.codeUnits.length),
      ByteArray(s.codeUnits),
    ]);

// Borsh Vec<u8>: u32-LE length prefix + raw bytes
ByteArray _bVec(Iterable<int> bytes) {
  final list = bytes.toList();
  return ByteArray.merge([ByteArray.u32(list.length), ByteArray(list)]);
}

// ── PDA derivation ────────────────────────────────────────────────────────────

Future<Ed25519HDPublicKey> deriveRoomPda(
  Ed25519HDPublicKey host,
  int roomNonce,
) =>
    Ed25519HDPublicKey.findProgramAddress(
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
) =>
    Ed25519HDPublicKey.findProgramAddress(
      seeds: [
        'slot'.codeUnits,
        roomPda.bytes,
        ByteArray.u64(slotNonce).toList(),
      ],
      programId: _programId,
    );

Future<Ed25519HDPublicKey> _deriveUserPda(Ed25519HDPublicKey host) =>
    Ed25519HDPublicKey.findProgramAddress(
      seeds: ['user'.codeUnits, host.bytes],
      programId: _programId,
    );

// ── Instructions ──────────────────────────────────────────────────────────────

Future<Instruction> buildCreateRoom({
  required Ed25519HDPublicKey host,
  required int roomNonce,
}) async {
  final roomPda = await deriveRoomPda(host, roomNonce);
  final userPda = await _deriveUserPda(host);

  final data = ByteArray.merge([
    ByteArray(_discCreateRoom),
    _bString('p2p'),        // title
    ByteArray.u8(0),         // category: General
    ByteArray.u8(0),         // access_mode: Public
    ByteArray.u8(1),         // connection_mode: P2P
    ByteArray.u64(0),        // price_per_minute
    ByteArray.u64(0),        // price_per_session
    ByteArray.u64(_depositLamports),
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
    ByteArray(_discOpenSlot),
    ByteArray.u64(slotNonce),
    ByteArray.u64(_depositLamports),
    ByteArray.u64(_expiresInSec),
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
    ByteArray(_discClaimSlot),
    ByteArray.u64(_depositLamports),
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
}) =>
    _buildChunkedWrite(
      disc: _discWriteOffer,
      signer: host,
      slotPda: slotPda,
      payload: encryptedPayload,
    );

List<Instruction> buildWriteAnswer({
  required Ed25519HDPublicKey viewer,
  required Ed25519HDPublicKey slotPda,
  required Uint8List encryptedPayload,
}) =>
    _buildChunkedWrite(
      disc: _discWriteAnswer,
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
  for (var i = 0; i < payload.length; i += _chunkSize) {
    chunks.add(payload.sublist(i, (i + _chunkSize).clamp(0, payload.length)));
  }
  if (chunks.isEmpty) chunks.add(Uint8List(0));

  return List.generate(chunks.length, (i) {
    final isLast = i == chunks.length - 1;
    final data = ByteArray.merge([
      ByteArray(disc),
      _bVec([]),             // protected_key: empty (we embed key in URL)
      _bVec(chunks[i]),      // data chunk
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

Future<Instruction> buildConfirmConnection({
  required Ed25519HDPublicKey signer,
  required Ed25519HDPublicKey slotPda,
}) async =>
    Instruction(
      programId: _programId,
      accounts: [
        AccountMeta.writeable(pubKey: signer, isSigner: true),
        AccountMeta.writeable(pubKey: slotPda, isSigner: false),
        AccountMeta.readonly(pubKey: _systemProgramId, isSigner: false),
      ],
      data: ByteArray(_discConfirmConnection),
    );
