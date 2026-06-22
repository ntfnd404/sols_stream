import 'dart:convert';

import 'package:signaling/src/data/solana_program/instruction_builder.dart';
import 'package:signaling/src/data/solana_program/signaling_program_constants.dart';
import 'package:solana/solana.dart';
import 'package:test/test.dart';

Ed25519HDPublicKey _key(int fill) => Ed25519HDPublicKey(List.filled(32, fill));

Ed25519HDPublicKey get _programId => Ed25519HDPublicKey.fromBase58(SignalingProgramConstants.programId);

Ed25519HDPublicKey get _systemProgramId =>
    Ed25519HDPublicKey.fromBase58(SignalingProgramConstants.systemProgramId);

Future<Ed25519HDPublicKey> _expectedUserPda(Ed25519HDPublicKey wallet) => Ed25519HDPublicKey.findProgramAddress(
      seeds: ['user'.codeUnits, wallet.bytes],
      programId: _programId,
    );

void main() {
  final authority = _key(1);

  group('buildCreateUser', () {
    test('data is discriminator + Borsh string nickname (4-byte LE len + utf8)', () async {
      final ix = await buildCreateUser(authority: authority, nickname: 'neo');
      final nick = utf8.encode('neo');

      expect(ix.data.toList(), [
        ...SignalingProgramConstants.discCreateUser,
        nick.length, 0, 0, 0, // u32 LE length prefix
        ...nick,
      ]);
    });

    test('defaults the nickname to the configured constant', () async {
      final ix = await buildCreateUser(authority: authority);
      final nick = utf8.encode(SignalingProgramConstants.defaultNickname);

      expect(ix.data.toList(), [
        ...SignalingProgramConstants.discCreateUser,
        nick.length, 0, 0, 0,
        ...nick,
      ]);
    });

    test('account order and flags are byte-exact', () async {
      final ix = await buildCreateUser(authority: authority);
      final userPda = await _expectedUserPda(authority);

      // authority (signer, writable), user PDA (writable), system_program (readonly).
      expect(ix.accounts.map((a) => a.pubKey).toList(), [authority, userPda, _systemProgramId]);
      expect(ix.accounts.map((a) => a.isSigner).toList(), [true, false, false]);
      expect(ix.accounts.map((a) => a.isWriteable).toList(), [true, true, false]);
    });
  });
}
