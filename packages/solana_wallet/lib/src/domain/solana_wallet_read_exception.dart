/// A sanitized failure produced while reading wallet state from the provider.
final class SolanaWalletReadException implements Exception {
  const SolanaWalletReadException();

  @override
  String toString() => 'SolanaWalletReadException';
}
