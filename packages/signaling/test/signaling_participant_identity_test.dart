import 'package:signaling/signaling.dart';
import 'package:test/test.dart';

void main() {
  test('copies public-key bytes on input and output', () {
    final source = List<int>.filled(32, 1);
    final identity = SignalingParticipantIdentity.fromPublicKey(
      publicKeyBytes: source,
      addressEncoder: (bytes) => bytes.join(','),
    );

    source[0] = 2;
    final exposed = identity.publicKeyBytes;
    exposed[1] = 3;

    expect(identity.publicKeyBytes, everyElement(1));
    expect(identity.address, List<int>.filled(32, 1).join(','));
  });
}
