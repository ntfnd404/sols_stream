import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sols_stream/core/di/app_resource_disposal_exception.dart';
import 'package:sols_stream/core/di/app_resource_disposal_stack.dart';

import '../../helpers/fake_app_dependencies.dart';

void main() {
  test('reports every disposal failure and rethrows the aggregate', () async {
    final firstFailure = StateError('first');
    final secondFailure = ArgumentError('second');
    final reported = <Object>[];
    final stack = AppResourceDisposalStack()
      ..register(Object(), (_) => throw firstFailure)
      ..register(Object(), (_) => throw secondFailure);
    final dependencies = fakeAppDependencies(
      resourceDisposalStack: stack,
      errorReporter: (error, _) => reported.add(error),
    );

    await expectLater(
      dependencies.dispose(),
      throwsA(isA<AppResourceDisposalException>()),
    );
    expect(reported, [secondFailure, firstFailure]);
  });

  test('repeated disposal does not repeat error reporting', () async {
    final resourceFailure = StateError('resource');
    final reported = <Object>[];
    final stack = AppResourceDisposalStack()..register(Object(), (_) => throw resourceFailure);
    final dependencies = fakeAppDependencies(
      resourceDisposalStack: stack,
      errorReporter: (error, _) => reported.add(error),
    );

    final first = dependencies.dispose();
    final second = dependencies.dispose();

    expect(identical(first, second), isTrue);
    await expectLater(first, throwsA(isA<AppResourceDisposalException>()));
    expect(reported, [resourceFailure]);
  });

  test('reporter failures reach the zone without replacing disposal failure', () async {
    final resourceFailure = StateError('resource');
    final reporterFailure = StateError('reporter');
    final zoneErrors = <Object>[];
    final stack = AppResourceDisposalStack()..register(Object(), (_) => throw resourceFailure);
    final dependencies = fakeAppDependencies(
      resourceDisposalStack: stack,
      errorReporter: (_, _) => throw reporterFailure,
    );

    final run = runZonedGuarded(
      () async {
        await expectLater(
          dependencies.dispose(),
          throwsA(
            isA<AppResourceDisposalException>().having(
              (error) => error.failures.single.error,
              'resource failure',
              same(resourceFailure),
            ),
          ),
        );
      },
      (error, _) => zoneErrors.add(error),
    );
    if (run == null) {
      fail('Guarded zone did not return the test future.');
    }
    await run;

    expect(zoneErrors, [reporterFailure]);
  });
}
