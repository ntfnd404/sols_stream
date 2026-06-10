/// Cryptographic parameters for the AES-GCM/PBKDF2 signal payload protocol.
abstract final class SignalCryptoConstants {
  /// AES-GCM authentication tag length, in bytes (128-bit MAC).
  static const int gcmTagLength = 16;

  /// PBKDF2 iteration count for key derivation. Matches the JS implementation.
  static const int pbkdf2Iterations = 150000;

  /// Derived AES-GCM key length, in bits (AES-256).
  static const int derivedKeyBits = 256;

  /// Suffix appended to the slot nonce to form the PBKDF2 salt.
  static const String saltSuffix = '|signal';
}
