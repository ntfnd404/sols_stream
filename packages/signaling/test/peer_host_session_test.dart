import 'package:signaling/signaling.dart';
import 'package:test/test.dart';

void main() {
  test('shares one host confirmation across concurrent callers', () async {
    var confirmations = 0;
    final session = PeerHostSession(
      connectionUrl:
          'https://p2p.example/home?intent=p2p&role=viewer'
          '&host=host&public=1',
      slotPda: 'slot',
      awaitAnswerSdp: () async => '{}',
      confirm: () async => confirmations += 1,
      cancelWaiting: () {},
      teardown: () async {},
    );

    await Future.wait([session.confirm(), session.confirm()]);

    expect(confirmations, 1);
  });

  test('shares one answer wait across concurrent callers', () async {
    var waits = 0;
    final session = PeerHostSession(
      connectionUrl:
          'https://p2p.example/home?intent=p2p&role=viewer'
          '&host=host&public=1',
      slotPda: 'slot',
      awaitAnswerSdp: () async {
        waits += 1;

        return '{}';
      },
      confirm: () async {},
      cancelWaiting: () {},
      teardown: () async {},
    );

    await Future.wait([session.awaitAnswerSdp(), session.awaitAnswerSdp()]);

    expect(waits, 1);
  });
}
