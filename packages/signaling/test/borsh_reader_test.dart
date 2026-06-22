import 'dart:typed_data';

import 'package:signaling/src/data/solana_program/borsh_reader.dart';
import 'package:test/test.dart';

Uint8List _u64le(int v) =>
    (ByteData(8)..setUint64(0, v, Endian.little)).buffer.asUint8List();
Uint8List _i64le(int v) =>
    (ByteData(8)..setInt64(0, v, Endian.little)).buffer.asUint8List();

void main() {
  group('BorshReader.readU64', () {
    test('reads zero', () {
      expect(BorshReader(_u64le(0)).readU64(), BigInt.zero);
    });

    test('reads a small value little-endian', () {
      expect(BorshReader(_u64le(1000000)).readU64(), BigInt.from(1000000));
    });

    test('reads a value beyond 2^53 without precision loss', () {
      // First integer a double cannot represent exactly.
      expect(
        BorshReader(_u64le(9007199254740993)).readU64(),
        BigInt.parse('9007199254740993'),
      );
    });

    test('reads the full unsigned range (all bytes 0xFF = 2^64 - 1)', () {
      final maxU64 = BorshReader(Uint8List.fromList(List.filled(8, 0xFF))).readU64();
      expect(maxU64, (BigInt.one << 64) - BigInt.one);
    });
  });

  group('BorshReader.readI64', () {
    test('reads a positive value', () {
      expect(BorshReader(_i64le(1700000000)).readI64(), BigInt.from(1700000000));
    });

    test('reads a negative value (two\'s complement)', () {
      expect(BorshReader(_i64le(-1)).readI64(), BigInt.from(-1));
      expect(BorshReader(_i64le(-1700000000)).readI64(), BigInt.from(-1700000000));
    });
  });

  test('advances the cursor across consecutive 64-bit reads', () {
    final buf = Uint8List.fromList([..._u64le(7), ..._i64le(-9)]);
    final reader = BorshReader(buf);

    expect(reader.readU64(), BigInt.from(7));
    expect(reader.readI64(), BigInt.from(-9));
    expect(reader.remaining, 0);
  });

  test('throws FormatException (not RangeError) on a truncated 64-bit read', () {
    expect(() => BorshReader(Uint8List(4)).readU64(), throwsFormatException);
  });
}
