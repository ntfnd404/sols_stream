part of 'call_bloc.dart';

@immutable
final class CallState {
  final MediaStream? localStream;
  final MediaStream? remoteStream;
  final bool localStreamActive;
  final bool startingLocalMedia;
  final bool remoteVideoAvailable;
  final bool remoteCameraEnabled;
  final bool remoteMicrophoneEnabled;
  final bool showLocalPreviewPip;
  final bool micEnabled;
  final bool cameraEnabled;
  final bool goingLive;
  final bool disconnecting;
  final PeerHostSession? hostSession;
  final bool connecting;
  final bool viewerConnected;
  final PeerOffer? peerOffer;
  final String rtcState;
  final String? status;
  final String? rtcDiagnostics;

  @override
  int get hashCode => Object.hash(
    identityHashCode(localStream),
    identityHashCode(remoteStream),
    localStreamActive,
    startingLocalMedia,
    remoteVideoAvailable,
    remoteCameraEnabled,
    remoteMicrophoneEnabled,
    showLocalPreviewPip,
    micEnabled,
    cameraEnabled,
    goingLive,
    disconnecting,
    identityHashCode(hostSession),
    connecting,
    viewerConnected,
    identityHashCode(peerOffer),
    rtcState,
    status,
    rtcDiagnostics,
  );

  const CallState({
    this.localStream,
    this.remoteStream,
    this.localStreamActive = false,
    this.startingLocalMedia = false,
    this.remoteVideoAvailable = false,
    this.remoteCameraEnabled = true,
    this.remoteMicrophoneEnabled = true,
    this.showLocalPreviewPip = true,
    this.micEnabled = true,
    this.cameraEnabled = true,
    this.goingLive = false,
    this.disconnecting = false,
    this.hostSession,
    this.connecting = false,
    this.viewerConnected = false,
    this.peerOffer,
    this.rtcState = 'Idle',
    this.status,
    this.rtcDiagnostics,
  });

  CallState copyWith({
    MediaStream? Function()? localStream,
    MediaStream? Function()? remoteStream,
    bool? localStreamActive,
    bool? startingLocalMedia,
    bool? remoteVideoAvailable,
    bool? remoteCameraEnabled,
    bool? remoteMicrophoneEnabled,
    bool? showLocalPreviewPip,
    bool? micEnabled,
    bool? cameraEnabled,
    bool? goingLive,
    bool? disconnecting,
    PeerHostSession? Function()? hostSession,
    bool? connecting,
    bool? viewerConnected,
    PeerOffer? Function()? peerOffer,
    String? rtcState,
    String? Function()? status,
    String? Function()? rtcDiagnostics,
  }) => CallState(
    localStream: localStream != null ? localStream() : this.localStream,
    remoteStream: remoteStream != null ? remoteStream() : this.remoteStream,
    localStreamActive: localStreamActive ?? this.localStreamActive,
    startingLocalMedia: startingLocalMedia ?? this.startingLocalMedia,
    remoteVideoAvailable: remoteVideoAvailable ?? this.remoteVideoAvailable,
    remoteCameraEnabled: remoteCameraEnabled ?? this.remoteCameraEnabled,
    remoteMicrophoneEnabled: remoteMicrophoneEnabled ?? this.remoteMicrophoneEnabled,
    showLocalPreviewPip: showLocalPreviewPip ?? this.showLocalPreviewPip,
    micEnabled: micEnabled ?? this.micEnabled,
    cameraEnabled: cameraEnabled ?? this.cameraEnabled,
    goingLive: goingLive ?? this.goingLive,
    disconnecting: disconnecting ?? this.disconnecting,
    hostSession: hostSession != null ? hostSession() : this.hostSession,
    connecting: connecting ?? this.connecting,
    viewerConnected: viewerConnected ?? this.viewerConnected,
    peerOffer: peerOffer != null ? peerOffer() : this.peerOffer,
    rtcState: rtcState ?? this.rtcState,
    status: status != null ? status() : this.status,
    rtcDiagnostics: rtcDiagnostics != null ? rtcDiagnostics() : this.rtcDiagnostics,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallState &&
          identical(localStream, other.localStream) &&
          identical(remoteStream, other.remoteStream) &&
          localStreamActive == other.localStreamActive &&
          startingLocalMedia == other.startingLocalMedia &&
          remoteVideoAvailable == other.remoteVideoAvailable &&
          remoteCameraEnabled == other.remoteCameraEnabled &&
          remoteMicrophoneEnabled == other.remoteMicrophoneEnabled &&
          showLocalPreviewPip == other.showLocalPreviewPip &&
          micEnabled == other.micEnabled &&
          cameraEnabled == other.cameraEnabled &&
          goingLive == other.goingLive &&
          disconnecting == other.disconnecting &&
          identical(hostSession, other.hostSession) &&
          connecting == other.connecting &&
          viewerConnected == other.viewerConnected &&
          identical(peerOffer, other.peerOffer) &&
          rtcState == other.rtcState &&
          status == other.status &&
          rtcDiagnostics == other.rtcDiagnostics;
}
