import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sols_stream/core/event_bus/app_event.dart';
import 'package:sols_stream/core/event_bus/app_event_bus.dart';

void main() {
  test('delivers events asynchronously and in order per subscription', () async {
    final eventBus = AppEventBus();
    final received = <AppEvent>[];
    const first = _TestAppEvent(1);
    const second = _TestAppEvent(2);
    final subscription = eventBus.on<_TestAppEvent>().listen(received.add);

    eventBus
      ..emit(first)
      ..emit(second);
    expect(received, isEmpty);

    await Future<void>.delayed(Duration.zero);
    expect(received, [first, second]);

    await subscription.cancel();
    await eventBus.dispose();
  });

  test('does not replay events emitted before subscription', () async {
    final eventBus = AppEventBus();
    eventBus.emit(const _TestAppEvent(1));
    await Future<void>.delayed(Duration.zero);

    final received = <_TestAppEvent>[];
    final subscription = eventBus.on<_TestAppEvent>().listen(received.add);
    await Future<void>.delayed(Duration.zero);

    expect(received, isEmpty);
    await subscription.cancel();
    await eventBus.dispose();
  });

  test('cancelled subscriber receives no later events', () async {
    final eventBus = AppEventBus();
    final received = <_TestAppEvent>[];
    final subscription = eventBus.on<_TestAppEvent>().listen(received.add);
    await subscription.cancel();

    eventBus.emit(const _TestAppEvent(1));
    await Future<void>.delayed(Duration.zero);

    expect(received, isEmpty);
    await eventBus.dispose();
  });

  test('listener failure reaches its zone without stopping other subscribers', () async {
    final eventBus = AppEventBus();
    final failures = <Object>[];
    final received = <_TestAppEvent>[];

    await runZonedGuarded(
      () async {
        final failingSubscription = eventBus.on<_TestAppEvent>().listen(
          (_) => throw StateError('listener failed'),
        );
        final healthySubscription = eventBus.on<_TestAppEvent>().listen(received.add);

        eventBus.emit(const _TestAppEvent(1));
        await Future<void>.delayed(Duration.zero);

        await failingSubscription.cancel();
        await healthySubscription.cancel();
      },
      (error, _) => failures.add(error),
    );

    expect(failures, [isA<StateError>()]);
    expect(received, [const _TestAppEvent(1)]);
    await eventBus.dispose();
  });

  test('owner can dispose after cancelling a paused subscriber', () async {
    final eventBus = AppEventBus();
    final subscription = eventBus.on<_TestAppEvent>().listen((_) {})..pause();

    await subscription.cancel();
    await eventBus.dispose();

    expect(() => eventBus.emit(const _TestAppEvent(1)), throwsStateError);
  });

  test('dispose waits until the broadcast controller closes', () async {
    final eventBus = AppEventBus();
    var streamDone = false;
    final subscription = eventBus.on<AppEvent>().listen(
      (_) {},
      onDone: () => streamDone = true,
    );

    await eventBus.dispose();

    expect(streamDone, isTrue);
    await subscription.cancel();
  });

  test('emit after dispose throws StateError', () async {
    final eventBus = AppEventBus();
    await eventBus.dispose();

    expect(() => eventBus.emit(const _TestAppEvent(1)), throwsStateError);
  });
}

// ignore: prefer-match-file-name
final class _TestAppEvent extends AppEvent {
  final int sequence;

  const _TestAppEvent(this.sequence);
}
