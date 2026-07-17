import 'dart:async';
import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:realtime_media/src/local_media_config.dart';
import 'package:realtime_media/src/realtime_media_exception.dart';
import 'package:realtime_media/src/realtime_media_factories.dart';
import 'package:realtime_media/src/realtime_media_session_controller.dart';
import 'package:realtime_media/src/remote_media_state.dart';

/// Owns one WebRTC peer connection plus local/remote media lifecycle.
///
/// The presentation layer may render the exposed [MediaStream] handles, but SDP
/// creation, ICE gathering, track wiring, and disposal live here.
final class RealtimeMediaSession implements RealtimeMediaSessionController {
  final UserMediaFactory _userMediaFactory;
  final PeerConnectionFactory _peerConnectionFactory;

  final _connectionStates = StreamController<RTCPeerConnectionState>.broadcast();
  final _remoteStreams = StreamController<MediaStream>.broadcast();
  final _remoteMediaStates = StreamController<RemoteMediaState>.broadcast();
  final _diagnostics = StreamController<String>.broadcast();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _audioSourceStream;
  MediaStream? _videoSourceStream;
  MediaStreamTrack? _audioTrack;
  MediaStreamTrack? _videoTrack;
  RTCDataChannel? _controlChannel;
  RTCRtpSender? _audioSender;
  RTCRtpSender? _videoSender;
  LocalMediaConfig _localMediaConfig = const LocalMediaConfig();
  bool _microphonePublishingEnabled = true;
  bool _cameraPublishingEnabled = true;
  bool _localPreviewVisible = true;
  RemoteMediaState _remoteMediaState = const RemoteMediaState();
  Future<void>? _mediaOperations;

  @override
  Stream<RTCPeerConnectionState> get connectionStates => _connectionStates.stream;

  @override
  Stream<MediaStream> get remoteStreams => _remoteStreams.stream;

  @override
  Stream<RemoteMediaState> get remoteMediaStates => _remoteMediaStates.stream;

  @override
  Stream<String> get diagnostics => _diagnostics.stream;

  @override
  MediaStream? get localStream => _localStream;

  @override
  bool get microphonePublishingEnabled => _microphonePublishingEnabled;

  @override
  bool get cameraPublishingEnabled => _cameraPublishingEnabled;

  @override
  bool get isLocalPreviewVisible => _localPreviewVisible;

  factory RealtimeMediaSession({
    UserMediaFactory? userMediaFactory,
    PeerConnectionFactory? peerConnectionFactory,
  }) => RealtimeMediaSession._(
    userMediaFactory ?? _createDefaultUserMedia,
    peerConnectionFactory ?? _createDefaultPeerConnection,
  );

  RealtimeMediaSession._(
    this._userMediaFactory,
    this._peerConnectionFactory,
  );

  @override
  Future<MediaStream> startLocalMedia({
    LocalMediaConfig config = const LocalMediaConfig(),
  }) async {
    final existingStream = _localStream;
    if (existingStream != null) return existingStream;
    _diag('local_media.requested');
    _localMediaConfig = config;

    final MediaStream stream;
    try {
      stream = await _userMediaFactory(config.toConstraints());
    } on Exception catch (_, stack) {
      Error.throwWithStackTrace(const LocalMediaStartFailure(), stack);
    }
    _localStream = stream;
    _audioSourceStream = stream;
    _videoSourceStream = stream;
    _audioTrack = stream.getAudioTracks().firstOrNull;
    _videoTrack = stream.getVideoTracks().firstOrNull;
    _diag(
      'local_media.ready direction=local '
      'audio=${stream.getAudioTracks().length} '
      'video=${stream.getVideoTracks().length}',
    );

    final pc = _peerConnection;
    if (pc != null) await _addLocalTracks(pc);

    return stream;
  }

  @override
  Future<String> createOffer(RtcConfiguration rtcConfiguration) async {
    final pc = await _ensurePeerConnection(
      rtcConfiguration,
      createControlChannel: true,
    );
    _diag('offer.create.started');
    try {
      final offer = await pc.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      await pc.setLocalDescription(offer);
      _diag('offer.local_description_set');
    } on Exception catch (_, stack) {
      Error.throwWithStackTrace(const PeerConnectionFailure(), stack);
    }
    await _waitForIceGathering(pc);

    return _localDescriptionJson(pc);
  }

  @override
  Future<String> createAnswer(
    String remoteOfferJson,
    RtcConfiguration rtcConfiguration,
  ) async {
    final peerConnection = await _ensurePeerConnection(
      rtcConfiguration,
      createControlChannel: false,
    );
    await _setRemoteDescription(peerConnection, remoteOfferJson);
    _diag('answer.remote_offer_applied');

    try {
      final answer = await peerConnection.createAnswer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      await peerConnection.setLocalDescription(answer);
      _diag('answer.local_description_set');
    } on Exception catch (_, stack) {
      Error.throwWithStackTrace(const PeerConnectionFailure(), stack);
    }
    await _waitForIceGathering(peerConnection);

    return _localDescriptionJson(peerConnection);
  }

  @override
  Future<void> applyAnswer(String answerJson) async {
    final pc = _peerConnection;
    if (pc == null) return;

    await _setRemoteDescription(pc, answerJson);
    _diag('answer.remote_answer_applied');
  }

  @override
  Future<bool> toggleMic() => _runMediaOperation(() async {
    final enabled = !_microphonePublishingEnabled;
    final sender = _audioSender;

    try {
      if (enabled) {
        final hadAudioTrack = _audioTrack != null;
        final audioTrack = _audioTrack ?? await _startAudioCapture();
        if (sender != null) {
          try {
            await sender.replaceTrack(audioTrack);
          } on Exception {
            if (!hadAudioTrack) {
              await _stopAudioCapture();
            }
            rethrow;
          }
        }
      } else {
        if (sender != null) {
          await sender.replaceTrack(null);
        }
        _microphonePublishingEnabled = false;
        _diag('microphone.publishing=disabled');
        unawaited(_sendMediaState());
        await _stopAudioCapture(propagateStopFailure: true);
      }
    } on Exception catch (_, stack) {
      Error.throwWithStackTrace(
        const MicrophonePublishingFailure(),
        stack,
      );
    }

    if (enabled) {
      _microphonePublishingEnabled = true;
      _diag('microphone.publishing=enabled');
      unawaited(_sendMediaState());
    }

    return enabled;
  });

  @override
  Future<bool> toggleCamera() => _runMediaOperation(() async {
    final enabled = !_cameraPublishingEnabled;
    final sender = _videoSender;

    try {
      if (enabled) {
        final hadVideoTrack = _videoTrack != null;
        final videoTrack = _videoTrack ?? await _startVideoCapture();
        if (sender != null) {
          try {
            await sender.replaceTrack(videoTrack);
          } on Exception {
            if (!hadVideoTrack) {
              await _stopVideoCapture(propagateStopFailure: true);
            }
            rethrow;
          }
        }
      } else {
        if (sender != null) {
          await sender.replaceTrack(null);
        }
        _cameraPublishingEnabled = false;
        _diag('camera.publishing=disabled');
        unawaited(_sendMediaState());
        if (!_localPreviewVisible) {
          await _stopVideoCapture(propagateStopFailure: true);
        }
      }
    } on Exception catch (_, stack) {
      Error.throwWithStackTrace(const CameraPublishingFailure(), stack);
    }

    if (enabled) {
      _cameraPublishingEnabled = true;
      _diag('camera.publishing=enabled');
      unawaited(_sendMediaState());
    }

    return enabled;
  });

  @override
  Future<void> setLocalPreviewVisible(bool visible) => _runMediaOperation(() async {
    if (_localPreviewVisible == visible) return;

    if (visible) {
      if (_videoTrack == null) {
        await _startVideoCapture();
      }
      _localPreviewVisible = true;
      _diag('camera.local_preview=visible');

      return;
    }

    _localPreviewVisible = false;
    _diag('camera.local_preview=hidden');
    if (!_cameraPublishingEnabled) {
      await _stopVideoCapture(propagateStopFailure: true);
    }
  });

  @override
  Future<void> dispose() async {
    await _mediaOperations;
    final tracks = _localStream?.getTracks() ?? <MediaStreamTrack>[];
    for (final track in tracks) {
      try {
        await track.stop();
      } on Exception {
        _diag('local_media.track_stop_failed');
      }
    }
    final audioSourceStream = _audioSourceStream;
    if (audioSourceStream != null && !identical(audioSourceStream, _localStream)) {
      try {
        await audioSourceStream.dispose();
      } on Exception {
        _diag('microphone.capture.dispose_source_failed');
      }
    }
    final videoSourceStream = _videoSourceStream;
    if (videoSourceStream != null && !identical(videoSourceStream, _localStream)) {
      try {
        await videoSourceStream.dispose();
      } on Exception {
        _diag('camera.capture.dispose_source_failed');
      }
    }
    try {
      await _localStream?.dispose();
    } on Exception {
      _diag('local_media.dispose_failed');
    }
    _localStream = null;
    _audioSourceStream = null;
    _videoSourceStream = null;
    _audioTrack = null;
    _videoTrack = null;

    try {
      await _controlChannel?.close();
    } on Exception {
      _diag('control_channel.close_failed');
    }
    _controlChannel = null;
    try {
      await _peerConnection?.close();
    } on Exception {
      _diag('pc.close_failed');
    }
    _peerConnection = null;
    _audioSender = null;
    _videoSender = null;
    _microphonePublishingEnabled = true;
    _cameraPublishingEnabled = true;
    _localPreviewVisible = true;
  }

  @override
  Future<void> close() async {
    //TODO(ntfnd404): why dispose first?
    await dispose();
    await _connectionStates.close();
    await _remoteStreams.close();
    await _remoteMediaStates.close();
    await _diagnostics.close();
  }

  Future<RTCPeerConnection> _ensurePeerConnection(
    RtcConfiguration rtcConfiguration, {
    required bool createControlChannel,
  }) async {
    final existingConnection = _peerConnection;
    if (existingConnection != null) return existingConnection;

    final RTCPeerConnection peerConnection;
    try {
      peerConnection = await _peerConnectionFactory(rtcConfiguration);
    } on Exception catch (_, stack) {
      Error.throwWithStackTrace(const PeerConnectionFailure(), stack);
    }
    _diag('peer_connection.created');
    peerConnection.onConnectionState = (state) {
      _diag('pc.connection_state=${state.name}');
      _connectionStates.add(state);
    };
    peerConnection.onSignalingState = (state) => _diag('pc.signaling_state=${state.name}');
    peerConnection.onIceConnectionState = (state) => _diag('pc.ice_connection_state=${state.name}');
    peerConnection.onDataChannel = _attachControlChannel;
    peerConnection.onTrack = (event) {
      if (event.streams.isEmpty) return;

      final stream = event.streams.first;
      if (_matchesLocalStream(stream)) {
        _diag(
          'pc.remote_track.rejected reason=local_identity',
        );

        return;
      }
      _diag(
        'pc.remote_track.accepted direction=remote '
        'audio=${stream.getAudioTracks().length} '
        'video=${stream.getVideoTracks().length}',
      );
      _remoteStreams.add(stream);
    };
    await _addLocalTracks(peerConnection);
    if (createControlChannel) {
      final channel = await peerConnection.createDataChannel(
        'sols-stream-control',
        RTCDataChannelInit()..ordered = true,
      );
      _attachControlChannel(channel);
    }
    _peerConnection = peerConnection;

    return peerConnection;
  }

  void _attachControlChannel(RTCDataChannel channel) {
    _controlChannel = channel;
    _diag('control_channel.attached');
    channel.onDataChannelState = (state) {
      _diag('control_channel.state=${state.name}');
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        unawaited(_sendMediaState());
      }
    };
    channel.onMessage = _handleControlMessage;
  }

  void _handleControlMessage(RTCDataChannelMessage message) {
    if (message.isBinary) return;

    try {
      final payload = jsonDecode(message.text);
      if (payload is! Map<String, dynamic> ||
          payload['type'] != 'media-state' ||
          payload['cameraEnabled'] is! bool ||
          payload['microphoneEnabled'] is! bool) {
        return;
      }

      _remoteMediaState = RemoteMediaState(
        cameraEnabled: payload['cameraEnabled'] as bool,
        microphoneEnabled: payload['microphoneEnabled'] as bool,
      );
      _diag('remote_camera.enabled=${_remoteMediaState.cameraEnabled}');
      _diag('remote_microphone.enabled=${_remoteMediaState.microphoneEnabled}');
      if (!_remoteMediaStates.isClosed) {
        _remoteMediaStates.add(_remoteMediaState);
      }
    } on FormatException {
      _diag('control_channel.invalid_message');
    }
  }

  Future<void> _sendMediaState() async {
    final channel = _controlChannel;
    if (channel == null || channel.state != RTCDataChannelState.RTCDataChannelOpen) {
      return;
    }

    try {
      await channel.send(
        RTCDataChannelMessage(
          jsonEncode({
            'type': 'media-state',
            'cameraEnabled': _cameraPublishingEnabled,
            'microphoneEnabled': _microphonePublishingEnabled,
          }),
        ),
      );
      _diag(
        'control_channel.media_state_sent '
        'camera=$_cameraPublishingEnabled '
        'microphone=$_microphonePublishingEnabled',
      );
    } on Exception {
      _diag('control_channel.media_state_send_failed');
    }
  }

  Future<MediaStreamTrack> _startAudioCapture() async {
    final localStream = _localStream;
    if (localStream == null) throw const LocalMediaStartFailure();
    _diag('microphone.capture=requested');

    final MediaStream sourceStream;
    try {
      sourceStream = await _userMediaFactory({
        'audio': _localMediaConfig.audio,
        'video': false,
      });
    } on Exception catch (_, stack) {
      Error.throwWithStackTrace(const LocalMediaStartFailure(), stack);
    }

    final track = sourceStream.getAudioTracks().firstOrNull;
    if (track == null) {
      await sourceStream.dispose();
      throw const LocalMediaStartFailure();
    }

    try {
      await localStream.addTrack(track);
    } on Exception catch (_, stack) {
      try {
        await track.stop();
      } on Exception {
        _diag('microphone.capture.stop_failed');
      }
      try {
        await sourceStream.dispose();
      } on Exception {
        _diag('microphone.capture.dispose_source_failed');
      }
      Error.throwWithStackTrace(const LocalMediaStartFailure(), stack);
    }

    _audioSourceStream = sourceStream;
    _audioTrack = track;
    _diag('microphone.capture=ready');

    return track;
  }

  Future<void> _stopAudioCapture({
    bool propagateStopFailure = false,
  }) async {
    final track = _audioTrack;
    if (track == null) return;

    final localStream = _localStream;
    final sourceStream = _audioSourceStream;
    Object? cleanupFailure;
    StackTrace? cleanupStack;
    try {
      await track.stop();
    } on Exception catch (error, stack) {
      _diag('microphone.capture.stop_failed');
      cleanupFailure = error;
      cleanupStack = stack;
    }
    try {
      await localStream?.removeTrack(track);
    } on Exception catch (error, stack) {
      _diag('microphone.capture.remove_track_failed');
      cleanupFailure ??= error;
      cleanupStack ??= stack;
    }
    if (sourceStream != null && !identical(sourceStream, localStream)) {
      try {
        await sourceStream.dispose();
      } on Exception catch (error, stack) {
        _diag('microphone.capture.dispose_source_failed');
        cleanupFailure ??= error;
        cleanupStack ??= stack;
      }
    }

    _audioTrack = null;
    _audioSourceStream = null;
    _diag('microphone.capture=stopped');
    if (propagateStopFailure && cleanupFailure != null) {
      Error.throwWithStackTrace(
        cleanupFailure,
        cleanupStack ?? StackTrace.current,
      );
    }
  }

  Future<MediaStreamTrack> _startVideoCapture() async {
    final localStream = _localStream;
    if (localStream == null) throw const LocalMediaStartFailure();
    _diag('camera.capture=requested');

    final MediaStream sourceStream;
    try {
      sourceStream = await _userMediaFactory({
        'audio': false,
        'video': _localMediaConfig.video,
      });
    } on Exception catch (_, stack) {
      Error.throwWithStackTrace(const LocalMediaStartFailure(), stack);
    }

    final track = sourceStream.getVideoTracks().firstOrNull;
    if (track == null) {
      await sourceStream.dispose();
      throw const LocalMediaStartFailure();
    }

    try {
      await localStream.addTrack(track);
    } on Exception catch (_, stack) {
      try {
        await track.stop();
      } on Exception {
        _diag('camera.capture.stop_failed');
      }
      try {
        await sourceStream.dispose();
      } on Exception {
        _diag('camera.capture.dispose_source_failed');
      }
      Error.throwWithStackTrace(const LocalMediaStartFailure(), stack);
    }

    _videoSourceStream = sourceStream;
    _videoTrack = track;
    _diag('camera.capture=ready');

    return track;
  }

  Future<void> _stopVideoCapture({
    bool propagateStopFailure = false,
  }) async {
    final track = _videoTrack;
    if (track == null) return;

    final localStream = _localStream;
    final sourceStream = _videoSourceStream;
    Object? cleanupFailure;
    StackTrace? cleanupStack;
    try {
      await track.stop();
    } on Exception catch (error, stack) {
      _diag('camera.capture.stop_failed');
      cleanupFailure = error;
      cleanupStack = stack;
    }
    try {
      await localStream?.removeTrack(track);
    } on Exception catch (error, stack) {
      _diag('camera.capture.remove_track_failed');
      cleanupFailure ??= error;
      cleanupStack ??= stack;
    }
    if (sourceStream != null && !identical(sourceStream, localStream)) {
      try {
        await sourceStream.dispose();
      } on Exception catch (error, stack) {
        _diag('camera.capture.dispose_source_failed');
        cleanupFailure ??= error;
        cleanupStack ??= stack;
      }
    }

    _videoTrack = null;
    _videoSourceStream = null;
    _diag('camera.capture=stopped');
    if (propagateStopFailure && cleanupFailure != null) {
      Error.throwWithStackTrace(
        cleanupFailure,
        cleanupStack ?? StackTrace.current,
      );
    }
  }

  Future<T> _runMediaOperation<T>(Future<T> Function() operation) {
    final result = Completer<T>();
    final previous = _mediaOperations;
    Future<void> execute() async {
      try {
        result.complete(await operation());
      } catch (error, stack) {
        result.completeError(error, stack);
      }
    }

    _mediaOperations = previous == null ? execute() : previous.then((_) => execute());

    return result.future;
  }

  Future<void> _addLocalTracks(RTCPeerConnection pc) async {
    final stream = _localStream;
    if (stream == null) return;

    final senders = await pc.getSenders();
    final senderTrackIds = senders.map((s) => s.track?.id).toSet();
    for (final track in stream.getTracks()) {
      if (track.kind == 'audio' && _audioSender != null) continue;
      if (track.kind == 'video' && _videoSender != null) continue;
      if (!senderTrackIds.contains(track.id)) {
        final sender = await pc.addTrack(track, stream);
        if (track.kind == 'audio') {
          _audioSender = sender;
          if (!_microphonePublishingEnabled) {
            await sender.replaceTrack(null);
          }
        } else if (track.kind == 'video') {
          _videoSender = sender;
          if (!_cameraPublishingEnabled) {
            await sender.replaceTrack(null);
          }
        }
        _diag('pc.local_track_added direction=local kind=${track.kind}');
      }
    }
  }

  Future<void> _waitForIceGathering(RTCPeerConnection pc) async {
    if (pc.iceGatheringState == RTCIceGatheringState.RTCIceGatheringStateComplete) {
      _diag('pc.ice_gathering=complete');

      return;
    }

    final completer = Completer<void>();
    _diag('pc.ice_gathering=waiting');
    pc.onIceGatheringState = (state) {
      _diag('pc.ice_gathering_state=${state.name}');
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete && !completer.isCompleted) {
        completer.complete();
      }
    };
    unawaited(
      Future<void>.delayed(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          _diag('pc.ice_gathering=timeout');
          completer.complete();
        }
      }),
    );

    await completer.future;
  }

  Future<void> _setRemoteDescription(RTCPeerConnection pc, String descriptionJson) async {
    final Map<String, dynamic> parsed;
    try {
      parsed = jsonDecode(descriptionJson) as Map<String, dynamic>;
    } on Exception catch (_, stack) {
      Error.throwWithStackTrace(const SdpParseFailure(), stack);
    }

    try {
      await pc.setRemoteDescription(
        RTCSessionDescription(parsed['sdp'] as String, parsed['type'] as String),
      );
      _diag('pc.remote_description_set type=${parsed['type']}');
    } on Exception catch (_, stack) {
      Error.throwWithStackTrace(const SdpApplicationFailure(), stack);
    }
  }

  Future<String> _localDescriptionJson(RTCPeerConnection pc) async {
    final description = await pc.getLocalDescription();
    if (description == null) throw const PeerConnectionFailure();

    return jsonEncode({'type': description.type, 'sdp': description.sdp});
  }

  bool _matchesLocalStream(MediaStream candidate) {
    final localStream = _localStream;
    if (localStream == null) return false;
    if (identical(candidate, localStream) || candidate.id == localStream.id) {
      return true;
    }

    final localTrackIds = localStream.getTracks().map((track) => track.id).toSet();

    return candidate.getTracks().any((track) => localTrackIds.contains(track.id));
  }

  static Future<MediaStream> _createDefaultUserMedia(
    Map<String, dynamic> constraints,
  ) => navigator.mediaDevices.getUserMedia(constraints);

  static Future<RTCPeerConnection> _createDefaultPeerConnection(
    RtcConfiguration configuration,
  ) => createPeerConnection(configuration);

  void _diag(String message) {
    if (_diagnostics.isClosed) return;
    _diagnostics.add(message);
  }
}
