import 'package:signaling/signaling.dart';
import 'package:solana/solana.dart' show Ed25519HDPublicKey;
import 'package:test/test.dart';

import 'fakes/fake_account.dart';
import 'fakes/fake_codec.dart';
import 'fakes/go_live_gateway.dart';
import 'fakes/recording_reclaim_gateway.dart';

SolanaSignaling _signaling(
  GoLiveGateway gateway,
  SignalingReclaimGateway reclaim,
) => SolanaSignaling(
  chain: gateway,
  codec: FakeCodec(),
  account: FakeAccount(publicKey: Ed25519HDPublicKey(List<int>.filled(32, 9))),
  reclaim: reclaim,
);

void main() {
  group('SolanaSignaling.goLive', () {
    test('produces a sols:// session URL on the happy path', () async {
      final reclaim = RecordingReclaimGateway();
      final session = await _signaling(GoLiveGateway(), reclaim).goLive('OFFER');

      expect(session.url, startsWith('sols://connect'));
      expect(session.roomPda, 'ROOM');
      expect(session.slotPda, 'SLOT');
      expect(reclaim.closedSlots, isEmpty);
      expect(reclaim.closedRooms, isEmpty);
    });

    test('compensates by reclaiming deposits when the offer write fails', () async {
      final reclaim = RecordingReclaimGateway();
      final signaling = _signaling(
        GoLiveGateway(failWriteOffer: true),
        reclaim,
      );

      await expectLater(signaling.goLive('OFFER'), throwsA(isA<StateError>()));
      expect(reclaim.closedSlots, ['SLOT']);
      expect(reclaim.closedRooms, ['ROOM']);
    });
  });
}
