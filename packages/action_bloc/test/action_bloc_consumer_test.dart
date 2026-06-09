import 'package:action_bloc/action_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'stubs/emitting_action_bloc.dart';
import 'stubs/stub_action_bloc.dart';

void main() {
  group('ActionBlocConsumer', () {
    testWidgets('actionListener fires on action', (tester) async {
      final bloc = StubActionBloc();
      addTearDown(bloc.close);
      final received = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: ActionBlocConsumer<StubActionBloc, int, String>(
              actionListener: (_, action) => received.add(action),
              builder: (_, state) => Text('$state'),
            ),
          ),
        ),
      );

      bloc.emitAction('hello');
      await tester.pump();

      expect(received, ['hello']);
    });

    testWidgets('stateListener fires on state change', (tester) async {
      final bloc = StubActionBloc();
      addTearDown(bloc.close);
      final states = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: ActionBlocConsumer<StubActionBloc, int, String>(
              stateListener: (_, state) => states.add(state),
              builder: (_, state) => Text('count:$state'),
            ),
          ),
        ),
      );

      bloc.add(Object());
      await tester.pump();

      expect(states, [1]);
    });

    testWidgets('builder rebuilds on state change', (tester) async {
      final bloc = StubActionBloc();
      addTearDown(bloc.close);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: ActionBlocConsumer<StubActionBloc, int, String>(
              builder: (_, state) => Text('count:$state'),
            ),
          ),
        ),
      );

      expect(find.text('count:0'), findsOneWidget);

      bloc.add(Object());
      await tester.pump();

      expect(find.text('count:1'), findsOneWidget);
    });

    testWidgets('actionListenWhen filters actions', (tester) async {
      final bloc = StubActionBloc();
      addTearDown(bloc.close);
      final received = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: ActionBlocConsumer<StubActionBloc, int, String>(
              actionListenWhen: (_, current) => current != 'skip',
              actionListener: (_, action) => received.add(action),
              builder: (_, state) => Text('$state'),
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

    testWidgets('actionListenWhen receives previous and current', (tester) async {
      final bloc = StubActionBloc();
      addTearDown(bloc.close);
      final received = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: ActionBlocConsumer<StubActionBloc, int, String>(
              actionListenWhen: (previous, current) => previous != current,
              actionListener: (_, action) => received.add(action),
              builder: (_, state) => Text('$state'),
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

    testWidgets('buildWhen false suppresses rebuild', (tester) async {
      final bloc = StubActionBloc();
      addTearDown(bloc.close);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: ActionBlocConsumer<StubActionBloc, int, String>(
              buildWhen: (_, _) => false,
              builder: (_, state) => Text('count:$state'),
            ),
          ),
        ),
      );

      expect(find.text('count:0'), findsOneWidget);

      bloc.add(Object());
      await tester.pump();

      expect(find.text('count:0'), findsOneWidget);
    });

    testWidgets('stateListenWhen false suppresses stateListener', (tester) async {
      final bloc = StubActionBloc();
      addTearDown(bloc.close);
      final states = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: ActionBlocConsumer<StubActionBloc, int, String>(
              stateListenWhen: (_, _) => false,
              stateListener: (_, state) => states.add(state),
              builder: (_, state) => Text('$state'),
            ),
          ),
        ),
      );

      bloc.add(Object());
      await tester.pump();

      expect(states, isEmpty);
    });

    testWidgets('builder, stateListener and actionListener all fire together', (tester) async {
      final bloc = EmittingActionBloc();
      addTearDown(bloc.close);
      final states = <int>[];
      final actions = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: ActionBlocConsumer<EmittingActionBloc, int, String>(
              stateListener: (_, state) => states.add(state),
              actionListener: (_, action) => actions.add(action),
              builder: (_, state) => Text('count:$state'),
            ),
          ),
        ),
      );

      bloc.add('go');
      await tester.pump();

      expect(find.text('count:1'), findsOneWidget);
      expect(states, [1]);
      expect(actions, ['go']);
    });

    testWidgets('uses explicit bloc without a provider', (tester) async {
      final bloc = StubActionBloc();
      addTearDown(bloc.close);
      final received = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: ActionBlocConsumer<StubActionBloc, int, String>(
            bloc: bloc,
            actionListener: (_, action) => received.add(action),
            builder: (_, state) => Text('$state'),
          ),
        ),
      );

      bloc.emitAction('x');
      await tester.pump();

      expect(received, ['x']);
    });
  });
}
