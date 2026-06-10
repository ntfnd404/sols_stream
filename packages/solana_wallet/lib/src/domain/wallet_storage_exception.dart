/// Thrown when wallet key material cannot be read, written, or decoded.
///
/// Wraps lower-level storage failures (e.g. `SecureStorageException`) so callers
/// receive a wallet-domain type and never see secret-bearing platform details.
/// A present-but-undecodable key throws this rather than silently regenerating
/// a new identity (which would abandon the user's funded account).
final class WalletStorageException implements Exception {
  /// Human-readable, secret-free description of the failure.
  final String message;

  const WalletStorageException(this.message);

  @override
  String toString() => 'WalletStorageException: $message';
}
