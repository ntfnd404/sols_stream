import 'package:signaling/src/application/signaling_nonce.dart';
import 'package:test/test.dart';

void main() {
  group('signalingNonceFromBytes', () {
    test('uses all 53 exact integer bits', () {
      final nonce = signalingNonceFromBytes(
        List<int>.filled(7, 255),
      );

      expect(nonce, 9007199254740991);
    });

    test('ignores the three unsafe high bits', () {
      final withHighBits = signalingNonceFromBytes([
        255,
        1,
        2,
        3,
        4,
        5,
        6,
      ]);
      final withoutHighBits = signalingNonceFromBytes([
        31,
        1,
        2,
        3,
        4,
        5,
        6,
      ]);

      expect(withHighBits, withoutHighBits);
    });

    test('rejects an unexpected byte length', () {
      expect(
        () => signalingNonceFromBytes(List<int>.filled(8, 0)),
        throwsArgumentError,
      );
    });
  });
}
