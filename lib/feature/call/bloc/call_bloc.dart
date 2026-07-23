import 'dart:async';
import 'dart:developer';

import 'package:ephemeral_bloc/ephemeral_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realtime_media/realtime_media.dart';
import 'package:signaling/signaling.dart';
import 'package:sols_stream/core/event_bus/app_event_bus.dart';
import 'package:sols_stream/core/event_bus/events/call_session_invalidated_app_event.dart';

part 'call_action.dart';
part 'call_event.dart';
part 'call_state.dart';

final class CallBloc extends Bloc<CallEvent, CallState> with EphemeralBlocMixin<CallState, CallAction> {
  final PeerSignaling _peerSignaling;
  final RealtimeMediaSessionController _mediaSession;
  final AppEventBus _eventBus;

  late final StreamSubscription<CallSessionInvalidatedAppEvent> _webRtcInvalidationSub;
  late final StreamSubscription<RTCPeerConnectionState> _mediaStateSub;
  late final StreamSubscription<MediaStream> _remoteStreamSub;
  late final StreamSubscription<RemoteMediaState> _remoteMediaStateSub;
  late final StreamSubscription<String> _mediaDiagnosticsSub;
  StreamSubscription<String>? _answerSub;

  bool get _hasActiveWebRtcSession =>
      _mediaSession.localStream != null ||
      state.goingLive ||
      state.connecting ||
      state.viewerConnected ||
      state.localStreamActive ||
      state.remoteVideoAvailable ||
      state.hostSession != null ||
      state.peerOffer != null;

  CallBloc({
    required this._peerSignaling,
    required this._mediaSession,
    required this._eventBus,
  }) : super(const CallState()) {
    on<GoLiveRequestedEvent>(_onGoLiveRequested);
    on<RegenerateInviteRequestedEvent>(_onRegenerateInviteRequested);
    on<ConnectAsViewerRequestedEvent>(_onConnectAsViewerRequested);
    on<DisconnectRequestedEvent>(_onDisconnectRequested);
    on<ToggleMicRequestedEvent>(_onToggleMicRequested);
    on<ToggleCameraRequestedEvent>(_onToggleCameraRequested);
    on<TogglePipRequestedEvent>(_onTogglePipRequested);
    on<_PeerConnectionStateChangedEvent>(_onPeerConnectionStateChanged);
    on<_RemoteTrackReceivedEvent>(_onRemoteTrackReceived);
    on<_RemoteMediaStateChangedEvent>(_onRemoteMediaStateChanged);
    on<_MediaDiagnosticsReceivedEvent>(_onMediaDiagnosticsReceived);
    on<_AnswerSdpReceivedEvent>(_onAnswerSdpReceived);
    on<_SignalingFailedEvent>(_onSignalingFailed);
    on<_CallSessionInvalidatedEvent>(_onWebRtcSessionInvalidated);

    _webRtcInvalidationSub = _eventBus.on<CallSessionInvalidatedAppEvent>().listen(
      (_) => add(const _CallSessionInvalidatedEvent()),
    );

    _mediaStateSub = _mediaSession.connectionStates.listen(
      (state) => add(_PeerConnectionStateChangedEvent(state)),
    );

    _remoteStreamSub = _mediaSession.remoteStreams.listen(
      (stream) => add(_RemoteTrackReceivedEvent(stream)),
    );

    _remoteMediaStateSub = _mediaSession.remoteMediaStates.listen(
      (mediaState) => add(_RemoteMediaStateChangedEvent(mediaState)),
    );

    _mediaDiagnosticsSub = _mediaSession.diagnostics.listen(
      (message) => add(_MediaDiagnosticsReceivedEvent(message)),
    );
  }

  @override
  Future<void> close() async {
    final hostSession = state.hostSession;
    hostSession?.cancelWaiting();
    await Future.wait<void>([
      _webRtcInvalidationSub.cancel(),
      _mediaStateSub.cancel(),
      _remoteStreamSub.cancel(),
      _remoteMediaStateSub.cancel(),
      _mediaDiagnosticsSub.cancel(),
      if (_answerSub case final answerSub?) answerSub.cancel(),
    ]);
    await _closeMediaBestEffort();
    await _reclaimDeposits(hostSession);

    return super.close();
  }

  // ── Publisher flow ────────────────────────────────────────────────────────

  Future<void> _onGoLiveRequested(
    GoLiveRequestedEvent event,
    Emitter<CallState> emit,
  ) => _startPublisher(
    rtcConfiguration: event.rtcConfiguration,
    emit: emit,
  );

  Future<void> _onRegenerateInviteRequested(
    RegenerateInviteRequestedEvent event,
    Emitter<CallState> emit,
  ) async {
    if (state.goingLive || state.disconnecting) return;

    _recordLog('publisher.invite.regeneration.started');
    await _disconnect(emit);
    if (emit.isDone) return;

    await _startPublisher(
      rtcConfiguration: event.rtcConfiguration,
      emit: emit,
    );
  }

  Future<void> _startPublisher({
    required Map<String, dynamic> rtcConfiguration,
    required Emitter<CallState> emit,
  }) async {
    if (state.goingLive || state.disconnecting) return;

    _recordLog('publisher.go_live.started');
    emit(
      state.copyWith(
        goingLive: true,
        status: () => 'Starting camera and mic…',
      ),
    );
    try {
      await _startLocalMedia(emit);
      _recordLog('publisher.local_media.ready');
      emit(
        state.copyWith(
          status: () => 'Creating offer…',
        ),
      );
      final offerJson = await _mediaSession.createOffer(rtcConfiguration);
      _recordLog('publisher.offer.created');

      emit(
        state.copyWith(
          status: () => 'Opening slot on Solana…',
        ),
      );
      final hostSession = await _peerSignaling.publishOffer(offerJson);
      _recordLog('publisher.signaling.ready');

      emit(
        state.copyWith(
          goingLive: false,
          hostSession: () => hostSession,
          status: () => 'Invite ready. Share it with the viewer.',
        ),
      );
      _answerSub = Stream.fromFuture(hostSession.awaitAnswerSdp()).listen(
        (answer) => add(_AnswerSdpReceivedEvent(answer)),
        onError: (Object error, StackTrace stackTrace) => add(
          _SignalingFailedEvent(error, stackTrace),
        ),
      );
    } catch (e, st) {
      _recordLog('publisher.go_live.failed type=${e.runtimeType}');
      _reportUnexpectedFailure(
        e,
        st,
        message: 'Go Live failed. Check your wallet and connection.',
      );
      await _disposeMediaBestEffort();
      if (emit.isDone) return;

      emit(
        state.copyWith(
          goingLive: false,
          localStream: () => null,
          remoteStream: () => null,
          localStreamActive: false,
          remoteVideoAvailable: false,
          status: () => 'Go Live failed. Check your wallet and connection.',
        ),
      );
    }
  }

  Future<void> _onAnswerSdpReceived(
    _AnswerSdpReceivedEvent event,
    Emitter<CallState> emit,
  ) async {
    emit(state.copyWith(status: () => 'Viewer connected — establishing media…'));
    try {
      if (_mediaSession.localStream == null) return;
      await _mediaSession.applyAnswer(event.answerJson);
    } catch (error, stack) {
      _reportUnexpectedFailure(
        error,
        stack,
        message: 'Apply answer failed.',
      );
      emit(state.copyWith(status: () => 'Apply answer failed.'));
    }
  }

  // ── Viewer flow ───────────────────────────────────────────────────────────

  Future<void> _onConnectAsViewerRequested(
    ConnectAsViewerRequestedEvent event,
    Emitter<CallState> emit,
  ) async {
    final url = event.url.trim();
    if (url.isEmpty) {
      emit(state.copyWith(status: () => 'Paste a connection link first.'));

      return;
    }
    if (state.connecting) return;

    _recordLog('viewer.connect.started');
    emit(state.copyWith(connecting: true, status: () => 'Starting camera and mic…'));
    try {
      final invite = Uri.tryParse(url);
      if (invite == null) {
        throw const FormatException('Invalid peer invite URI.');
      }
      _recordLog('viewer.protocol.peer');
      await _connectToPeer(invite, event.rtcConfiguration, emit);
      emit(
        state.copyWith(
          connecting: false,
          viewerConnected: true,
          status: () => 'Answer sent — waiting for media…',
        ),
      );
      _recordLog('viewer.connect.completed');
    } on PeerSelfConnectionException catch (error) {
      _recordLog('viewer.connect.rejected reason=same_wallet');
      _recordLogExpectedFailure(error);
      emit(
        state.copyWith(
          connecting: false,
          status: () => 'Publisher and viewer must use different wallets.',
        ),
      );
    } on PeerInviteClaimedException catch (error) {
      _recordLog('viewer.connect.rejected reason=invite_claimed');
      _recordLogExpectedFailure(error);

      emit(
        state.copyWith(
          connecting: false,
          status: () =>
              'This invite has already been claimed. '
              'Ask the publisher to regenerate it.',
        ),
      );
    } on KeyBrokerException catch (error) {
      _recordLog(
        'viewer.connect.failed type=KeyBrokerException status=${error.statusCode ?? 'unknown'}',
      );
      _recordLogExpectedFailure(error);

      emit(
        state.copyWith(
          connecting: false,
          status: () =>
              'The invite expired or no longer matches the active session. Ask the publisher to regenerate it.',
        ),
      );
    } catch (e, st) {
      _recordLog('viewer.connect.failed type=${e.runtimeType}');
      _reportUnexpectedFailure(
        e,
        st,
        message: 'Connect failed. Check the invite link and try again.',
      );

      emit(
        state.copyWith(
          connecting: false,
          status: () => 'Connect failed. Check the invite link and try again.',
        ),
      );
    }
  }

  Future<void> _connectToPeer(
    Uri invite,
    Map<String, dynamic> rtcConfig,
    Emitter<CallState> emit,
  ) async {
    emit(state.copyWith(status: () => 'Discovering peer on-chain…'));
    final offer = await _peerSignaling.fetchOffer(invite);
    emit(
      state.copyWith(
        peerOffer: () => offer,
        status: () => 'Starting camera and mic…',
      ),
    );

    await _startLocalMedia(emit);
    _recordLog('viewer.local_media.ready');
    emit(state.copyWith(status: () => 'Building answer…'));
    final answerJson = await _mediaSession.createAnswer(offer.sdpOffer, rtcConfig);
    emit(
      state.copyWith(
        status: () => 'Sending answer…',
      ),
    );
    await _peerSignaling.submitAnswer(offer, answerJson);
  }

  // ── Disconnect ────────────────────────────────────────────────────────────

  Future<void> _onDisconnectRequested(
    DisconnectRequestedEvent event,
    Emitter<CallState> emit,
  ) async {
    await _disconnect(emit);
  }

  Future<void> _onWebRtcSessionInvalidated(
    _CallSessionInvalidatedEvent event,
    Emitter<CallState> emit,
  ) async {
    if (!_hasActiveWebRtcSession) return;

    await _disconnect(emit);
  }

  Future<void> _disconnect(Emitter<CallState> emit) async {
    if (state.disconnecting) return;

    await _answerSub?.cancel();
    _answerSub = null;
    // Stops the answer-poll loop's chain reads — without this, a host who
    // disconnects mid-wait leaves an unbounded background RPC poll running.
    state.hostSession?.cancelWaiting();

    emit(
      state.copyWith(
        disconnecting: true,
        status: () => 'Disconnecting…',
      ),
    );
    // Stop capture and RTP publication before waiting for Solana confirmations.
    // Reclaim remains awaited so a fresh GoLiveRequestedEvent cannot race the
    // transaction that returns the host's User PDA to Idle.
    await _disposeMediaBestEffort();
    await _reclaimDeposits();
    if (emit.isDone) return;

    emit(
      state.copyWith(
        goingLive: false,
        connecting: false,
        viewerConnected: false,
        hostSession: () => null,
        peerOffer: () => null,
        localStream: () => null,
        remoteStream: () => null,
        localStreamActive: false,
        remoteVideoAvailable: false,
        remoteCameraEnabled: true,
        remoteMicrophoneEnabled: true,
        micEnabled: true,
        cameraEnabled: true,
        disconnecting: false,
        rtcState: 'Idle',
        status: () => 'Disconnected.',
        rtcDiagnostics: () => null,
      ),
    );
  }

  // ── Media controls ────────────────────────────────────────────────────────

  Future<void> _onToggleMicRequested(
    ToggleMicRequestedEvent event,
    Emitter<CallState> emit,
  ) async {
    if (!state.localStreamActive) return;

    try {
      final enabled = await _mediaSession.toggleMic();
      emit(state.copyWith(micEnabled: enabled));
    } catch (error, stack) {
      _reportUnexpectedFailure(
        error,
        stack,
        message: 'Could not update microphone. Try again.',
      );
      emit(
        state.copyWith(
          micEnabled: _mediaSession.microphonePublishingEnabled,
          status: () => 'Could not update microphone. Try again.',
        ),
      );
    }
  }

  Future<void> _onToggleCameraRequested(
    ToggleCameraRequestedEvent event,
    Emitter<CallState> emit,
  ) async {
    if (!state.localStreamActive) return;

    try {
      final enabled = await _mediaSession.toggleCamera();
      emit(state.copyWith(cameraEnabled: enabled));
    } catch (error, stack) {
      _reportUnexpectedFailure(
        error,
        stack,
        message: 'Could not update camera. Try again.',
      );
      emit(
        state.copyWith(
          cameraEnabled: _mediaSession.cameraPublishingEnabled,
          status: () => 'Could not update camera. Try again.',
        ),
      );
    }
  }

  Future<void> _onTogglePipRequested(
    TogglePipRequestedEvent event,
    Emitter<CallState> emit,
  ) async {
    try {
      if (state.localStreamActive) {
        await _mediaSession.setLocalPreviewVisible(event.show);
      }
      emit(state.copyWith(showLocalPreviewPip: event.show));
    } catch (error, stack) {
      _reportUnexpectedFailure(
        error,
        stack,
        message: 'Could not update local preview. Try again.',
      );
      emit(
        state.copyWith(
          showLocalPreviewPip: _mediaSession.isLocalPreviewVisible,
          status: () => 'Could not update local preview. Try again.',
        ),
      );
    }
  }

  // ── WebRTC callbacks ──────────────────────────────────────────────────────

  void _onPeerConnectionStateChanged(
    _PeerConnectionStateChangedEvent event,
    Emitter<CallState> emit,
  ) {
    final cs = event.connectionState;
    final dropped =
        cs == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
        cs == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
        cs == RTCPeerConnectionState.RTCPeerConnectionStateClosed;

    emit(
      state.copyWith(
        rtcState: cs.name,
        viewerConnected: dropped ? false : state.viewerConnected,
        status: () => 'Peer connection: ${cs.name}',
      ),
    );

    if (cs == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
      unawaited(_confirmConnection());
    }
  }

  void _onRemoteTrackReceived(
    _RemoteTrackReceivedEvent event,
    Emitter<CallState> emit,
  ) {
    final localStream = state.localStream;
    if (localStream != null && _matchesLocalStream(localStream, event.stream)) {
      _recordLog(
        'media.remote_stream.rejected reason=local_identity',
      );

      return;
    }

    emit(
      state.copyWith(
        remoteStream: () => event.stream,
        remoteVideoAvailable: true,
        status: () => 'Remote track received.',
      ),
    );
  }

  bool _matchesLocalStream(
    MediaStream localStream,
    MediaStream candidate,
  ) {
    if (identical(localStream, candidate) || localStream.id == candidate.id) {
      return true;
    }

    final localTrackIds = localStream.getTracks().map((track) => track.id).toSet();

    return candidate.getTracks().any((track) => localTrackIds.contains(track.id));
  }

  void _onRemoteMediaStateChanged(
    _RemoteMediaStateChangedEvent event,
    Emitter<CallState> emit,
  ) => emit(
    state.copyWith(
      remoteCameraEnabled: event.mediaState.cameraEnabled,
      remoteMicrophoneEnabled: event.mediaState.microphoneEnabled,
    ),
  );

  void _onMediaDiagnosticsReceived(
    _MediaDiagnosticsReceivedEvent event,
    Emitter<CallState> emit,
  ) {
    _recordLog('media.${event.message}');
    emit(state.copyWith(rtcDiagnostics: () => event.message));
  }

  Future<void> _onSignalingFailed(
    _SignalingFailedEvent event,
    Emitter<CallState> emit,
  ) async {
    _recordLog('publisher.signaling.failed type=${event.error.runtimeType}');
    _reportUnexpectedFailure(
      event.error,
      event.stackTrace,
      message: 'Signaling failed. Check the wallet balance and connection, then start a new call.',
    );
    await _disconnect(emit);
    if (emit.isDone) return;

    emit(
      state.copyWith(
        status: () => 'Signaling failed. Check the wallet balance and connection, then start a new call.',
      ),
    );
  }

  // ── Helpers: media ────────────────────────────────────────────────────────

  Future<void> _startLocalMedia(Emitter<CallState> emit) async {
    if (state.localStreamActive || state.startingLocalMedia) return;

    emit(state.copyWith(startingLocalMedia: true));
    try {
      final stream = await _mediaSession.startLocalMedia();
      emit(
        state.copyWith(
          localStream: () => stream,
          localStreamActive: true,
          startingLocalMedia: false,
          status: () => 'Camera and mic ready.',
        ),
      );
    } catch (e, stack) {
      _recordLog('media.start.failed type=${e.runtimeType}');
      _reportUnexpectedFailure(
        e,
        stack,
        message: 'Failed to start camera and microphone.',
      );
      emit(
        state.copyWith(
          startingLocalMedia: false,
          status: () => 'Failed to start camera and microphone.',
        ),
      );
      rethrow;
    }
  }

  // ── Helpers: signaling ────────────────────────────────────────────────────

  Future<void> _confirmConnection() async {
    try {
      final offer = state.peerOffer;
      if (offer != null) {
        await _peerSignaling.confirm(offer);
      } else if (state.hostSession case final hostSession?) {
        await hostSession.confirm();
      }
    } catch (error, stackTrace) {
      _recordLog('signaling.confirm.failed type=${error.runtimeType}');
      addError(error, stackTrace);
    }
  }

  Future<void> _reclaimDeposits([PeerHostSession? capturedSession]) {
    final hostSession = capturedSession ?? state.hostSession;
    if (hostSession == null) return Future<void>.value();

    return _teardownHostSession(hostSession);
  }

  Future<void> _teardownHostSession(PeerHostSession hostSession) async {
    try {
      await hostSession.teardown();
    } catch (error, stack) {
      _recordLog('host.reclaim.failed type=${error.runtimeType}');
      addError(error, stack);
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  Future<void> _disposeWebRtc() async {
    await _mediaSession.dispose();
  }

  Future<void> _disposeMediaBestEffort() async {
    try {
      await _disposeWebRtc();
    } on Object catch (error, stack) {
      _recordLog('media.dispose.failed type=${error.runtimeType}');
      addError(error, stack);
    }
  }

  Future<void> _closeMediaBestEffort() async {
    try {
      await _mediaSession.close();
    } on Object catch (error, stack) {
      _recordLog('media.close.failed type=${error.runtimeType}');
      addError(error, stack);
    }
  }

  void _recordLogExpectedFailure(Object error) {
    _recordLog('expected_failure type=${error.runtimeType}');
  }

  void _reportUnexpectedFailure(
    Object error,
    StackTrace stackTrace, {
    required String message,
  }) {
    emitAction(ShowStatusMessageAction(message));
    addError(error, stackTrace);
  }

  void _recordLog(String event) => log(
    event,
    name: 'Call',
  );
}
