/// A terminal infrastructure failure while reading signaling state.
///
/// Provider adapters use this exception when a read must not be retried and
/// the provider failure cannot safely cross the package boundary.
final class SignalingReadFailureException implements Exception {
  const SignalingReadFailureException();

  @override
  String toString() => 'SignalingReadFailureException';
}
