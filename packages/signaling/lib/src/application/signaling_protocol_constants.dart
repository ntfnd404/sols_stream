/// Protocol field sizes shared by signaling application services.
abstract final class SignalingProtocolConstants {
  /// Source byte length for a nonce that remains exact on every Dart platform.
  ///
  /// The on-chain field is u64, so every generated value remains valid.
  static const int nonceByteLength = 7;
}
