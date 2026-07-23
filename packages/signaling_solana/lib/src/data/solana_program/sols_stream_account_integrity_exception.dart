final class SolsStreamAccountIntegrityException implements Exception {
  final String accountName;
  final String message;

  const SolsStreamAccountIntegrityException({
    required this.accountName,
    required this.message,
  });

  @override
  String toString() => '$accountName account integrity failure: $message';
}
