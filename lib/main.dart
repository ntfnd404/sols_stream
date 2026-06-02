import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SolsStreamMwpApp());
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff00a86b), brightness: Brightness.dark),
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
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  final _stunTurnUrlsController = TextEditingController(text: 'stun:stun.l.google.com:19302');
  final _turnUsernameController = TextEditingController();
  final _turnPasswordController = TextEditingController();
  final _sessionController = TextEditingController();
  final _webRtcTokenController = TextEditingController();
  final _localSdpController = TextEditingController();
  final _remoteSdpController = TextEditingController();

  final _hlsUrlController = TextEditingController();
  final _hlsUsernameController = TextEditingController();
  final _hlsPasswordController = TextEditingController();
  final _hlsTokenController = TextEditingController();

  TransportMode _transportMode = TransportMode.webrtc;
  WebRtcRole _webRtcRole = WebRtcRole.publisher;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  bool _renderersReady = false;
  bool _startingLocalMedia = false;
  bool _remoteVideoAvailable = false;
  bool _showLocalPreviewPip = true;
  bool _micEnabled = true;
  bool _cameraEnabled = true;

  VideoPlayerController? _videoController;
  bool _isStartingHls = false;

  String _rtcState = 'Idle';
  String? _status;

  bool get _hlsSupported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    if (!mounted) return;
    setState(() => _renderersReady = true);
  }

  @override
  void dispose() {
    _stunTurnUrlsController.dispose();
    _turnUsernameController.dispose();
    _turnPasswordController.dispose();
    _sessionController.dispose();
    _webRtcTokenController.dispose();
    _localSdpController.dispose();
    _remoteSdpController.dispose();
    _hlsUrlController.dispose();
    _hlsUsernameController.dispose();
    _hlsPasswordController.dispose();
    _hlsTokenController.dispose();
    _disposeWebRtc();
    _disposeHls();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

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
      _status = 'Starting local media...';
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
        _status = 'Local media started.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _startingLocalMedia = false;
        _status = 'Failed to start local media: $error';
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
    return <String, dynamic>{'iceServers': iceServers, 'sdpSemantics': 'unified-plan'};
  }

  Future<void> _attachPeerConnectionHandlers(RTCPeerConnection pc) async {
    pc.onConnectionState = (state) {
      if (!mounted) return;
      setState(() {
        _rtcState = state.name;
        _status = 'Peer connection: ${state.name}';
      });
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
    final remoteDescription = keepRemoteDescription && previous != null ? await previous.getRemoteDescription() : null;
    await previous?.close();
    _peerConnection = null;
    _remoteVideoAvailable = false;
    _remoteRenderer.srcObject = null;

    final pc = await _ensurePeerConnection();
    if (remoteDescription != null) {
      await pc.setRemoteDescription(remoteDescription);
    }
  }

  Future<void> _createOffer() async {
    try {
      final pc = await _ensurePeerConnection();
      final offer = await pc.createOffer({'offerToReceiveAudio': true, 'offerToReceiveVideo': true});
      await pc.setLocalDescription(offer);
      await _waitForIceGathering(pc);
      final localDescription = await pc.getLocalDescription();
      if (localDescription == null) {
        throw StateError('Local offer is missing after gathering.');
      }
      _localSdpController.text = _encodeSdp(localDescription);
      if (!mounted) return;
      setState(() => _status = 'Offer ready.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = 'Create offer failed: $error');
    }
  }

  Future<void> _createAnswer() async {
    try {
      final pc = await _ensurePeerConnection();
      if (await pc.getRemoteDescription() == null) {
        await _applyRemoteSdp(setStatus: false);
      }
      final answer = await pc.createAnswer({'offerToReceiveAudio': true, 'offerToReceiveVideo': true});
      await pc.setLocalDescription(answer);
      await _waitForIceGathering(pc);
      final localDescription = await pc.getLocalDescription();
      if (localDescription == null) {
        throw StateError('Local answer is missing after gathering.');
      }
      _localSdpController.text = _encodeSdp(localDescription);
      if (!mounted) return;
      setState(() => _status = 'Answer ready.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = 'Create answer failed: $error');
    }
  }

  Future<void> _applyRemoteSdp({bool setStatus = true}) async {
    final raw = _remoteSdpController.text.trim();
    if (raw.isEmpty) {
      if (mounted && setStatus) {
        setState(() => _status = 'Remote SDP is empty.');
      }
      return;
    }

    try {
      final pc = await _ensurePeerConnection();
      final desc = _decodeSdp(raw);
      await pc.setRemoteDescription(desc);
      if (!mounted || !setStatus) return;
      setState(() => _status = 'Remote SDP applied.');
    } catch (error) {
      if (!mounted || !setStatus) return;
      setState(() => _status = 'Apply remote SDP failed: $error');
    }
  }

  Future<void> _copyLocalSdp() async {
    final text = _localSdpController.text.trim();
    if (text.isEmpty) {
      setState(() => _status = 'Local SDP is empty.');
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    setState(() => _status = 'Local SDP copied.');
  }

  Future<void> _disconnectWebRtc() async {
    await _disposeWebRtc();
    _localSdpController.clear();
    _remoteSdpController.clear();
    if (!mounted) return;
    setState(() => _status = 'WebRTC disconnected.');
  }

  void _toggleMic() {
    final next = !_micEnabled;
    for (final track in _localStream?.getAudioTracks() ?? const <MediaStreamTrack>[]) {
      track.enabled = next;
    }
    setState(() => _micEnabled = next);
  }

  void _toggleCamera() {
    final next = !_cameraEnabled;
    for (final track in _localStream?.getVideoTracks() ?? const <MediaStreamTrack>[]) {
      track.enabled = next;
    }
    setState(() => _cameraEnabled = next);
  }

  Future<void> _playHls() async {
    if (!_hlsSupported) {
      setState(() {
        _status = 'HLS playback via video_player is not supported on this platform.';
      });
      return;
    }

    final streamUrl = _hlsUrlController.text.trim();
    if (streamUrl.isEmpty) {
      setState(() => _status = 'Stream URL is empty.');
      return;
    }

    setState(() {
      _isStartingHls = true;
      _status = 'Starting HLS playback...';
    });

    try {
      await _disposeWebRtc();
      await _disposeHls();

      final controller = VideoPlayerController.networkUrl(Uri.parse(streamUrl), httpHeaders: _buildHlsHeaders());
      await controller.initialize();
      await controller.play();
      controller.setLooping(false);
      _videoController = controller;

      if (!mounted) return;
      setState(() {
        _isStartingHls = false;
        _status = 'HLS playback started.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isStartingHls = false;
        _status = 'HLS playback failed: $error';
      });
    }
  }

  Future<void> _stopHls() async {
    await _disposeHls();
    if (!mounted) return;
    setState(() => _status = 'HLS playback stopped.');
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

  List<String> _splitLines(String input) {
    return input.split(RegExp(r'[\n,]')).map((value) => value.trim()).where((value) => value.isNotEmpty).toList();
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

  String _encodeSdp(RTCSessionDescription description) {
    return jsonEncode({
      'type': description.type,
      'sdp': description.sdp,
      'session': _sessionController.text.trim(),
      'token': _webRtcTokenController.text.trim(),
      'role': _webRtcRole.name,
    });
  }

  RTCSessionDescription _decodeSdp(String raw) {
    final dynamic parsed = jsonDecode(raw);
    if (parsed is! Map<String, dynamic>) {
      throw const FormatException('SDP payload must be a JSON object.');
    }
    final type = parsed['type'] as String?;
    final sdp = parsed['sdp'] as String?;
    if (type == null || sdp == null) {
      throw const FormatException('SDP payload must contain type and sdp.');
    }
    return RTCSessionDescription(sdp, type);
  }

  Widget _buildViewport() {
    if (_transportMode == TransportMode.hls) {
      final controller = _videoController;
      if (controller == null || !controller.value.isInitialized) {
        return _ViewportPlaceholder(title: 'HLS / LL-HLS', subtitle: 'Enter a stream URL and start playback.');
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
    final primaryRenderer = showRemote ? _remoteRenderer : _localRenderer;

    if (!showRemote && !hasLocal) {
      return _ViewportPlaceholder(title: 'WebRTC', subtitle: 'Start local media or paste remote SDP to begin.');
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        RTCVideoView(
          primaryRenderer,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('sols.stream MWP'), backgroundColor: Colors.transparent),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1100;
            final viewport = _Panel(title: 'Viewport', child: _buildViewportSection());
            final controls = _Panel(title: 'Connection', child: _buildControlSection());

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
            Chip(avatar: const Icon(Icons.network_check, size: 18), label: Text(_rtcState)),
            if (_transportMode == TransportMode.webrtc)
              FilterChip(
                selected: _micEnabled,
                onSelected: _localStream == null ? null : (_) => _toggleMic(),
                label: Text(_micEnabled ? 'Mic on' : 'Mic off'),
              ),
            if (_transportMode == TransportMode.webrtc)
              FilterChip(
                selected: _cameraEnabled,
                onSelected: _localStream == null ? null : (_) => _toggleCamera(),
                label: Text(_cameraEnabled ? 'Camera on' : 'Camera off'),
              ),
            if (_transportMode == TransportMode.webrtc)
              FilterChip(
                selected: _showLocalPreviewPip,
                onSelected: _remoteVideoAvailable && _localStream != null
                    ? (value) => setState(() => _showLocalPreviewPip = value)
                    : null,
                label: const Text('Local PiP'),
              ),
          ],
        ),
        if (_status != null) ...[
          const SizedBox(height: 12),
          Text(_status!, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        ],
      ],
    );
  }

  Widget _buildControlSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<TransportMode>(
            segments: const [
              ButtonSegment(value: TransportMode.webrtc, label: Text('WebRTC')),
              ButtonSegment(value: TransportMode.hls, label: Text('HLS / LL-HLS')),
            ],
            selected: {_transportMode},
            onSelectionChanged: (values) => _setTransportMode(values.first),
          ),
          const SizedBox(height: 16),
          if (_transportMode == TransportMode.webrtc) _buildWebRtcControls() else _buildHlsControls(),
        ],
      ),
    );
  }

  Widget _buildWebRtcControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<WebRtcRole>(
          segments: const [
            ButtonSegment(value: WebRtcRole.publisher, label: Text('Publisher')),
            ButtonSegment(value: WebRtcRole.viewer, label: Text('Viewer')),
          ],
          selected: {_webRtcRole},
          onSelectionChanged: (values) {
            setState(() => _webRtcRole = values.first);
          },
        ),
        const SizedBox(height: 12),
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _LabeledField(
                label: 'TURN username',
                child: TextField(
                  controller: _turnUsernameController,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _LabeledField(
                label: 'TURN password',
                child: TextField(
                  controller: _turnPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _LabeledField(
                label: 'Session / Room',
                child: TextField(
                  controller: _sessionController,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _LabeledField(
                label: 'Token',
                child: TextField(
                  controller: _webRtcTokenController,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: _startingLocalMedia ? null : _startLocalMedia,
              icon: _startingLocalMedia
                  ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.videocam),
              label: const Text('Start Local Media'),
            ),
            FilledButton.tonalIcon(
              onPressed: _createOffer,
              icon: const Icon(Icons.upload_file),
              label: const Text('Create Offer'),
            ),
            FilledButton.tonalIcon(
              onPressed: _createAnswer,
              icon: const Icon(Icons.description),
              label: const Text('Create Answer'),
            ),
            FilledButton.tonalIcon(
              onPressed: _applyRemoteSdp,
              icon: const Icon(Icons.download),
              label: const Text('Apply Remote SDP'),
            ),
            FilledButton.tonalIcon(
              onPressed: _copyLocalSdp,
              icon: const Icon(Icons.copy),
              label: const Text('Copy Local SDP'),
            ),
            FilledButton.tonalIcon(
              onPressed: _disconnectWebRtc,
              icon: const Icon(Icons.call_end),
              label: const Text('Disconnect'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'Local SDP',
          child: TextField(
            controller: _localSdpController,
            readOnly: true,
            maxLines: 10,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Generated offer/answer JSON appears here',
            ),
          ),
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'Remote SDP',
          child: TextField(
            controller: _remoteSdpController,
            maxLines: 10,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Paste remote offer/answer JSON here',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHlsControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_hlsSupported) ...[
          const Text(
            'HLS via video_player is available on Android, iOS, macOS and Web. '
            'This build cannot play HLS on the current platform.',
          ),
          const SizedBox(height: 12),
        ],
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
                  decoration: const InputDecoration(border: OutlineInputBorder()),
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
                  decoration: const InputDecoration(border: OutlineInputBorder()),
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
                  ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.play_arrow),
              label: const Text('Play'),
            ),
            FilledButton.tonalIcon(onPressed: _stopHls, icon: const Icon(Icons.stop), label: const Text('Stop')),
          ],
        ),
      ],
    );
  }
}

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
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
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
