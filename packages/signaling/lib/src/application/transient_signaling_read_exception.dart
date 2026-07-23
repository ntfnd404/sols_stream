/// A temporary infrastructure failure while reading signaling state.
///
/// Provider adapters may use this marker when retrying the read is safe.
/// Integrity, decoding, and programming failures must retain their original
/// exception type so the application does not mask them as polling timeouts.
final class TransientSignalingReadException implements Exception {
  const TransientSignalingReadException();

  @override
  String toString() => 'TransientSignalingReadException';
}
