import 'dart:async';

import 'package:sols_stream/core/event_bus/app_event.dart';

/// In-process broadcast bus for cross-feature application events.
///
/// Event producers publish immutable [AppEvent] objects with [emit], and
/// consumers subscribe to the event type they care about with [on<T>].
///
/// The bus is intentionally a regular object, not a global singleton. Create it
/// in the application's composition root and pass it through dependency
/// injection. The same owner that creates the bus should call [dispose] when the
/// application scope is torn down.
///
/// Subscribers own their subscriptions and must cancel them with the rest of
/// their lifecycle. During application teardown, producers stop first,
/// consumers cancel their subscriptions next, and the application scope owner
/// disposes the bus last. The bus does not force-cancel leaked or paused
/// subscriptions.
///
/// Delivery is asynchronous and ordered per subscription. The bus has no
/// replay, persistence, acknowledgement, or durable buffering. Events emitted
/// before a subscriber listens are lost, and emitting after [dispose] throws a
/// [StateError].
///
/// Listener failures belong to the subscriber's zone and do not stop delivery
/// to other subscribers. The bus does not retry or confirm application-level
/// handling. It must not carry financial outcomes or required workflow
/// transitions.
///
/// Example:
/// ```dart
/// final subscription = eventBus.on<FeatureChangedAppEvent>().listen(...);
/// ```
final class AppEventBus {
  final _controller = StreamController<AppEvent>.broadcast();

  Stream<T> on<T extends AppEvent>() => _controller.stream.where((event) => event is T).cast<T>();

  void emit(AppEvent event) => _controller.add(event);

  Future<void> dispose() => _controller.close();
}
