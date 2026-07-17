import 'package:flutter_test/flutter_test.dart';
import 'package:sols_stream/core/security/safe_error_formatter.dart';

final class _SensitiveFailure implements Exception {
  @override
  String toString() => 'https://rpc.example/?token=secret response-body';
}

final class _ThrowingToStringFailure implements Exception {
  @override
  String toString() => throw StateError('must not be called');
}

void main() {
  test('formats only context, runtime type, and stack trace', () {
    final stackTrace = StackTrace.fromString('safe stack');

    final result = formatSafeError(
      _SensitiveFailure(),
      context: 'Wallet read',
      stackTrace: stackTrace,
    );

    expect(result, 'Wallet read: _SensitiveFailure\nsafe stack');
    expect(result, isNot(contains('secret')));
    expect(result, isNot(contains('rpc.example')));
    expect(result, isNot(contains('response-body')));
  });

  test('never invokes the untrusted error toString', () {
    expect(
      formatSafeError(_ThrowingToStringFailure()),
      '_ThrowingToStringFailure',
    );
  });
}
