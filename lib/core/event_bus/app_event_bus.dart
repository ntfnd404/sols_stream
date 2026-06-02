import 'dart:async';

abstract class DomainEvent {
  const DomainEvent();
}

/// Cross-feature event bus. BLoCs subscribe via [on<T>()].
class AppEventBus {
  AppEventBus._();
  static final instance = AppEventBus._();

  final _controller = StreamController<DomainEvent>.broadcast();

  Stream<T> on<T extends DomainEvent>() =>
      _controller.stream.where((e) => e is T).cast<T>();

  void emit(DomainEvent event) => _controller.add(event);

  void dispose() => _controller.close();
}

// ── Domain events ────────────────────────────────────────────────────────────

class ViewerJoinedEvent extends DomainEvent {
  const ViewerJoinedEvent();
}

class PeerConnectedEvent extends DomainEvent {
  const PeerConnectedEvent();
}

class PeerDisconnectedEvent extends DomainEvent {
  const PeerDisconnectedEvent();
}

class StreamStartedEvent extends DomainEvent {
  final String connectionUrl;
  const StreamStartedEvent(this.connectionUrl);
}
