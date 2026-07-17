/// Controls the timing of slot-polling loops.
abstract interface class SlotPollingScheduler {
  /// Maximum poll attempts when waiting for an offer to appear.
  int get maxOfferAttempts;

  /// Maximum poll attempts when waiting for an answer to appear.
  int get maxAnswerAttempts;

  /// Waits one polling cycle before the next slot read.
  Future<void> tick();
}

/// Waits 5 seconds between slot reads. The host waits for a viewer to answer
/// effectively indefinitely (bounded only by the on-chain slot expiry, not by
/// a local attempt count) — there is no reason to give up locally on a host
/// who simply hasn't shared the link yet. Waiting for the host's offer stays
/// capped at 24 attempts (~2 min): the host is expected to respond promptly
/// once a viewer has claimed the slot.
final class DefaultSlotPollingScheduler implements SlotPollingScheduler {
  static const Duration _interval = Duration(seconds: 5);
  static const int _maxOfferAttempts = 24;
  static const int _maxAnswerAttempts = 1 << 30;

  @override
  int get maxOfferAttempts => _maxOfferAttempts;

  @override
  int get maxAnswerAttempts => _maxAnswerAttempts;

  const DefaultSlotPollingScheduler();

  @override
  Future<void> tick() => Future.delayed(_interval);
}
