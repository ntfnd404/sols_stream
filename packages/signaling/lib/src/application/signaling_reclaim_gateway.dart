/// Port for reclaiming on-chain deposits left by a slot/room that will never be
/// used (e.g. `goLive` failed after the deposits landed, or a session expired).
///
/// Segregated from `SignalingChainGateway` (ISP): reclaim is a distinct
/// capability that most callers never need, and whose on-chain shape depends on
/// the program IDL — which the client does not yet have. The default binding is
/// [UnsupportedSignalingReclaimGateway] (Null Object); a real implementation is
/// wired once the program's close instructions are known.
///
/// On mainnet the deposits are real money, so the application is structured to
/// call this compensation seam now even though it is a no-op until the IDL lands.
/// If the program turns out to auto-refund on expiry, the Null Object correctly
/// models "nothing to reclaim" and stays the permanent binding.
abstract interface class SignalingReclaimGateway {
  /// Reclaims the slot deposit and closes the slot account at [slotPda].
  Future<void> closeSlot(String slotPda);

  /// Reclaims the room deposit and closes the room account at [roomPda].
  Future<void> closeRoom(String roomPda);
}

/// Null Object binding: reclaim is not yet available (no program IDL). Calls are
/// no-ops so the compensation path in the application layer can run unconditionally
/// without leaking exceptions; the residual deposit is left for the future
/// IDL-backed implementation (or is auto-refunded on-chain at expiry).
final class UnsupportedSignalingReclaimGateway implements SignalingReclaimGateway {
  const UnsupportedSignalingReclaimGateway();

  @override
  Future<void> closeSlot(String slotPda) async {}

  @override
  Future<void> closeRoom(String roomPda) async {}
}
