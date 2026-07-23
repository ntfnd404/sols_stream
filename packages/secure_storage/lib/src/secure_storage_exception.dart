/// Generic typed exception for [SecureStorage] failures.
///
/// SECURITY: zero-arg, fixed message. Original platform exception details
/// (e.g. `PlatformException.message`, which may echo the storage key or the
/// secret value) are NOT carried. The original cause is preserved only via
/// the stack trace through [Error.throwWithStackTrace].
///
/// Each consumer SHOULD wrap this in its own typed exception at the data
/// layer (e.g. `WalletStorageException`) — this type should not propagate
/// past the boundary that owns the secret.
final class SecureStorageException implements Exception {
  const SecureStorageException();

  @override
  String toString() => 'Secure storage operation failed';
}
