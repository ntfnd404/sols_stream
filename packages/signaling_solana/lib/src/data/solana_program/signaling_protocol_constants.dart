/// Application-owned signaling protocol defaults and limits.
abstract final class SignalingProtocolConstants {
  static const int depositLamports = 1000000;
  static const int expiresInSec = 120;
  static const int chunkSize = 800;
  static const String defaultNickname = 'sols.stream';
}
