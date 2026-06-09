import 'dart:async';

import 'package:action_bloc/action_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/plain_bloc_observer.dart';
import 'fakes/spy_action_bloc_observer.dart';
import 'stubs/stub_action_bloc.dart';

void main() {
  group('ActionBlocMixin', () {
    late StubActionBloc bloc;
    late BlocObserver previousObserver;

    setUp(() {
      previousObserver = Bloc.observer;
      bloc = StubActionBloc();
    });

    tearDown(() async {
      Bloc.observer = previousObserver;
      if (!bloc.isClosed) await bloc.close();
    });

    test('emitAction delivers action to stream subscriber', () async {
      final received = <String>[];
      bloc.actionStream.listen(received.add);

      bloc.emitAction('hello');
      await Future<void>.delayed(Duration.zero);

      expect(received, ['hello']);
    });

    test('emitAction after close() is a no-op', () async {
      final received = <String>[];
      bloc.actionStream.listen(received.add);

      await bloc.close();
      bloc.emitAction('should not arrive');
      await Future<void>.delayed(Duration.zero);

      expect(received, isEmpty);
    });

    test('delivers multiple actions in order (FIFO)', () async {
      final received = <String>[];
      bloc.actionStream.listen(received.add);

      bloc
        ..emitAction('a')
        ..emitAction('b')
        ..emitAction('c');
      await Future<void>.delayed(Duration.zero);

      expect(received, ['a', 'b', 'c']);
    });

    test('emitAction with a non-action BlocObserver does not throw', () async {
      Bloc.observer = PlainBlocObserver();
      final received = <String>[];
      bloc.actionStream.listen(received.add);

      bloc.emitAction('ok');
      await Future<void>.delayed(Duration.zero);

      expect(received, ['ok']);
    });

    test('broadcast: two subscribers each receive independently', () async {
      final a = <String>[];
      final b = <String>[];
      bloc.actionStream.listen(a.add);
      bloc.actionStream.listen(b.add);

      bloc.emitAction('ping');
      await Future<void>.delayed(Duration.zero);

      expect(a, ['ping']);
      expect(b, ['ping']);
    });

    test('late subscriber does not receive past action', () async {
      bloc.emitAction('past');
      await Future<void>.delayed(Duration.zero);

      final received = <String>[];
      bloc.actionStream.listen(received.add);
      await Future<void>.delayed(Duration.zero);

      expect(received, isEmpty);
    });

    test('emitAction notifies registered action observer', () async {
      final observer = SpyActionBlocObserver();
      Bloc.observer = observer;

      bloc.emitAction('hello');
      await Future<void>.delayed(Duration.zero);

      expect(observer.records, [
        (bloc: bloc, change: const ActionChange<Object?>(current: 'hello')),
      ]);
    });

    test('emitAction reports previous action to observer', () async {
      final observer = SpyActionBlocObserver();
      Bloc.observer = observer;

      bloc
        ..emitAction('first')
        ..emitAction('second');
      await Future<void>.delayed(Duration.zero);

      expect(observer.records, [
        (bloc: bloc, change: const ActionChange<Object?>(current: 'first')),
        (
          bloc: bloc,
          change: const ActionChange<Object?>(previous: 'first', current: 'second'),
        ),
      ]);
    });

    test('close() completes the stream', () async {
      final done = Completer<void>();
      bloc.actionStream.listen((_) {}, onDone: done.complete);

      await bloc.close();

      expect(done.isCompleted, isTrue);
    });
  });
}

