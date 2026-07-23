/// Indicates that independently read signaling accounts disagree.
final class SignalingStateIntegrityException implements Exception {
  const SignalingStateIntegrityException();

  @override
  String toString() => 'Signaling state failed integrity validation.';
}
