import 'package:signaling/signaling.dart';
import 'package:solana/solana.dart' show Ed25519HDPublicKey;
import 'package:test/test.dart';

import 'fakes/fake_account.dart';
import 'fakes/fake_codec.dart';
import 'fakes/go_live_gateway.dart';
import 'fakes/recording_reclaim_gateway.dart';

SolanaSignaling _signaling(SignalingReclaimGateway reclaim) => SolanaSignaling(
      chain: GoLiveGateway(),
      codec: FakeCodec(),
      account: FakeAccount(publicKey: Ed25519HDPublicKey(List<int>.filled(32, 9))),
      reclaim: reclaim,
    );

const _session = SignalingSession(
  url: 'sols://connect',
  roomPda: 'ROOM',
  slotPda: 'SLOT',
  prot: 'PROT',
  slotNonce: 2,
  roomNonce: 1,
);

const _offer = FetchedOffer(
  sdpOffer: 'OFFER',
  slotPda: 'VIEWER_SLOT',
  roomPda: 'ROOM',
  prot: 'PROT',
  slotNonce: 2,
);

void main() {
  group('SolanaSignaling.stopAndReclaim (host)', () {
    test('closes the slot, then ends, then closes the room (Q3 order)', () async {
      final reclaim = RecordingReclaimGateway();

      await _signaling(reclaim).stopAndReclaim(_session);

      expect(reclaim.closedSlots, [(slotPda: 'SLOT', viewer: null)]);
      expect(reclaim.endedRooms, ['ROOM']);
      expect(reclaim.closedRooms, ['ROOM']);
      expect(reclaim.calls, ['closeConnectSlot:SLOT', 'endRoom:ROOM', 'closeRoom:ROOM']);
    });

    test('a failing slot close does not abort end_room / close_room', () async {
      final reclaim = RecordingReclaimGateway(throwOnCloseConnectSlot: StateError('boom'));

      await _signaling(reclaim).stopAndReclaim(_session);

      // The slot close was attempted and the room steps still ran.
      expect(reclaim.calls, ['closeConnectSlot:SLOT', 'endRoom:ROOM', 'closeRoom:ROOM']);
    });

    test('a failing end_room does not abort close_room', () async {
      final reclaim = RecordingReclaimGateway(throwOnEndRoom: StateError('boom'));

      await _signaling(reclaim).stopAndReclaim(_session);

      expect(reclaim.closedRooms, ['ROOM']);
    });

    test('never throws even when every step fails', () async {
      final reclaim = RecordingReclaimGateway(
        throwOnCloseConnectSlot: StateError('a'),
        throwOnEndRoom: StateError('b'),
        throwOnCloseRoom: StateError('c'),
      );

      await expectLater(_signaling(reclaim).stopAndReclaim(_session), completes);
      expect(reclaim.calls, ['closeConnectSlot:SLOT', 'endRoom:ROOM', 'closeRoom:ROOM']);
    });
  });

  group('SolanaSignaling.leaveAndReclaim (viewer)', () {
    test('closes only the viewer slot and issues no room ops', () async {
      final reclaim = RecordingReclaimGateway();

      await _signaling(reclaim).leaveAndReclaim(_offer);

      expect(reclaim.closedSlots, [(slotPda: 'VIEWER_SLOT', viewer: null)]);
      expect(reclaim.endedRooms, isEmpty);
      expect(reclaim.closedRooms, isEmpty);
    });

    test('never throws when the slot close fails', () async {
      final reclaim = RecordingReclaimGateway(throwOnCloseConnectSlot: StateError('boom'));

      await expectLater(_signaling(reclaim).leaveAndReclaim(_offer), completes);
      expect(reclaim.calls, ['closeConnectSlot:VIEWER_SLOT']);
    });
  });
}
