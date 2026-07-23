import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sols_stream/core/di/app_dependencies.dart';
import 'package:sols_stream/core/di/app_resource_disposal_stack.dart';
import 'package:sols_stream/core/di/app_scope.dart';

import '../../helpers/fake_app_dependencies.dart';

void main() {
  testWidgets('provides the application dependencies', (tester) async {
    final dependencies = fakeAppDependencies();
    late AppDependencies resolved;

    await tester.pumpWidget(
      AppScope(
        dependencies: dependencies,
        child: Builder(
          builder: (context) {
            resolved = AppScope.of(context);

            return const SizedBox();
          },
        ),
      ),
    );

    expect(resolved, same(dependencies));
  });

  testWidgets('disposes dependencies when removed', (tester) async {
    var disposeCount = 0;
    final stack = AppResourceDisposalStack()..register(Object(), (_) => disposeCount += 1);
    final dependencies = fakeAppDependencies(resourceDisposalStack: stack);

    await tester.pumpWidget(
      AppScope(
        dependencies: dependencies,
        child: const SizedBox(),
      ),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump();

    expect(disposeCount, 1);
  });

  testWidgets('rejects replacing the dependency graph', (tester) async {
    var firstDisposeCount = 0;
    final first = fakeAppDependencies(
      resourceDisposalStack: AppResourceDisposalStack()..register(Object(), (_) => firstDisposeCount += 1),
    );
    final second = fakeAppDependencies();

    await tester.pumpWidget(
      AppScope(dependencies: first, child: const SizedBox()),
    );
    await tester.pumpWidget(
      AppScope(dependencies: second, child: const SizedBox()),
    );
    expect(tester.takeException(), isA<StateError>());
    expect(firstDisposeCount, 0);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();

    await first.dispose();
    expect(firstDisposeCount, 1);
    await second.dispose();
  });

  testWidgets('does not dispose the same graph during rebuild', (tester) async {
    var disposeCount = 0;
    final dependencies = fakeAppDependencies(
      resourceDisposalStack: AppResourceDisposalStack()..register(Object(), (_) => disposeCount += 1),
    );

    await tester.pumpWidget(
      AppScope(dependencies: dependencies, child: const SizedBox()),
    );
    await tester.pumpWidget(
      AppScope(
        dependencies: dependencies,
        child: const SizedBox(key: ValueKey('updated')),
      ),
    );
    await tester.pump();

    expect(disposeCount, 0);
  });
}
