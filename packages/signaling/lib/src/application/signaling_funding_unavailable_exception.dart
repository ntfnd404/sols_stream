/// The provider adapter could not confirm its configured funding precondition.
///
/// This exception intentionally carries no provider SDK types, raw causes, or
/// retry classification.
final class SignalingFundingUnavailableException implements Exception {
  const SignalingFundingUnavailableException();

  @override
  String toString() => 'SignalingFundingUnavailableException';
}
