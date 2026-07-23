import 'dart:async';

import 'package:realtime_media/realtime_media.dart';

import 'fake_media_stream.dart';

final class FakeRealtimeMediaSession implements RealtimeMediaSessionController {
  bool micEnabled = true;
  bool cameraEnabled = true;
  bool localPreviewVisible = true;
  bool videoCaptureActive = true;
  final Object? cameraToggleError;
  final Object? microphoneToggleError;
  final Future<void> Function()? onDispose;
  final Future<void> Function()? onClose;
  final Object? closeError;
  int disposeCalls = 0;
  int closeCalls = 0;

  @override
  MediaStream? localStream;

  final _connectionStates = StreamController<RTCPeerConnectionState>.broadcast();
  final _remoteStreams = StreamController<MediaStream>.broadcast();
  final _remoteMediaStates = StreamController<RemoteMediaState>.broadcast();
  final _diagnostics = StreamController<String>.broadcast();

  @override
  bool get microphonePublishingEnabled => micEnabled;

  @override
  bool get cameraPublishingEnabled => cameraEnabled;

  @override
  bool get isLocalPreviewVisible => localPreviewVisible;

  @override
  Stream<RTCPeerConnectionState> get connectionStates => _connectionStates.stream;

  @override
  Stream<MediaStream> get remoteStreams => _remoteStreams.stream;

  @override
  Stream<RemoteMediaState> get remoteMediaStates => _remoteMediaStates.stream;

  @override
  Stream<String> get diagnostics => _diagnostics.stream;

  FakeRealtimeMediaSession({
    this.cameraToggleError,
    this.microphoneToggleError,
    this.onDispose,
    this.onClose,
    this.closeError,
  });

  void emitConnectionState(RTCPeerConnectionState state) {
    _connectionStates.add(state);
  }

  void emitRemoteStream(MediaStream stream) {
    _remoteStreams.add(stream);
  }

  void emitRemoteMediaState(RemoteMediaState state) {
    _remoteMediaStates.add(state);
  }

  @override
  Future<void> applyAnswer(String answerJson) async {}

  @override
  Future<void> close() async {
    closeCalls++;
    final closeCallback = onClose;
    if (closeCallback != null) {
      await closeCallback();
    }
    await _connectionStates.close();
    await _remoteStreams.close();
    await _remoteMediaStates.close();
    await _diagnostics.close();
    if (closeError case final error?) throw error;
  }

  @override
  Future<String> createAnswer(
    String remoteOfferJson,
    RtcConfiguration rtcConfiguration,
  ) async => '{"type":"answer"}';

  @override
  Future<String> createOffer(
    RtcConfiguration rtcConfiguration,
  ) async => '{"type":"offer"}';

  @override
  Future<void> dispose() async {
    disposeCalls++;
    final disposeCallback = onDispose;
    if (disposeCallback != null) {
      await disposeCallback();
    }
    localStream = null;
  }

  @override
  Future<MediaStream> startLocalMedia({
    LocalMediaConfig config = const LocalMediaConfig(),
  }) async {
    final existingStream = localStream;
    if (existingStream != null) return existingStream;

    final createdStream = FakeMediaStream();
    localStream = createdStream;

    return createdStream;
  }

  @override
  Future<bool> toggleCamera() async {
    if (cameraToggleError case final error?) throw error;
    cameraEnabled = !cameraEnabled;
    videoCaptureActive = cameraEnabled || localPreviewVisible;

    return cameraEnabled;
  }

  @override
  Future<void> setLocalPreviewVisible(bool visible) async {
    localPreviewVisible = visible;
    videoCaptureActive = cameraEnabled || localPreviewVisible;
  }

  @override
  Future<bool> toggleMic() async {
    if (microphoneToggleError case final error?) throw error;
    micEnabled = !micEnabled;

    return micEnabled;
  }
}
