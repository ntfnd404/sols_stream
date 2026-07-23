import 'package:signaling/signaling.dart';
import 'package:test/test.dart';

void main() {
  test('PeerHostSession toString redacts capability query values', () {
    final session = PeerHostSession(
      connectionUrl:
          'https://p2p.example/home?intent=p2p&role=viewer'
          '&host=abc&public=1&prot=secret',
      slotPda: 'slot',
      awaitAnswerSdp: () async => '{}',
      confirm: () async {},
      cancelWaiting: () {},
      teardown: () async {},
    );

    final value = session.toString();

    expect(value, contains('prot=%5Bredacted%5D'));
    expect(value, isNot(contains('secret')));
  });

  test('PeerOffer toString redacts SDP', () {
    const offer = PeerOffer(
      sdpOffer: '{"sdp":"secret-sdp"}',
      slotPda: 'slot',
      hostAddress: 'host',
    );

    final value = offer.toString();

    expect(value, contains('sdpOffer: [redacted]'));
    expect(value, isNot(contains('secret-sdp')));
  });
}
