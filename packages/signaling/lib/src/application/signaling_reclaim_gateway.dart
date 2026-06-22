/// Port for reclaiming on-chain deposits left by a slot/room — the
/// `close_connect_slot` / `end_room` / `close_room` instructions of the
/// sols.stream signaling program.
///
/// Segregated from `SignalingChainGateway` (ISP): reclaim is a distinct
/// capability with a money-moving trust boundary (the program skims a mandated
/// 1% to the on-chain service wallet and refunds the rest pro-rata). The default
/// binding is [UnsupportedSignalingReclaimGateway] (Null Object); the real
/// Solana implementation is wired in `SignalingAssembly`.
///
/// Every method is **best-effort and idempotent**: an already-closed/absent
/// account completes without throwing, so callers can run reclaim
/// unconditionally on teardown without leaking exceptions. A residual deposit
/// (e.g. config unreadable, transient RPC) is left for the program's passive
/// `cleanup_*` fallback rather than surfaced as an error.
abstract interface class SignalingReclaimGateway {
  /// Closes a connect slot (`close_connect_slot`): the program skims 1% to the
  /// service wallet and refunds the rest to host + viewer.
  ///
  /// [viewer] is the on-chain viewer's base58 pubkey, or `null` when the slot is
  /// unclaimed — in which case the implementation substitutes the host as the
  /// refund placeholder (matching the web client). The `host` is the signer and
  /// the service wallet is resolved on-chain by the implementation; neither is a
  /// call-surface parameter (a caller must never be able to redirect the skim).
  ///
  /// `close_connect_slot` takes no room account, so [roomPda] is intentionally
  /// not a parameter (see `reference/program-client.js`).
  Future<void> closeConnectSlot({
    required String slotPda,
    String? viewer,
  });

  /// Marks the room not-live (`end_room`). Idempotent on already-ended rooms.
  /// Must precede [closeRoom]. Only the host may call this.
  Future<void> endRoom({required String roomPda});

  /// Reclaims room rent to the host (`close_room`). Must run after [endRoom] and
  /// after every slot is closed. Idempotent on already-closed rooms.
  Future<void> closeRoom({required String roomPda});
}

/// Null Object binding: reclaim disabled. Calls are no-ops so the compensation
/// path in the application layer can run unconditionally without leaking
/// exceptions; the residual deposit is left for the on-chain `cleanup_*`
/// fallback. Used until a real [SignalingReclaimGateway] is wired.
final class UnsupportedSignalingReclaimGateway implements SignalingReclaimGateway {
  const UnsupportedSignalingReclaimGateway();

  @override
  Future<void> closeConnectSlot({required String slotPda, String? viewer}) async {}

  @override
  Future<void> endRoom({required String roomPda}) async {}

  @override
  Future<void> closeRoom({required String roomPda}) async {}
}
