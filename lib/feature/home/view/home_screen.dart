import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:signaling/signaling.dart';
import 'package:solana_wallet/solana_wallet.dart';
import 'package:sols_stream/core/event_bus/app_event_bus.dart';
import 'package:sols_stream/core/event_bus/events/stream_domain_event.dart';
import 'package:sols_stream/feature/app/di/app_scope.dart';
import 'package:sols_stream/feature/home/view/enums/home_intent.dart';
import 'package:sols_stream/feature/home/view/enums/transport_mode.dart';
import 'package:sols_stream/feature/home/view/enums/web_rtc_role.dart';
import 'package:sols_stream/feature/home/view/widgets/control_section.dart';
import 'package:sols_stream/feature/home/view/widgets/hls_controls.dart';
import 'package:sols_stream/feature/home/view/widgets/panel.dart';
import 'package:sols_stream/feature/home/view/widgets/publisher_controls.dart';
import 'package:sols_stream/feature/home/view/widgets/stream_viewport.dart';
import 'package:sols_stream/feature/home/view/widgets/stun_turn_section.dart';
import 'package:sols_stream/feature/home/view/widgets/viewer_controls.dart';
import 'package:sols_stream/feature/home/view/widgets/viewport_section.dart';
import 'package:sols_stream/feature/home/view/widgets/wallet_tile.dart';
import 'package:sols_stream/feature/home/view/widgets/webrtc_controls.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.intent = HomeIntent.stream});

  final HomeIntent intent;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Renderers ─────────────────────────────────────────────────────────────
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  // ── WebRTC config controllers ──────────────────────────────────────────────
  final _stunTurnUrlsController = TextEditingController(
    text: 'stun:stun.l.google.com:19302',
  );
  final _turnUsernameController = TextEditingController();
  final _turnPasswordController = TextEditingController();

  // ── HLS controllers ────────────────────────────────────────────────────────
  final _hlsUrlController = TextEditingController();
  final _hlsUsernameController = TextEditingController();
  final _hlsPasswordController = TextEditingController();
  final _hlsTokenController = TextEditingController();

  // ── Viewer connection link ─────────────────────────────────────────────────
  final _connectionLinkController = TextEditingController();

  // ── Mode / role ───────────────────────────────────────────────────────────
  TransportMode _transportMode = TransportMode.webrtc;
  WebRtcRole _webRtcRole = WebRtcRole.publisher;

  // ── WebRTC state ──────────────────────────────────────────────────────────
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  bool _renderersReady = false;
  bool _startingLocalMedia = false;
  bool _remoteVideoAvailable = false;
  bool _showLocalPreviewPip = true;
  bool _micEnabled = true;
  bool _cameraEnabled = true;

  // ── HLS ───────────────────────────────────────────────────────────────────
  VideoPlayerController? _videoController;
  bool _isStartingHls = false;

  // ── Signaling ─────────────────────────────────────────────────────────────
  late AppEventBus _eventBus;
  SolanaSignaling? _signaling;
  WalletAccount? _walletAccount;
  SignalingSession? _signalingSession;
  FetchedOffer? _fetchedOffer;
  bool _goingLive = false;
  bool _connecting = false;
  StreamSubscription<String>? _answerSub;

  // ── Status ────────────────────────────────────────────────────────────────
  String _rtcState = 'Idle';
  String? _status;

  // ── Wallet UI ─────────────────────────────────────────────────────────────
  int _walletBalance = 0;

  bool get _hlsSupported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  void initState() {
    super.initState();
    switch (widget.intent) {
      case HomeIntent.joinRoom:
        _webRtcRole = WebRtcRole.viewer;
      case HomeIntent.stream:
      case HomeIntent.p2pCall:
        _webRtcRole = WebRtcRole.publisher;
    }
    _initRenderers();
  }

  // ── Init / balance ────────────────────────────────────────────────────────

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    if (!mounted) return;

    setState(() => _renderersReady = true);
  }

  Future<void> _refreshBalance() async {
    final account = _walletAccount;
    if (account == null) return;

    try {
      final balance = await account.getBalance();
      if (!mounted) return;

      setState(() => _walletBalance = balance);
    } on Exception catch (e) {
      log('Balance refresh failed: $e', name: 'HomeScreen');
    }
  }

  // ── WebRTC core ───────────────────────────────────────────────────────────

  Future<void> _disposeWebRtc() async {
    if (_renderersReady) {
      _remoteRenderer.srcObject = null;
      _localRenderer.srcObject = null;
    }
    _remoteVideoAvailable = false;
    final stream = _localStream;
    _localStream = null;
    for (final track in stream?.getTracks() ?? <MediaStreamTrack>[]) {
      await track.stop();
    }
    await stream?.dispose();
    await _peerConnection?.close();
    _peerConnection = null;
    if (!mounted) return;

    setState(() {
      _micEnabled = true;
      _cameraEnabled = true;
      _rtcState = 'Idle';
    });
  }

  Future<void> _disposeHls() async {
    final controller = _videoController;
    _videoController = null;
    await controller?.dispose();
  }

  Future<void> _setTransportMode(TransportMode mode) async {
    if (_transportMode == mode) return;

    if (mode == TransportMode.webrtc) {
      await _disposeHls();
    } else {
      await _disposeWebRtc();
    }
    if (!mounted) return;

    setState(() {
      _transportMode = mode;
      _status = null;
    });
  }

  Future<void> _startLocalMedia() async {
    if (_startingLocalMedia || !_renderersReady) return;

    if (_localStream != null) {
      setState(() => _status = 'Local media already started.');

      return;
    }
    setState(() {
      _startingLocalMedia = true;
      _status = 'Starting camera and mic…';
    });
    try {
      final stream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
          'frameRate': {'ideal': 30},
          'facingMode': 'user',
        },
      });
      _localRenderer.srcObject = stream;
      _localStream = stream;
      if (_peerConnection != null) {
        await _rebuildPeerConnection(keepRemoteDescription: true);
      }
      if (!mounted) return;

      setState(() {
        _startingLocalMedia = false;
        _status = 'Camera and mic ready.';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _startingLocalMedia = false;
        _status = 'Failed to start media: $error';
      });
    }
  }

  Future<RTCPeerConnection> _ensurePeerConnection() async {
    if (_peerConnection != null) return _peerConnection!;

    final pc = await createPeerConnection(_rtcConfiguration());
    _attachPeerConnectionHandlers(pc);
    await _addLocalTracks(pc);
    _peerConnection = pc;

    return pc;
  }

  Map<String, dynamic> _rtcConfiguration() {
    final urls = _splitLines(_stunTurnUrlsController.text);
    final iceServers = <Map<String, dynamic>>[];
    for (final url in urls) {
      final server = <String, dynamic>{'urls': url};
      if (url.startsWith('turn:') || url.startsWith('turns:')) {
        if (_turnUsernameController.text.trim().isNotEmpty) {
          server['username'] = _turnUsernameController.text.trim();
        }
        if (_turnPasswordController.text.trim().isNotEmpty) {
          server['credential'] = _turnPasswordController.text.trim();
        }
      }
      iceServers.add(server);
    }

    return {'iceServers': iceServers, 'sdpSemantics': 'unified-plan'};
  }

  void _attachPeerConnectionHandlers(RTCPeerConnection pc) {
    pc.onConnectionState = (state) {
      if (!mounted) return;
      setState(() {
        _rtcState = state.name;
        _status = 'Peer connection: ${state.name}';
      });
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _eventBus.emit(const PeerConnectedEvent());
        final session = _signalingSession;
        final offer = _fetchedOffer;
        final slotPda = session?.slotPda ?? offer?.slotPda;
        if (slotPda != null) {
          _signaling?.confirmConnection(slotPda);
        }
      }
    };
    pc.onTrack = (event) {
      if (event.streams.isEmpty) return;
      _remoteRenderer.srcObject = event.streams.first;
      if (!mounted) return;
      setState(() {
        _remoteVideoAvailable = true;
        _status = 'Remote track received.';
      });
    };
  }

  Future<void> _addLocalTracks(RTCPeerConnection pc) async {
    final stream = _localStream;
    if (stream == null) return;

    final senders = await pc.getSenders();
    final senderTrackIds = senders.map((s) => s.track?.id).toSet();
    for (final track in stream.getTracks()) {
      if (!senderTrackIds.contains(track.id)) {
        await pc.addTrack(track, stream);
      }
    }
  }

  Future<void> _rebuildPeerConnection({required bool keepRemoteDescription}) async {
    final previous = _peerConnection;
    final remoteDesc = keepRemoteDescription && previous != null ? await previous.getRemoteDescription() : null;
    await previous?.close();
    _peerConnection = null;
    _remoteVideoAvailable = false;
    _remoteRenderer.srcObject = null;
    final pc = await _ensurePeerConnection();
    if (remoteDesc != null) await pc.setRemoteDescription(remoteDesc);
  }

  Future<String> _createRawOffer() async {
    final pc = await _ensurePeerConnection();
    final offer = await pc.createOffer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': true,
    });
    await pc.setLocalDescription(offer);
    await _waitForIceGathering(pc);
    final desc = await pc.getLocalDescription();
    if (desc == null) throw StateError('Local offer missing after gathering.');

    return jsonEncode({'type': desc.type, 'sdp': desc.sdp});
  }

  Future<String> _createRawAnswer(String remoteOfferJson) async {
    final pc = await _ensurePeerConnection();
    final parsed = jsonDecode(remoteOfferJson) as Map<String, dynamic>;
    await pc.setRemoteDescription(
      RTCSessionDescription(parsed['sdp'] as String, parsed['type'] as String),
    );
    final answer = await pc.createAnswer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': true,
    });
    await pc.setLocalDescription(answer);
    await _waitForIceGathering(pc);
    final desc = await pc.getLocalDescription();
    if (desc == null) throw StateError('Local answer missing after gathering.');

    return jsonEncode({'type': desc.type, 'sdp': desc.sdp});
  }

  Future<void> _waitForIceGathering(RTCPeerConnection pc) async {
    if (pc.iceGatheringState == RTCIceGatheringState.RTCIceGatheringStateComplete) {
      return;
    }
    final completer = Completer<void>();
    pc.onIceGatheringState = (state) {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete && !completer.isCompleted) {
        completer.complete();
      }
    };
    Future<void>.delayed(const Duration(seconds: 5), () {
      if (!completer.isCompleted) completer.complete();
    });
    await completer.future;
    pc.onIceGatheringState = null;
  }

  void _toggleMic() {
    final next = !_micEnabled;
    for (final MediaStreamTrack track in _localStream?.getAudioTracks() ?? []) {
      track.enabled = next;
    }
    setState(() => _micEnabled = next);
  }

  void _toggleCamera() {
    final next = !_cameraEnabled;
    for (final MediaStreamTrack track in _localStream?.getVideoTracks() ?? []) {
      track.enabled = next;
    }
    setState(() => _cameraEnabled = next);
  }

  // ── Publisher flow ────────────────────────────────────────────────────────

  Future<void> _goLive() async {
    if (_goingLive) return;

    setState(() {
      _goingLive = true;
      _status = 'Starting camera and mic…';
    });
    try {
      await _startLocalMedia();
      setState(() => _status = 'Creating offer…');
      final offerJson = await _createRawOffer();

      setState(() => _status = 'Writing offer to Solana…');
      final session = await (_signaling ?? (throw StateError('Signaling not initialized'))).goLive(offerJson);

      setState(() {
        _signalingSession = session;
        _goingLive = false;
        _status = 'Waiting for viewer to connect…';
      });

      _eventBus.emit(const StreamStartedEvent());
      _answerSub = (_signaling ?? (throw StateError('Signaling not initialized')))
          .watchForAnswer(session)
          .listen(
            _onAnswerReceived,
            onError: (Object e) {
              if (!mounted) return;
              setState(() => _status = 'Signaling error: $e');
            },
          );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _goingLive = false;
        _status = 'Go Live failed: $e';
      });
    }
  }

  Future<void> _onAnswerReceived(String answerJson) async {
    if (!mounted) return;

    setState(() => _status = 'Viewer connected — establishing media…');
    try {
      final pc = await _ensurePeerConnection();
      final parsed = jsonDecode(answerJson) as Map<String, dynamic>;
      await pc.setRemoteDescription(
        RTCSessionDescription(parsed['sdp'] as String, parsed['type'] as String),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _status = 'Apply answer failed: $e');
    }
  }

  // ── Viewer flow ───────────────────────────────────────────────────────────

  Future<void> _connectAsViewer() async {
    final url = _connectionLinkController.text.trim();
    if (url.isEmpty) {
      setState(() => _status = 'Paste a connection link first.');

      return;
    }
    if (_connecting) return;

    setState(() {
      _connecting = true;
      _status = 'Starting camera and mic…';
    });
    try {
      await _startLocalMedia();
      setState(() => _status = 'Fetching offer from Solana…');
      final offer = await (_signaling ?? (throw StateError('Signaling not initialized'))).fetchOffer(url);
      _fetchedOffer = offer;

      setState(() => _status = 'Creating answer…');
      final answerJson = await _createRawAnswer(offer.sdpOffer);

      setState(() => _status = 'Writing answer to Solana…');
      await (_signaling ?? (throw StateError('Signaling not initialized'))).submitAnswer(offer, answerJson);

      if (!mounted) return;

      setState(() {
        _connecting = false;
        _status = 'Answer sent — waiting for media…';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _connecting = false;
        _status = 'Connect failed: $e';
      });
    }
  }

  // ── HLS ───────────────────────────────────────────────────────────────────

  Future<void> _playHls() async {
    if (!_hlsSupported) {
      setState(() => _status = 'HLS not supported on this platform.');

      return;
    }
    final url = _hlsUrlController.text.trim();
    if (url.isEmpty) {
      setState(() => _status = 'Stream URL is empty.');

      return;
    }
    setState(() {
      _isStartingHls = true;
      _status = 'Starting HLS playback…';
    });
    try {
      await _disposeWebRtc();
      await _disposeHls();
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: _buildHlsHeaders(),
      );
      await controller.initialize();
      await controller.play();
      unawaited(controller.setLooping(false));
      _videoController = controller;
      if (!mounted) return;

      setState(() {
        _isStartingHls = false;
        _status = 'HLS playback started.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isStartingHls = false;
        _status = 'HLS playback failed: $e';
      });
    }
  }

  Future<void> _stopHls() async {
    await _disposeHls();
    if (!mounted) return;

    setState(() => _status = 'HLS stopped.');
  }

  Map<String, String> _buildHlsHeaders() {
    final headers = <String, String>{};
    final username = _hlsUsernameController.text.trim();
    final password = _hlsPasswordController.text.trim();
    final token = _hlsTokenController.text.trim();
    if (username.isNotEmpty || password.isNotEmpty) {
      final creds = base64Encode(utf8.encode('$username:$password'));
      headers['Authorization'] = 'Basic $creds';
    } else if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  List<String> _splitLines(String input) =>
      input.split(RegExp(r'[\n,]')).map((v) => v.trim()).where((v) => v.isNotEmpty).toList();

  // ── Disconnect ────────────────────────────────────────────────────────────

  Future<void> _disconnect() async {
    unawaited(_answerSub?.cancel());
    _answerSub = null;

    // Best-effort on-chain deposit reclaim before the handles are dropped. Runs
    // fire-and-forget: the reclaim methods never throw and we must not block the
    // teardown UI on the network round-trips.
    _reclaimDeposits();

    _signalingSession = null;
    _fetchedOffer = null;
    await _disposeWebRtc();
    if (!mounted) return;

    setState(() => _status = 'Disconnected.');
  }

  void _reclaimDeposits() {
    final signaling = _signaling;
    if (signaling == null) return;

    final session = _signalingSession;
    final offer = _fetchedOffer;
    if (_webRtcRole == WebRtcRole.publisher && session != null) {
      unawaited(signaling.stopAndReclaim(session));
    } else if (_webRtcRole == WebRtcRole.viewer && offer != null) {
      unawaited(signaling.leaveAndReclaim(offer));
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _eventBus = AppScope.of(context).eventBus;
    if (_signaling == null) {
      _signaling = AppScope.of(context).signaling;
      _walletAccount = AppScope.of(context).walletAccount;
      _refreshBalance();
    }
  }

  @override
  void dispose() {
    _stunTurnUrlsController.dispose();
    _turnUsernameController.dispose();
    _turnPasswordController.dispose();
    _hlsUrlController.dispose();
    _hlsUsernameController.dispose();
    _hlsPasswordController.dispose();
    _hlsTokenController.dispose();
    _connectionLinkController.dispose();
    _answerSub?.cancel();
    _disposeWebRtc();
    _disposeHls();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('sols.stream'),
      backgroundColor: Colors.transparent,
    ),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1100;
          final viewport = Panel(
            title: 'Viewport',
            child: ViewportSection(
              rtcState: _rtcState,
              transportMode: _transportMode,
              micEnabled: _micEnabled,
              cameraEnabled: _cameraEnabled,
              localStreamActive: _localStream != null,
              remoteVideoAvailable: _remoteVideoAvailable,
              showLocalPreviewPip: _showLocalPreviewPip,
              onToggleMic: _toggleMic,
              onToggleCamera: _toggleCamera,
              onTogglePip: (v) => setState(() => _showLocalPreviewPip = v),
              status: _status,
              viewport: StreamViewport(
                transportMode: _transportMode,
                webRtcRole: _webRtcRole,
                videoController: _videoController,
                localStreamActive: _localStream != null,
                remoteVideoAvailable: _remoteVideoAvailable,
                showLocalPreviewPip: _showLocalPreviewPip,
                localRenderer: _localRenderer,
                remoteRenderer: _remoteRenderer,
              ),
            ),
          );
          final controls = Panel(
            title: 'Connection',
            child: ControlSection(
              transportMode: _transportMode,
              onTransportChanged: _setTransportMode,
              webRtcControls: WebRtcControls(
                role: _webRtcRole,
                onRoleChanged: (r) => setState(() => _webRtcRole = r),
                hasLocalStream: _localStream != null,
                onDisconnect: _disconnect,
                publisherControls: PublisherControls(
                  session: _signalingSession,
                  goingLive: _goingLive,
                  onGoLive: _goLive,
                ),
                viewerControls: ViewerControls(
                  connectionLinkController: _connectionLinkController,
                  connecting: _connecting,
                  onConnect: _connectAsViewer,
                ),
                stunTurnSection: StunTurnSection(
                  urlsController: _stunTurnUrlsController,
                  usernameController: _turnUsernameController,
                  passwordController: _turnPasswordController,
                ),
              ),
              hlsControls: HlsControls(
                hlsSupported: _hlsSupported,
                isStartingHls: _isStartingHls,
                urlController: _hlsUrlController,
                usernameController: _hlsUsernameController,
                passwordController: _hlsPasswordController,
                tokenController: _hlsTokenController,
                onPlay: _playHls,
                onStop: _stopHls,
              ),
              walletTile: WalletTile(
                walletAccount: _walletAccount,
                walletBalance: _walletBalance,
                onRefresh: _refreshBalance,
              ),
            ),
          );

          return Padding(
            padding: const EdgeInsets.all(16),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 3, child: viewport),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: controls),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 3, child: viewport),
                      const SizedBox(height: 16),
                      Expanded(flex: 4, child: controls),
                    ],
                  ),
          );
        },
      ),
    ),
  );
}
