part of 'call_bloc.dart';

sealed class CallEvent {
  const CallEvent();
}

final class ConnectAsViewerRequestedEvent extends CallEvent {
  final String url;
  final Map<String, dynamic> rtcConfiguration;

  const ConnectAsViewerRequestedEvent({
    required this.url,
    required this.rtcConfiguration,
  });
}

final class DisconnectRequestedEvent extends CallEvent {
  const DisconnectRequestedEvent();
}

final class GoLiveRequestedEvent extends CallEvent {
  final Map<String, dynamic> rtcConfiguration;

  const GoLiveRequestedEvent({required this.rtcConfiguration});
}

final class RegenerateInviteRequestedEvent extends CallEvent {
  final Map<String, dynamic> rtcConfiguration;

  const RegenerateInviteRequestedEvent({required this.rtcConfiguration});
}

final class ToggleCameraRequestedEvent extends CallEvent {
  const ToggleCameraRequestedEvent();
}

final class ToggleMicRequestedEvent extends CallEvent {
  const ToggleMicRequestedEvent();
}

final class TogglePipRequestedEvent extends CallEvent {
  final bool show;

  const TogglePipRequestedEvent({required this.show});
}

final class _AnswerSdpReceivedEvent extends CallEvent {
  final String answerJson;

  const _AnswerSdpReceivedEvent(this.answerJson);
}

final class _CallSessionInvalidatedEvent extends CallEvent {
  const _CallSessionInvalidatedEvent();
}

final class _MediaDiagnosticsReceivedEvent extends CallEvent {
  final String message;

  const _MediaDiagnosticsReceivedEvent(this.message);
}

final class _PeerConnectionStateChangedEvent extends CallEvent {
  final RTCPeerConnectionState connectionState;

  const _PeerConnectionStateChangedEvent(this.connectionState);
}

final class _RemoteTrackReceivedEvent extends CallEvent {
  final MediaStream stream;

  const _RemoteTrackReceivedEvent(this.stream);
}

final class _RemoteMediaStateChangedEvent extends CallEvent {
  final RemoteMediaState mediaState;

  const _RemoteMediaStateChangedEvent(this.mediaState);
}

final class _SignalingFailedEvent extends CallEvent {
  final Object error;
  final StackTrace stackTrace;

  const _SignalingFailedEvent(this.error, this.stackTrace);
}
