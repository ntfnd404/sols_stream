import 'package:signaling/src/data/crypto/aes_gcm_signal_payload_codec.dart';
import 'package:test/test.dart';

void main() {
  group('AesGcmSignalPayloadCodec', () {
    const codec = AesGcmSignalPayloadCodec();
    const sdp = '{"type":"offer","sdp":"v=0\\r\\no=- 1 2 IN IP4 0.0.0.0"}';
    const prot = 'c29tZS0zMi1ieXRlLXByb3RlY3Rpb24ta2V5LXg='; // base64
    const slotNonce = 1234567890;

    test('encode → decode round-trips the SDP', () async {
      final bytes = await codec.encode(sdp, prot, slotNonce, 'offer');

      expect(bytes, isNotEmpty);
      expect(await codec.decode(bytes, prot, slotNonce, 'offer'), sdp);
    });

    test('decode with the wrong prot key fails', () async {
      final bytes = await codec.encode(sdp, prot, slotNonce, 'offer');

      expect(
        () => codec.decode(bytes, 'd3JvbmctcHJvdGVjdGlvbi1rZXk=', slotNonce, 'offer'),
        throwsA(anything),
      );
    });

    test('decode with the wrong slotNonce (bound via AAD) fails', () async {
      final bytes = await codec.encode(sdp, prot, slotNonce, 'offer');

      expect(
        () => codec.decode(bytes, prot, slotNonce + 1, 'offer'),
        throwsA(anything),
      );
    });

    test('decode with the wrong messageType (AAD mismatch) fails', () async {
      final bytes = await codec.encode(sdp, prot, slotNonce, 'offer');

      expect(
        () => codec.decode(bytes, prot, slotNonce, 'answer'),
        throwsA(anything),
      );
    });
  });
}
