import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:signaling/signaling.dart';
import 'package:video_player/video_player.dart';

import 'core/di/app_scope.dart';
import 'core/event_bus/app_event_bus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deps = await AppDependencies.build();
  runApp(
    AppScope(
      signaling: deps.signaling,
      deps: deps,
      child: const SolsStreamMwpApp(),
    ),
  );
}

enum TransportMode { webrtc, hls }

enum WebRtcRole { publisher, viewer }

class SolsStreamMwpApp extends StatelessWidget {
  const SolsStreamMwpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'sols.stream MWP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff00a86b),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xff101214),
        useMaterial3: true,
      ),
      home: const StreamMwpHome(),
    );
  }
}

class StreamMwpHome extends StatefulWidget {
  const StreamMwpHome({super.key});

  @override
  State<StreamMwpHome> createState() => _StreamMwpHomeState();
}

class _StreamMwpHomeState extends State<StreamMwpHome> {
  // ── Renderers ────────────────────────────────────────────────────────────
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  // ── WebRTC config controllers ─────────────────────────────────────────────
  final _stunTurnUrlsController = TextEditingController(
    text: 'stun:stun.l.google.com:19302',
  );
  final _turnUsernameController = TextEditingController();
  final _turnPasswordController = TextEditingController();

  // ── HLS controllers ───────────────────────────────────────────────────────
  final _hlsUrlController = TextEditingController();
  final _hlsUsernameController = TextEditingController();
  final _hlsPasswordController = TextEditingController();
  final _hlsTokenController = TextEditingController();

  // ── Viewer connection link ────────────────────────────────────────────────
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
  SolanaSignaling? _signaling;
  SignalingSession? _signalingSession;
  FetchedOffer? _fetchedOffer;
  bool _goingLive = false;
  bool _connecting = false;
  StreamSubscription<String>? _answerSub;

  // ── Status ────────────────────────────────────────────────────────────────
  String _rtcState = 'Idle';
  String? _status;

  // ── Wallet UI ─────────────────────────────────────────────────────────────
  bool _walletExpanded = false;
  int _walletBalance = 0;

  bool get _hlsSupported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_signaling == null) {
      _signaling = AppScope.of(context).signaling;
      _refreshBalance();
    }
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    if (!mounted) return;
    setState(() => _renderersReady = true);
  }

  Future<void> _refreshBalance() async {
    try {
      final balance = await _signaling!.getBalance();
      if (!mounted) return;
      setState(() => _walletBalance = balance);
    } catch (_) {}
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

  // ── WebRTC core (unchanged) ───────────────────────────────────────────────

  Future<void> _disposeWebRtc() async {
    _remoteRenderer.srcObject = null;
    _localRenderer.srcObject = null;
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
    final pc = await createPeerConnection(_buildRtcConfiguration());
    await _attachPeerConnectionHandlers(pc);
    await _addLocalTracks(pc);
    _peerConnection = pc;
    return pc;
  }

  Map<String, dynamic> _buildRtcConfiguration() {
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

  Future<void> _attachPeerConnectionHandlers(RTCPeerConnection pc) async {
    pc.onConnectionState = (state) {
      if (!mounted) return;
      setState(() {
        _rtcState = state.name;
        _status = 'Peer connection: ${state.name}';
      });
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        AppEventBus.instance.emit(const PeerConnectedEvent());
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

  Future<void> _rebuildPeerConnection({
    required bool keepRemoteDescription,
  }) async {
    final previous = _peerConnection;
    final remoteDesc = keepRemoteDescription && previous != null
        ? await previous.getRemoteDescription()
        : null;
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
    if (pc.iceGatheringState ==
        RTCIceGatheringState.RTCIceGatheringStateComplete) { return; }
    final completer = Completer<void>();
    pc.onIceGatheringState = (state) {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete &&
          !completer.isCompleted) {
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
    for (final track in _localStream?.getAudioTracks() ?? []) {
      track.enabled = next;
    }
    setState(() => _micEnabled = next);
  }

  void _toggleCamera() {
    final next = !_cameraEnabled;
    for (final track in _localStream?.getVideoTracks() ?? []) {
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
      final session = await _signaling!.goLive(offerJson);

      setState(() {
        _signalingSession = session;
        _goingLive = false;
        _status = 'Waiting for viewer to connect…';
      });

      AppEventBus.instance.emit(StreamStartedEvent(session.url));
      _answerSub = _signaling!.watchForAnswer(session).listen(
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
      final offer = await _signaling!.fetchOffer(url);
      _fetchedOffer = offer;

      setState(() => _status = 'Creating answer…');
      final answerJson = await _createRawAnswer(offer.sdpOffer);

      setState(() => _status = 'Writing answer to Solana…');
      await _signaling!.submitAnswer(offer, answerJson);

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
      controller.setLooping(false);
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

  List<String> _splitLines(String input) => input
      .split(RegExp(r'[\n,]'))
      .map((v) => v.trim())
      .where((v) => v.isNotEmpty)
      .toList();

  // ── Disconnect ────────────────────────────────────────────────────────────

  Future<void> _disconnect() async {
    _answerSub?.cancel();
    _answerSub = null;
    _signalingSession = null;
    _fetchedOffer = null;
    await _disposeWebRtc();
    if (!mounted) return;
    setState(() {
      _status = 'Disconnected.';
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('sols.stream MWP'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1100;
            final viewport = _Panel(
              title: 'Viewport',
              child: _buildViewportSection(),
            );
            final controls = _Panel(
              title: 'Connection',
              child: _buildControlSection(),
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

  // ── Viewport ──────────────────────────────────────────────────────────────

  Widget _buildViewportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ColoredBox(color: Colors.black, child: _buildViewport()),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              avatar: const Icon(Icons.network_check, size: 18),
              label: Text(_rtcState),
            ),
            if (_transportMode == TransportMode.webrtc) ...[
              FilterChip(
                selected: _micEnabled,
                onSelected: _localStream == null ? null : (_) => _toggleMic(),
                label: Text(_micEnabled ? 'Mic on' : 'Mic off'),
              ),
              FilterChip(
                selected: _cameraEnabled,
                onSelected:
                    _localStream == null ? null : (_) => _toggleCamera(),
                label: Text(_cameraEnabled ? 'Camera on' : 'Camera off'),
              ),
              FilterChip(
                selected: _showLocalPreviewPip,
                onSelected: _remoteVideoAvailable && _localStream != null
                    ? (v) => setState(() => _showLocalPreviewPip = v)
                    : null,
                label: const Text('Local PiP'),
              ),
            ],
          ],
        ),
        if (_status != null) ...[
          const SizedBox(height: 8),
          Text(
            _status!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildViewport() {
    if (_transportMode == TransportMode.hls) {
      final controller = _videoController;
      if (controller == null || !controller.value.isInitialized) {
        return const _ViewportPlaceholder(
          title: 'HLS / LL-HLS',
          subtitle: 'Enter a stream URL and tap Play.',
        );
      }
      return FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      );
    }

    final hasLocal = _localStream != null;
    final showRemote = _remoteVideoAvailable;

    if (!showRemote && !hasLocal) {
      return _ViewportPlaceholder(
        title: 'WebRTC',
        subtitle: _webRtcRole == WebRtcRole.publisher
            ? 'Tap "Go Live" to start broadcasting.'
            : 'Paste a connection link and tap "Connect".',
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        RTCVideoView(
          showRemote ? _remoteRenderer : _localRenderer,
          mirror: !showRemote,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
        ),
        if (showRemote && hasLocal && _showLocalPreviewPip)
          Positioned(
            right: 12,
            bottom: 12,
            child: SizedBox(
              width: 180,
              height: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: RTCVideoView(
                    _localRenderer,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Control section ───────────────────────────────────────────────────────

  Widget _buildControlSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<TransportMode>(
            segments: const [
              ButtonSegment(value: TransportMode.webrtc, label: Text('WebRTC')),
              ButtonSegment(
                  value: TransportMode.hls, label: Text('HLS / LL-HLS')),
            ],
            selected: {_transportMode},
            onSelectionChanged: (v) => _setTransportMode(v.first),
          ),
          const SizedBox(height: 16),
          if (_transportMode == TransportMode.webrtc)
            _buildWebRtcControls()
          else
            _buildHlsControls(),
          const SizedBox(height: 16),
          _buildWalletTile(),
        ],
      ),
    );
  }

  // ── WebRTC controls ───────────────────────────────────────────────────────

  Widget _buildWebRtcControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<WebRtcRole>(
          segments: const [
            ButtonSegment(
                value: WebRtcRole.publisher, label: Text('Publisher')),
            ButtonSegment(value: WebRtcRole.viewer, label: Text('Viewer')),
          ],
          selected: {_webRtcRole},
          onSelectionChanged: (v) => setState(() => _webRtcRole = v.first),
        ),
        const SizedBox(height: 16),
        if (_webRtcRole == WebRtcRole.publisher)
          _buildPublisherControls()
        else
          _buildViewerControls(),
        const SizedBox(height: 12),
        _buildStunTurnSection(),
        const SizedBox(height: 12),
        if (_localStream != null)
          FilledButton.tonalIcon(
            onPressed: _disconnect,
            icon: const Icon(Icons.call_end),
            label: const Text('Disconnect'),
          ),
      ],
    );
  }

  Widget _buildPublisherControls() {
    final session = _signalingSession;
    if (session != null) {
      // Live — show QR + URL
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '🔴 Live',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.redAccent),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share this link or QR with the viewer:',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Center(
            child: QrImageView(data: session.url, size: 180),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  session.url,
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                tooltip: 'Copy link',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: session.url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied')),
                  );
                },
              ),
            ],
          ),
        ],
      );
    }

    return FilledButton.icon(
      onPressed: _goingLive ? null : _goLive,
      icon: _goingLive
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.stream),
      label: Text(_goingLive ? 'Going live…' : 'Go Live'),
    );
  }

  Widget _buildViewerControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LabeledField(
          label: 'Connection link',
          child: TextField(
            controller: _connectionLinkController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'sols://connect?host=…',
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _connecting ? null : _connectAsViewer,
          icon: _connecting
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.call),
          label: Text(_connecting ? 'Connecting…' : 'Connect'),
        ),
      ],
    );
  }

  Widget _buildStunTurnSection() {
    return ExpansionTile(
      title: const Text('STUN / TURN settings'),
      initiallyExpanded: false,
      children: [
        _LabeledField(
          label: 'STUN / TURN URLs',
          child: TextField(
            controller: _stunTurnUrlsController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'One per line or comma-separated',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _LabeledField(
                label: 'Username',
                child: TextField(
                  controller: _turnUsernameController,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _LabeledField(
                label: 'Password',
                child: TextField(
                  controller: _turnPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── HLS controls ──────────────────────────────────────────────────────────

  Widget _buildHlsControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_hlsSupported)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'HLS is available on Android, iOS, macOS and Web.',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        _LabeledField(
          label: 'Stream URL',
          child: TextField(
            controller: _hlsUrlController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'https://example.com/live/master.m3u8',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _LabeledField(
                label: 'Username',
                child: TextField(
                  controller: _hlsUsernameController,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _LabeledField(
                label: 'Password',
                child: TextField(
                  controller: _hlsPasswordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'Token',
          child: TextField(
            controller: _hlsTokenController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: !_hlsSupported || _isStartingHls ? null : _playHls,
              icon: _isStartingHls
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: const Text('Play'),
            ),
            FilledButton.tonalIcon(
              onPressed: _stopHls,
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
            ),
          ],
        ),
      ],
    );
  }

  // ── Wallet tile ───────────────────────────────────────────────────────────

  Widget _buildWalletTile() {
    final sig = _signaling;
    if (sig == null) return const SizedBox.shrink();
    final address = sig.walletAddress;
    final shortAddr = address.length > 12
        ? '${address.substring(0, 6)}…${address.substring(address.length - 4)}'
        : address;
    final solBalance = _walletBalance / 1e9;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xff1a1d20),
        border: Border.all(color: const Color(0xff2a3036)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet, size: 18),
            const SizedBox(width: 8),
            Text('Wallet · $shortAddr'),
            const Spacer(),
            Text('${solBalance.toStringAsFixed(4)} SOL'),
          ],
        ),
        initiallyExpanded: _walletExpanded,
        onExpansionChanged: (v) async {
          setState(() => _walletExpanded = v);
          if (v) await _refreshBalance();
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SelectableText(address,
                    style: const TextStyle(fontSize: 12, color: Colors.white54)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy address'),
                      onPressed: () =>
                          Clipboard.setData(ClipboardData(text: address)),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Refresh'),
                      onPressed: _refreshBalance,
                    ),
                  ],
                ),
                const Text(
                  'Network: Solana devnet\nMin balance for transactions: 0.002 SOL',
                  style: TextStyle(fontSize: 11, color: Colors.white38),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _ViewportPlaceholder extends StatelessWidget {
  const _ViewportPlaceholder({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xff171a1d),
        border: Border.all(color: const Color(0xff2a3036)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
