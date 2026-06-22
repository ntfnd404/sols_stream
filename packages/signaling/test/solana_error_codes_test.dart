import 'package:signaling/src/data/solana_program/solana_error_codes.dart';
import 'package:solana/solana.dart' show JsonRpcException;
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

  group('solanaCustomErrorCode extraction', () {
    JsonRpcException withData(Object? data) => JsonRpcException('failed', -32002, data);

    test('reads the Custom code from a failed instruction payload', () {
      final error = withData({
        'err': {
          'InstructionError': [0, {'Custom': 6023}],
        },
        'logs': <String>[],
      });

      expect(solanaCustomErrorCode(error), 6023);
      expect(solanaErrorName(solanaCustomErrorCode(error)!), 'DepositMismatch');
    });

    test('tolerates InstructionError at the payload top level', () {
      final error = withData({
        'InstructionError': [1, {'Custom': 6009}],
      });

      expect(solanaCustomErrorCode(error), 6009);
    });

    test('returns null when there is no custom code', () {
      expect(solanaCustomErrorCode(withData({'err': 'BlockhashNotFound'})), isNull);
      expect(solanaCustomErrorCode(withData({'err': {'InstructionError': [0, 'InvalidAccountData']}})), isNull);
      expect(solanaCustomErrorCode(withData(null)), isNull);
      expect(solanaCustomErrorCode(withData('opaque')), isNull);
    });

    test('returns null for non-JsonRpcException errors and never throws', () {
      expect(solanaCustomErrorCode(StateError('x')), isNull);
      expect(solanaCustomErrorCode('plain string'), isNull);
      expect(() => solanaCustomErrorCode(Exception('e')), returnsNormally);
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
