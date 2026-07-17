import 'dart:typed_data';

import 'package:signaling/signaling.dart';
import 'package:signaling_solana/src/data/solana_program/sols_stream_instruction_factory.dart';
import 'package:signaling_solana/src/generated/sols_stream_solana.dart';
import 'package:solana/solana.dart';
import 'package:test/test.dart';

Ed25519HDPublicKey _key(int fill) => Ed25519HDPublicKey(List<int>.filled(32, fill));

void main() {
  final factory = SolsStreamInstructionFactory();
  final host = _key(1);
  final room = _key(2);
  final slot = _key(3);

  test('create_user preserves discriminator and ordered account flags', () async {
    final instruction = await factory.createUser(authority: host);

    expect(
      instruction.data.toList().take(8),
      SolsStreamCreateUserRequest.discriminator,
    );
    expect(instruction.programId.toBase58(), SolsStreamProgram.programAddress.toBase58());
    expect(
      instruction.accounts.map((meta) => (meta.isSigner, meta.isWriteable)).toList(),
      [(true, true), (false, true), (false, false)],
    );
  });

  test('generated PDA resolution matches package:solana', () async {
    final actualUser = await factory.deriveUserPda(host);
    final expectedUser = await Ed25519HDPublicKey.findProgramAddress(
      seeds: ['user'.codeUnits, host.bytes],
      programId: Ed25519HDPublicKey.fromBase58(
        SolsStreamProgram.programAddress.toBase58(),
      ),
    );
    final actualRoom = await factory.deriveRoomPda(host, 7);

    expect(actualUser, expectedUser);
    expect(
      actualRoom,
      await Ed25519HDPublicKey.findProgramAddress(
        seeds: [
          'room'.codeUnits,
          host.bytes,
          (ByteData(8)..setUint64(0, 7, Endian.little)).buffer.asUint8List(),
        ],
        programId: Ed25519HDPublicKey.fromBase58(
          SolsStreamProgram.programAddress.toBase58(),
        ),
      ),
    );
  });

  test('close/end/leave retain load-bearing account flags', () async {
    final closeSlot = await factory.closeConnectSlot(
      host: host,
      slotPda: slot,
      viewer: _key(4),
      configPda: _key(5),
      serviceWallet: _key(6),
    );
    final endRoom = await factory.endRoom(host: host, roomPda: room);
    final leaveRoom = await factory.leaveRoom(viewer: host, roomPda: room);

    expect(closeSlot.data.toList(), SolsStreamCloseConnectSlotRequest.discriminator);
    expect(
      closeSlot.accounts.map((meta) => (meta.isSigner, meta.isWriteable)),
      [(true, true), (false, true), (false, true), (false, false), (false, true)],
    );
    expect(endRoom.accounts.first.isWriteable, isFalse);
    expect(leaveRoom.accounts.first.isWriteable, isFalse);
  });

  test('write chunking preserves lead and single final chunk', () async {
    final payload = Uint8List.fromList(List<int>.generate(801, (index) => index % 256));
    final instructions = await factory.writeOfferWithProtectedKey(
      host: host,
      slotPda: slot,
      protectedKey: Uint8List.fromList([9, 8]),
      encryptedPayload: payload,
    );

    expect(instructions, hasLength(3));
    final decoded = instructions
        .map(
          (instruction) => SolsStreamWriteOfferArgs.codec.decodeExact(
            instruction.data.toList().sublist(8),
          ),
        )
        .toList();
    expect(decoded[0].hostProtectedKey, [9, 8]);
    expect(decoded[0].offerData, isEmpty);
    expect(decoded[0].finalize, isFalse);
    expect(decoded[1].offerData, hasLength(800));
    expect(decoded[1].finalize, isFalse);
    expect(decoded[2].offerData, hasLength(1));
    expect(decoded[2].finalize, isTrue);
  });

  test('empty payload still emits one final write', () async {
    final instructions = await factory.writeAnswer(
      viewer: host,
      slotPda: slot,
      encryptedPayload: Uint8List(0),
    );
    final args = SolsStreamWriteAnswerArgs.codec.decodeExact(
      instructions.single.data.toList().sublist(8),
    );

    expect(args.answerData, isEmpty);
    expect(args.finalize, isTrue);
  });

  test('proof remains a non-Anchor application instruction', () {
    final instruction = factory.proof(prover: host, slotPda: slot.toBase58());

    expect(instruction.accounts.single.isSigner, isTrue);
    expect(instruction.accounts.single.isWriteable, isFalse);
    expect(String.fromCharCodes(instruction.data), 'proof:${slot.toBase58()}');
  });

  test('unknown domain enum code is rejected before serialization', () {
    final params = RoomCreationParams(
      title: 'test',
      category: 8,
      accessMode: 0,
      connectionMode: 1,
      pricePerMinute: 0,
      pricePerSession: 0,
    );

    expect(
      () => factory.createRoom(host: host, roomNonce: 1, params: params),
      throwsArgumentError,
    );
  });

  test('metadata registries expose every IDL declaration once', () {
    expect(SolsStreamAccountRegistry.accounts, hasLength(4));
    expect(SolsStreamInstructionRegistry.instructions, hasLength(27));
    expect(
      SolsStreamInstructionRegistry.byName['create_room']?.accounts.map((account) => account.name),
      ['host', 'host_user', 'room', 'system_program'],
    );
  });
}
