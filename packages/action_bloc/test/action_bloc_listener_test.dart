import 'package:action_bloc/action_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_action_bloc.dart';
import 'stubs/emitting_action_bloc.dart';
import 'stubs/stub_action_bloc.dart';
import 'stubs/stub_bloc.dart';

void main() {
  group('ActionBlocListener', () {
    testWidgets('listens to ActionBlocStreamable without requiring mixin', (tester) async {
      final bloc = FakeActionBloc();
      addTearDown(bloc.close);
      final received = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: ActionBlocListener<FakeActionBloc, String>(
              listener: (_, action) => received.add(action),
              child: const SizedBox.shrink(),
            ),
          ),
        ),
      );

      bloc.emitAction('hello');
      await tester.pump();

      expect(received, ['hello']);
    });

    testWidgets('listenWhen returning false suppresses listener call', (tester) async {
      final bloc = StubActionBloc();
      addTearDown(bloc.close);
      final received = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: ActionBlocListener<StubActionBloc, String>(
              listenWhen: (_, current) => current != 'skip',
              listener: (_, action) => received.add(action),
              child: const SizedBox.shrink(),
            ),
          ),
        ),
      );

      bloc.emitAction('pass');
      bloc.emitAction('skip');
      bloc.emitAction('pass');
      await tester.pump();

      expect(received, ['pass', 'pass']);
    });

    testWidgets('listenWhen receives null then prior action as previous', (tester) async {
      final bloc = StubActionBloc();
      addTearDown(bloc.close);
      final seen = <(String?, String)>[];

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: ActionBlocListener<StubActionBloc, String>(
              listenWhen: (previous, current) {
                seen.add((previous, current));

                return true;
              },
              listener: (_, _) {},
              child: const SizedBox.shrink(),
            ),
          ),
        ),
      );

      bloc.emitAction('a');
      bloc.emitAction('b');
      await tester.pump();

      expect(seen, [(null, 'a'), ('a', 'b')]);
    });

    testWidgets('listenWhen can suppress a consecutive duplicate action', (tester) async {
      final bloc = StubActionBloc();
      addTearDown(bloc.close);
      final received = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: ActionBlocListener<StubActionBloc, String>(
              listenWhen: (previous, current) => previous != current,
              listener: (_, action) => received.add(action),
              child: const SizedBox.shrink(),
            ),
          ),
        ),
      );

      bloc.emitAction('x');
      bloc.emitAction('x');
      bloc.emitAction('y');
      await tester.pump();

      expect(received, ['x', 'y']);
    });

    testWidgets('resets previous-action tracking on bloc swap', (tester) async {
      final blocA = StubActionBloc();
      final blocB = StubActionBloc();
      addTearDown(blocA.close);
      addTearDown(blocB.close);
      final seen = <(String?, String)>[];

      Widget build(StubActionBloc bloc) => MaterialApp(
        home: ActionBlocListener<StubActionBloc, String>(
          bloc: bloc,
          listenWhen: (previous, current) {
            seen.add((previous, current));

            return true;
          },
          listener: (_, _) {},
          child: const SizedBox.shrink(),
        ),
      );

      await tester.pumpWidget(build(blocA));
      blocA.emitAction('a1');
      await tester.pump();

      // Swap the bloc → resubscribe → previous resets to null.
      await tester.pumpWidget(build(blocB));
      blocB.emitAction('b1');
      await tester.pump();

      expect(seen, [(null, 'a1'), (null, 'b1')]);
    });

    testWidgets('uses explicit bloc without a provider', (tester) async {
      final bloc = StubActionBloc();
      addTearDown(bloc.close);
      final received = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: ActionBlocListener<StubActionBloc, String>(
            bloc: bloc,
            listener: (_, action) => received.add(action),
            child: const SizedBox.shrink(),
          ),
        ),
      );

      bloc.emitAction('x');
      await tester.pump();

      expect(received, ['x']);
    });

    testWidgets('cancels subscription on dispose', (tester) async {
      final bloc = StubActionBloc();
      addTearDown(bloc.close);
      final received = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: ActionBlocListener<StubActionBloc, String>(
            bloc: bloc,
            listener: (_, action) => received.add(action),
            child: const SizedBox.shrink(),
          ),
        ),
      );

      // Remove the listener from the tree → dispose cancels the subscription.
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      bloc.emitAction('after-dispose');
      await tester.pump();

      expect(received, isEmpty);
    });

    testWidgets('throws StateError when bloc is not ActionBlocStreamable', (tester) async {
      final bloc = StubBloc();
      addTearDown(bloc.close);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: ActionBlocListener<StubBloc, String>(
              listener: (_, _) {},
              child: const SizedBox.shrink(),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isA<StateError>());
    });

    testWidgets('composes inside MultiBlocListener', (tester) async {
      final bloc = StubActionBloc();
      addTearDown(bloc.close);
      final received = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: MultiBlocListener(
              listeners: [
                ActionBlocListener<StubActionBloc, String>(
                  listener: (_, action) => received.add(action),
                ),
              ],
              child: const Text('child-here'),
            ),
          ),
        ),
      );

      expect(find.text('child-here'), findsOneWidget);

      bloc.emitAction('hi');
      await tester.pump();

      expect(received, ['hi']);
    });

    testWidgets('receives an action emitted from a bloc event handler', (tester) async {
      final bloc = EmittingActionBloc();
      addTearDown(bloc.close);
      final received = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: ActionBlocListener<EmittingActionBloc, String>(
              listener: (_, action) => received.add(action),
              child: const SizedBox.shrink(),
            ),
          ),
        ),
      );

      bloc.add('from-handler');
      await tester.pump();

      expect(received, ['from-handler']);
    });

    testWidgets('stays bound to the initial provided bloc across a value swap', (tester) async {
      // Resolution uses context.read (listen: false), so the listener registers
      // no dependency on the provider — a BlocProvider.value swap is not
      // observed and the subscription stays on the originally resolved bloc.
      // This matches flutter_bloc's BlocListener; to switch blocs, pass an
      // explicit `bloc` (see the bloc-swap test above).
      final blocA = StubActionBloc();
      final blocB = StubActionBloc();
      addTearDown(blocA.close);
      addTearDown(blocB.close);
      final received = <String>[];

      Widget build(StubActionBloc bloc) => MaterialApp(
        home: BlocProvider<StubActionBloc>.value(
          value: bloc,
          child: ActionBlocListener<StubActionBloc, String>(
            listener: (_, action) => received.add(action),
            child: const SizedBox.shrink(),
          ),
        ),
      );

      await tester.pumpWidget(build(blocA));
      await tester.pumpWidget(build(blocB));

      blocB.emitAction('on-b');
      blocA.emitAction('on-a');
      await tester.pump();

      expect(received, ['on-a']);
    });
  });
}
