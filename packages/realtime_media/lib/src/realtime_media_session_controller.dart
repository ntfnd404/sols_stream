import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:realtime_media/src/local_media_config.dart';
import 'package:realtime_media/src/remote_media_state.dart';

typedef RtcConfiguration = Map<String, Object?>;

abstract interface class RealtimeMediaSessionController {
  Stream<RTCPeerConnectionState> get connectionStates;
  Stream<MediaStream> get remoteStreams;
  Stream<RemoteMediaState> get remoteMediaStates;
  Stream<String> get diagnostics;
  MediaStream? get localStream;
  bool get microphonePublishingEnabled;
  bool get cameraPublishingEnabled;
  bool get isLocalPreviewVisible;

  Future<MediaStream> startLocalMedia({
    LocalMediaConfig config = const LocalMediaConfig(),
  });

  Future<String> createOffer(RtcConfiguration rtcConfiguration);

  Future<String> createAnswer(
    String remoteOfferJson,
    RtcConfiguration rtcConfiguration,
  );

  Future<void> applyAnswer(String answerJson);

  Future<bool> toggleMic();

  Future<bool> toggleCamera();

  Future<void> setLocalPreviewVisible(bool visible);

  Future<void> dispose();

  Future<void> close();
}
