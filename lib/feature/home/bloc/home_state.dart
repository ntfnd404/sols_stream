part of 'home_bloc.dart';

@immutable
final class HomeState {
  final TransportMode transportMode;
  final WebRtcRole webRtcRole;
  final SessionMode sessionMode;

  @override
  int get hashCode => Object.hash(transportMode, webRtcRole, sessionMode);

  const HomeState({
    this.transportMode = TransportMode.webrtc,
    this.webRtcRole = WebRtcRole.publisher,
    this.sessionMode = SessionMode.p2p,
  });

  HomeState copyWith({
    TransportMode? transportMode,
    WebRtcRole? webRtcRole,
    SessionMode? sessionMode,
  }) => HomeState(
    transportMode: transportMode ?? this.transportMode,
    webRtcRole: webRtcRole ?? this.webRtcRole,
    sessionMode: sessionMode ?? this.sessionMode,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeState &&
          transportMode == other.transportMode &&
          webRtcRole == other.webRtcRole &&
          sessionMode == other.sessionMode;
}
