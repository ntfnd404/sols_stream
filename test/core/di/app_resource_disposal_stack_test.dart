import 'package:flutter_test/flutter_test.dart';
import 'package:sols_stream/core/di/app_resource_disposal_exception.dart';
import 'package:sols_stream/core/di/app_resource_disposal_stack.dart';

void main() {
  test('disposes resources once in reverse creation order', () async {
    final stack = AppResourceDisposalStack();
    final events = <String>[];

    stack
      ..register('first', (resource) => events.add(resource))
      ..register('second', (resource) => events.add(resource));

    await stack.dispose();
    await stack.dispose();

    expect(events, ['second', 'first']);
  });

  test('continues cleanup and preserves every failure', () async {
    final stack = AppResourceDisposalStack();
    final events = <String>[];
    final firstFailure = StateError('first failure');
    final secondFailure = ArgumentError('second failure');

    stack
      ..register('last', (resource) => events.add(resource))
      ..register('first failure', (_) => throw firstFailure)
      ..register('second failure', (_) => throw secondFailure)
      ..register('first', (resource) => events.add(resource));

    final exception = await _captureDisposalException(stack);

    expect(events, ['first', 'last']);
    expect(
      exception.failures.map((failure) => failure.error),
      [secondFailure, firstFailure],
    );
    expect(exception.toString(), 'AppResourceDisposalException(2 failures)');
    expect(exception.toString(), isNot(contains('first failure')));
    expect(
      exception.combinedStackTrace.toString(),
      allOf(
        contains('disposal failure 1: ArgumentError'),
        contains('disposal failure 2: StateError'),
      ),
    );
  });

  test('rejects registration after disposal starts', () async {
    final stack = AppResourceDisposalStack();
    await stack.dispose();

    expect(
      () => stack.register(Object(), (_) {}),
      throwsStateError,
    );
  });

  test('rejects registration from a synchronous disposer', () async {
    final stack = AppResourceDisposalStack();
    var rejected = false;
    stack.register(Object(), (_) {
      try {
        stack.register(Object(), (_) {});
      } on StateError {
        rejected = true;
      }
    });

    await stack.dispose();

    expect(rejected, isTrue);
  });

  test('describes ownership without exposing resources', () {
    final stack = AppResourceDisposalStack()..register('secret-resource', (_) {});

    expect(stack.toString(), 'AppResourceDisposalStack(1 pending)');
    expect(stack.toString(), isNot(contains('secret-resource')));
  });

  test('rejects an empty aggregate disposal exception', () {
    expect(
      () => AppResourceDisposalException(const []),
      throwsArgumentError,
    );
  });
}

Future<AppResourceDisposalException> _captureDisposalException(
  AppResourceDisposalStack stack,
) async {
  try {
    await stack.dispose();
    fail('dispose must throw');
  } on AppResourceDisposalException catch (error) {
    return error;
  }
}
