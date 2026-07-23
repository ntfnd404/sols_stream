import 'package:signaling/signaling.dart';
import 'package:signaling/src/data/local_key_broker_gateway.dart';
import 'package:test/test.dart';

void main() {
  test('round-trips a capability across separate local broker instances', () async {
    final now = DateTime.utc(2026, 6, 28);
    final hostBroker = LocalKeyBrokerGateway(now: () => now);
    final viewerBroker = LocalKeyBrokerGateway(now: () => now);

    final protectedKey = await hostBroker.protect(
      passphrase: 'local-passphrase',
      hostAddress: 'host',
      offerId: 'slot',
    );
    final passphrase = await viewerBroker.unprotect(
      protectedKey: protectedKey,
      hostAddress: 'host',
      offerId: 'slot',
      slotPda: 'slot',
    );

    expect(passphrase, 'local-passphrase');
  });

  test('rejects an envelope for a different slot', () async {
    final broker = LocalKeyBrokerGateway();
    final protectedKey = await broker.protect(
      passphrase: 'local-passphrase',
      hostAddress: 'host',
      offerId: 'slot',
    );

    await expectLater(
      broker.unprotect(
        protectedKey: protectedKey,
        hostAddress: 'host',
        offerId: 'other-slot',
      ),
      throwsA(isA<KeyBrokerException>()),
    );
  });

  test('rejects an expired envelope without exposing its content', () async {
    var now = DateTime.utc(2026, 6, 28);
    final broker = LocalKeyBrokerGateway(now: () => now);
    final protectedKey = await broker.protect(
      passphrase: 'secret-passphrase',
      hostAddress: 'host',
      offerId: 'slot',
      ttl: const Duration(milliseconds: 1),
    );
    now = now.add(const Duration(milliseconds: 2));

    await expectLater(
      broker.unprotect(
        protectedKey: protectedKey,
        hostAddress: 'host',
        offerId: 'slot',
      ),
      throwsA(
        isA<KeyBrokerException>().having(
          (error) => error.toString(),
          'message',
          isNot(contains('secret-passphrase')),
        ),
      ),
    );
  });
}
