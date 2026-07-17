import 'dart:typed_data';

import 'package:signaling/signaling.dart';
import 'package:test/test.dart';

void main() {
  final viewer = List<int>.filled(32, 7);
  final otherViewer = List<int>.filled(32, 8);

  test('allows a new viewer to enter an open funded slot', () {
    expect(
      classifyPeerSlotAccess(
        slot: _slot(
          state: ConnectSlotState.open,
          viewer: List<int>.filled(32, 0),
        ),
        viewerPublicKey: viewer,
        nowSeconds: BigInt.from(100),
        minimumTtlSeconds: 30,
      ),
      PeerSlotAccess.joinable,
    );
  });

  test('rejects an inconsistent open slot with a non-zero viewer', () {
    expect(
      classifyPeerSlotAccess(
        slot: _slot(
          state: ConnectSlotState.open,
          viewer: viewer,
        ),
        viewerPublicKey: viewer,
        nowSeconds: BigInt.from(100),
        minimumTtlSeconds: 30,
      ),
      PeerSlotAccess.unavailable,
    );
  });

  for (final state in [
    ConnectSlotState.claimed,
    ConnectSlotState.offerReady,
  ]) {
    test('allows the owning viewer to resume a ${state.name} slot', () {
      expect(
        classifyPeerSlotAccess(
          slot: _slot(
            state: state,
            viewer: viewer,
          ),
          viewerPublicKey: viewer,
          nowSeconds: BigInt.from(100),
          minimumTtlSeconds: 30,
        ),
        PeerSlotAccess.joinable,
      );
    });
  }

  test('classifies an offer-ready slot owned by another viewer as claimed', () {
    expect(
      classifyPeerSlotAccess(
        slot: _slot(
          state: ConnectSlotState.offerReady,
          viewer: otherViewer,
        ),
        viewerPublicKey: viewer,
        nowSeconds: BigInt.from(100),
        minimumTtlSeconds: 30,
      ),
      PeerSlotAccess.claimedByAnotherViewer,
    );
  });

  test('classifies an expired slot as unavailable', () {
    expect(
      classifyPeerSlotAccess(
        slot: _slot(
          state: ConnectSlotState.expired,
          viewer: otherViewer,
        ),
        viewerPublicKey: viewer,
        nowSeconds: BigInt.from(100),
        minimumTtlSeconds: 30,
      ),
      PeerSlotAccess.unavailable,
    );
  });

  test('classifies a connected slot owned by another viewer as claimed', () {
    expect(
      classifyPeerSlotAccess(
        slot: _slot(
          state: ConnectSlotState.connected,
          viewer: otherViewer,
        ),
        viewerPublicKey: viewer,
        nowSeconds: BigInt.from(100),
        minimumTtlSeconds: 30,
      ),
      PeerSlotAccess.claimedByAnotherViewer,
    );
  });
}

ConnectSlotData _slot({
  required ConnectSlotState state,
  required List<int> viewer,
}) => ConnectSlotData(
  room: Uint8List(32),
  host: Uint8List(32),
  viewer: Uint8List.fromList(viewer),
  hostProtectedKey: Uint8List(0),
  viewerProtectedKey: Uint8List(0),
  offerData: Uint8List(0),
  answerData: Uint8List(0),
  state: state,
  createdAt: BigInt.zero,
  expiresAt: BigInt.from(1000),
  hostDeposit: BigInt.one,
  viewerDeposit: BigInt.zero,
  hostRentPaid: BigInt.zero,
  viewerRentPaid: BigInt.zero,
  accessPrice: BigInt.zero,
  hostConfirmed: false,
  viewerConfirmed: false,
);
