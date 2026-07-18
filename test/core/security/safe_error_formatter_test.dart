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

final class _ThrowingStackTrace implements StackTrace {
  @override
  String toString() => throw StateError('stack must not be rendered');
}

final class _DiagnosticComponent {}

void main() {
  test('development diagnostics include typed context and stack trace', () {
    final stackTrace = StackTrace.fromString('safe stack');
    const formatter = SafeErrorFormatter(detail: SafeDiagnosticDetail.development);

    final result = formatter.format(
      _SensitiveFailure(),
      context: SafeDiagnosticContext.walletBalance,
      stackTrace: stackTrace,
    );

    expect(result, 'WALLET-READ-001 Wallet balance: _SensitiveFailure\nsafe stack');
    expect(result, isNot(contains('secret')));
    expect(result, isNot(contains('rpc.example')));
    expect(result, isNot(contains('response-body')));
  });

  test('never invokes the untrusted error toString', () {
    const formatter = SafeErrorFormatter(detail: SafeDiagnosticDetail.development);

    expect(
      formatter.format(
        _ThrowingToStringFailure(),
        context: SafeDiagnosticContext.rootZone,
      ),
      'APP-ROOT-001 Root zone: _ThrowingToStringFailure',
    );
  });

  test('development diagnostics identify a typed component', () {
    const formatter = SafeErrorFormatter(detail: SafeDiagnosticDetail.development);

    final result = formatter.format(
      _SensitiveFailure(),
      context: SafeDiagnosticContext.blocObserver,
      componentType: _DiagnosticComponent,
    );

    expect(result, 'APP-BLOC-001 BLoC component=_DiagnosticComponent: _SensitiveFailure');
  });

  test('release diagnostics do not render error, component, or stack trace', () {
    const formatter = SafeErrorFormatter(detail: SafeDiagnosticDetail.release);

    final result = formatter.format(
      _ThrowingToStringFailure(),
      context: SafeDiagnosticContext.rootZone,
      componentType: _DiagnosticComponent,
      stackTrace: _ThrowingStackTrace(),
    );

    expect(result, 'APP-ROOT-001 Root zone');
  });

  test('diagnostic context codes are unique', () {
    final codes = SafeDiagnosticContext.values.map((context) => context.code).toList();

    expect(codes.toSet(), hasLength(codes.length));
  });
}
