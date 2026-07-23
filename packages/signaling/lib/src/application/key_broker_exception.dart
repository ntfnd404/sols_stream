/// A sanitized key-broker failure safe to expose in diagnostics.
final class KeyBrokerException implements Exception {
  final String operation;
  final int? statusCode;
  final String reason;

  const KeyBrokerException({
    required this.operation,
    this.statusCode,
    this.reason = 'request failed',
  });

  @override
  String toString() {
    final status = statusCode == null ? '' : ' (status=$statusCode)';

    return 'KeyBrokerException: $operation $reason$status';
  }
}
