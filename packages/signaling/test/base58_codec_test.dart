import 'package:signaling/src/application/base58_codec.dart';
import 'package:test/test.dart';

void main() {
  test('preserves leading zero bytes without adding an extra digit', () {
    expect(base58Encode([0]), '1');
    expect(base58Encode([0, 0]), '11');
    expect(base58Encode([0, 1]), '12');
  });

  test('encodes an all-zero Solana public key as 32 leading-one digits', () {
    expect(base58Encode(List<int>.filled(32, 0)), '1' * 32);
  });
}
