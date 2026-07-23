import 'package:signaling/src/application/peer_slot_access.dart';
import 'package:signaling/src/domain/connect_slot_data.dart';
import 'package:signaling/src/domain/connect_slot_state.dart';

/// Classifies whether [slot] can be entered or resumed by [viewerPublicKey].
PeerSlotAccess classifyPeerSlotAccess({
  required ConnectSlotData slot,
  required List<int> viewerPublicKey,
  required BigInt nowSeconds,
  required int minimumTtlSeconds,
}) {
  final ownedByViewer = _sameBytes(slot.viewer, viewerPublicKey);
  final ttl = slot.expiresAt - nowSeconds;
  final viable = ttl >= BigInt.from(minimumTtlSeconds) && slot.hostDeposit > BigInt.zero;
  if (!viable) return PeerSlotAccess.unavailable;

  if (slot.state == ConnectSlotState.open) {
    return slot.viewer.every((byte) => byte == 0) ? PeerSlotAccess.joinable : PeerSlotAccess.unavailable;
  }

  final claimedState =
      slot.state == ConnectSlotState.claimed ||
      slot.state == ConnectSlotState.offerReady ||
      slot.state == ConnectSlotState.answerReady ||
      slot.state == ConnectSlotState.connected;
  if (!claimedState) return PeerSlotAccess.unavailable;
  if (!ownedByViewer) {
    return PeerSlotAccess.claimedByAnotherViewer;
  }

  final resumableState = slot.state == ConnectSlotState.claimed || slot.state == ConnectSlotState.offerReady;

  return resumableState ? PeerSlotAccess.joinable : PeerSlotAccess.unavailable;
}

bool _sameBytes(List<int> first, List<int> second) {
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) return false;
  }

  return true;
}
