import 'package:sols_stream/core/event_bus/domain_event.dart';

/// Group of application events related to stream session lifecycle.
///
/// Emitters publish these events when stream setup, viewer presence, or peer
/// connection state changes. Listeners may subscribe to [StreamDomainEvent] for
/// the whole group or to a concrete event type for a narrower reaction.
sealed class StreamDomainEvent extends DomainEvent {
  const StreamDomainEvent();
}

/// Emitted when a viewer joins a stream session.
final class ViewerJoinedEvent extends StreamDomainEvent {
  const ViewerJoinedEvent();
}

/// Emitted when a peer connection reaches the connected state.
final class PeerConnectedEvent extends StreamDomainEvent {
  const PeerConnectedEvent();
}

/// Emitted when a peer connection leaves an active connected state.
final class PeerDisconnectedEvent extends StreamDomainEvent {
  const PeerDisconnectedEvent();
}

/// Emitted after a stream session is created and can be shared.
///
/// Intentionally carries no payload: the shareable `sols://` URL embeds the
/// `prot` capability key (full decrypt/answer access), so it must never travel
/// through the event bus where a logging/analytics observer could capture it.
/// The URL stays local to the publisher screen; consumers needing a safe handle
/// should reference the on-chain slot address instead.
final class StreamStartedEvent extends StreamDomainEvent {
  const StreamStartedEvent();
}
