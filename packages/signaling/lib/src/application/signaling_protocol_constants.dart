/// Polling cadence, timeouts, and protocol field sizes used by the signaling
/// application service's on-chain interactions.
abstract final class SignalingProtocolConstants {
  /// Delay between on-chain slot-state polls.
  static const Duration pollInterval = Duration(seconds: 5);

  /// Number of [pollInterval] ticks `fetchOffer` waits before giving up.
  static const int maxOfferPollAttempts = 24;

  /// Byte length of a random u64 nonce (room/slot nonce).
  static const int nonceByteLength = 8;

  /// Byte length of the random `prot` key embedded in the connection URL.
  static const int protKeyByteLength = 32;

  /// Clears the sign bit of a u64 read as a signed 64-bit integer, keeping
  /// generated nonces within the positive range expected on-chain.
  static const int int64SignBitMask = 0x7FFFFFFFFFFFFFFF;
}
