import 'package:signaling/src/data/solana_program/solana_error_codes.dart';
import 'package:test/test.dart';

void main() {
  group('solanaErrorName lookup', () {
    test('resolves known codes to their Anchor names', () {
      expect(solanaErrorName(6000), 'NicknameTooLong');
      expect(solanaErrorName(6015), 'SlotExpired');
      expect(solanaErrorName(6023), 'DepositMismatch');
      expect(solanaErrorName(6032), 'SlotConnected');
    });

    test('returns null for out-of-range / unknown codes', () {
      expect(solanaErrorName(5999), isNull);
      expect(solanaErrorName(7000), isNull);
      expect(solanaErrorName(0), isNull);
      expect(solanaErrorName(-1), isNull);
    });

    test('never throws for any int input', () {
      for (final code in [
        -2147483648,
        -1,
        0,
        5999,
        6000,
        6016,
        6032,
        6033,
        9999,
        2147483647,
      ]) {
        expect(() => solanaErrorName(code), returnsNormally, reason: '$code');
      }
    });
  });

  group('SolanaErrorCodes map', () {
    test('covers the full 6000..6032 range contiguously', () {
      for (var code = SolanaErrorCodes.firstCode;
          code <= SolanaErrorCodes.lastCode;
          code++) {
        expect(SolanaErrorCodes.names[code], isNotNull, reason: '$code');
      }
      expect(
        SolanaErrorCodes.names.length,
        SolanaErrorCodes.lastCode - SolanaErrorCodes.firstCode + 1,
      );
    });
  });
}
