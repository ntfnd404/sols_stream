part of 'home_bloc.dart';

sealed class HomeEvent {
  const HomeEvent();
}

final class SessionModeChangedEvent extends HomeEvent {
  final SessionMode mode;

  const SessionModeChangedEvent(this.mode);
}

final class TransportModeChangedEvent extends HomeEvent {
  final TransportMode mode;

  const TransportModeChangedEvent(this.mode);
}

final class WebRtcRoleChangedEvent extends HomeEvent {
  final WebRtcRole role;

  const WebRtcRoleChangedEvent(this.role);
}
