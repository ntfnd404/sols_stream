import 'package:signaling/signaling.dart';

/// Zero-delay scheduler for fast unit tests.
class ImmediatePollingScheduler implements SlotPollingScheduler {
  final int _maxOfferAttempts;
  final int _maxAnswerAttempts;

  @override
  int get maxOfferAttempts => _maxOfferAttempts;

  @override
  int get maxAnswerAttempts => _maxAnswerAttempts;

  const ImmediatePollingScheduler({
    this._maxOfferAttempts = 1,
    this._maxAnswerAttempts = 1,
  });

  @override
  Future<void> tick() async {}
}
