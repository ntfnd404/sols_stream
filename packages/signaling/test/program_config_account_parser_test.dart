import 'dart:typed_data';

import 'package:signaling/src/data/solana_program/program_config_account_parser.dart';
import 'package:signaling/src/data/solana_program/signaling_program_constants.dart';
import 'package:test/test.dart';

Uint8List _u64le(int v) =>
    (ByteData(8)..setUint64(0, v, Endian.little)).buffer.asUint8List();

/// Builds a Borsh ProgramConfig account buffer matching the parser's layout.
Uint8List _account({
  List<int>? disc,
  int authorityFill = 7,
  int serviceWalletFill = 9,
  int turnPrice = 100,
  int signalFee = 200,
  int heartbeatTtl = 300,
  int minHeartbeatInterval = 400,
  int bump = 253,
}) {
  final b = BytesBuilder()
    ..add(Uint8List.fromList(disc ?? SignalingProgramConstants.discProgramConfigAccount))
    ..add(Uint8List.fromList(List.filled(32, authorityFill)))
    ..add(Uint8List.fromList(List.filled(32, serviceWalletFill)))
    ..add(_u64le(turnPrice))
    ..add(_u64le(signalFee))
    ..add(_u64le(heartbeatTtl))
    ..add(_u64le(minHeartbeatInterval))
    ..add(Uint8List.fromList([bump]));

  return b.toBytes();
}

void main() {
  group('ProgramConfigAccountParser', () {
    test('parses every field from a valid account buffer', () {
      final account = ProgramConfigAccountParser.parse(_account())!;

      expect(account.authority, List.filled(32, 7));
      expect(account.serviceWallet, List.filled(32, 9));
      expect(account.turnPrice, BigInt.from(100));
      expect(account.signalFee, BigInt.from(200));
      expect(account.heartbeatTtl, BigInt.from(300));
      expect(account.minHeartbeatInterval, BigInt.from(400));
      expect(account.bump, 253);
    });

    test('service_wallet sits at offset 40 (8 disc + 32 authority)', () {
      final account = ProgramConfigAccountParser.parse(
        _account(serviceWalletFill: 42),
      )!;

      expect(account.serviceWallet, List.filled(32, 42));
    });

    test('returns null on a discriminator mismatch (not a ProgramConfig)', () {
      final wrongDisc = ProgramConfigAccountParser.parse(
        _account(disc: List.filled(8, 0)),
      );

      expect(wrongDisc, isNull);
    });

    test('returns null on a buffer shorter than the discriminator', () {
      expect(ProgramConfigAccountParser.parse(Uint8List(4)), isNull);
    });
  });
}
