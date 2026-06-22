import 'package:signaling/src/data/solana_program/instruction_builder.dart';
import 'package:signaling/src/data/solana_program/signaling_program_constants.dart';
import 'package:solana/solana.dart';
import 'package:test/test.dart';

Ed25519HDPublicKey _key(int fill) => Ed25519HDPublicKey(List.filled(32, fill));

Ed25519HDPublicKey get _programId =>
    Ed25519HDPublicKey.fromBase58(SignalingProgramConstants.programId);

Future<Ed25519HDPublicKey> _expectedUserPda(Ed25519HDPublicKey host) =>
    Ed25519HDPublicKey.findProgramAddress(
      seeds: ['user'.codeUnits, host.bytes],
      programId: _programId,
    );

void main() {
  final host = _key(1);
  final slot = _key(2);
  final viewer = _key(3);
  final config = _key(4);
  final serviceWallet = _key(5);
  final room = _key(6);

  group('buildCloseConnectSlot', () {
    final ix = buildCloseConnectSlot(
      host: host,
      slotPda: slot,
      viewer: viewer,
      configPda: config,
      serviceWallet: serviceWallet,
    );

    test('data is the discriminator only', () {
      expect(ix.data.toList(), SignalingProgramConstants.discCloseConnectSlot);
    });

    test('account order and flags are byte-exact', () {
      expect(ix.accounts.map((a) => a.pubKey).toList(), [
        host, slot, viewer, config, serviceWallet,
      ]);
      // host: signer + writable; slot: writable; viewer: writable;
      // config: readonly; service_wallet: writable.
      expect(ix.accounts.map((a) => a.isSigner).toList(), [true, false, false, false, false]);
      expect(ix.accounts.map((a) => a.isWriteable).toList(), [true, true, true, false, true]);
    });
  });

  group('buildEndRoom', () {
    test('host is signer + READONLY; user PDA + room writable; disc-only data', () async {
      final ix = await buildEndRoom(host: host, roomPda: room);
      final userPda = await _expectedUserPda(host);

      expect(ix.data.toList(), SignalingProgramConstants.discEndRoom);
      expect(ix.accounts.map((a) => a.pubKey).toList(), [host, userPda, room]);
      expect(ix.accounts.map((a) => a.isSigner).toList(), [true, false, false]);
      // The end_room/close_room asymmetry: host is read-only here.
      expect(ix.accounts.map((a) => a.isWriteable).toList(), [false, true, true]);
    });
  });

  group('buildCloseRoom', () {
    test('host is signer + WRITABLE (receives rent); disc-only data', () async {
      final ix = await buildCloseRoom(host: host, roomPda: room);
      final userPda = await _expectedUserPda(host);

      expect(ix.data.toList(), SignalingProgramConstants.discCloseRoom);
      expect(ix.accounts.map((a) => a.pubKey).toList(), [host, userPda, room]);
      expect(ix.accounts.map((a) => a.isSigner).toList(), [true, false, false]);
      // host is writable here (asymmetry with end_room).
      expect(ix.accounts.map((a) => a.isWriteable).toList(), [true, true, true]);
    });
  });
}
