import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:realtime_media/realtime_media.dart';
import 'package:sols_stream/feature/home/model/transport_mode.dart';
import 'package:sols_stream/feature/home/model/web_rtc_role.dart';
import 'package:sols_stream/feature/home/view/widgets/viewport_placeholder.dart';
import 'package:streaming/streaming.dart';

class StreamViewport extends StatefulWidget {
  const StreamViewport({
    super.key,
    required this.transportMode,
    required this.webRtcRole,
    required this.videoController,
    required this.localStreamActive,
    required this.remoteVideoAvailable,
    required this.remoteCameraEnabled,
    required this.remoteMicrophoneEnabled,
    required this.showLocalPreviewPip,
    required this.localRenderer,
    required this.remoteRenderer,
  });

  final TransportMode transportMode;
  final WebRtcRole webRtcRole;
  final VideoPlayerController? videoController;
  final bool localStreamActive;
  final bool remoteVideoAvailable;
  final bool remoteCameraEnabled;
  final bool remoteMicrophoneEnabled;
  final bool showLocalPreviewPip;
  final RTCVideoRenderer? localRenderer;
  final RTCVideoRenderer? remoteRenderer;

  @override
  State<StreamViewport> createState() => _StreamViewportState();
}

class _StreamViewportState extends State<StreamViewport> {
  // Tap-to-swap toggle for which stream fills the main viewport vs the
  // corner PiP. Reset whenever a viewer freshly connects, so the
  // interlocutor's camera always starts out as the main view.
  bool _localIsPrimary = false;

  void _toggleSwap() => setState(() => _localIsPrimary = !_localIsPrimary);

  bool _shouldCoverVideo({required bool isLocal}) => !isLocal && !widget.remoteCameraEnabled;

  @override
  void didUpdateWidget(StreamViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.remoteVideoAvailable && widget.remoteVideoAvailable) {
      _localIsPrimary = false;
    }
    if (!widget.showLocalPreviewPip) {
      _localIsPrimary = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.transportMode == TransportMode.hls) {
      final ctrl = widget.videoController;
      if (ctrl == null || !ctrl.value.isInitialized) {
        return const ViewportPlaceholder(
          title: 'HLS / LL-HLS',
          subtitle: 'Enter a stream URL and tap Play.',
        );
      }

      return FittedBox(
        child: SizedBox(
          width: ctrl.value.size.width,
          height: ctrl.value.size.height,
          child: VideoPlayer(ctrl),
        ),
      );
    }

    if (!widget.remoteVideoAvailable && !widget.localStreamActive) {
      return ViewportPlaceholder(
        title: 'WebRTC',
        subtitle: widget.webRtcRole == WebRtcRole.publisher
            ? 'Tap "Go Live" to start broadcasting.'
            : 'Paste a connection link and tap "Connect".',
      );
    }

    final localIsPrimary = !widget.remoteVideoAvailable || _localIsPrimary;
    final primaryRenderer = localIsPrimary ? widget.localRenderer : widget.remoteRenderer;
    final secondaryRenderer = localIsPrimary ? widget.remoteRenderer : widget.localRenderer;
    final primaryLabel = localIsPrimary ? 'LOCAL PREVIEW' : 'REMOTE PARTICIPANT';
    final secondaryLabel = localIsPrimary ? 'REMOTE PARTICIPANT' : 'LOCAL PREVIEW';
    if (primaryRenderer == null) {
      return const ViewportPlaceholder(
        title: 'WebRTC',
        subtitle: 'Preparing video renderer.',
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        RTCVideoView(primaryRenderer, mirror: localIsPrimary),
        if (_shouldCoverVideo(isLocal: localIsPrimary)) const _RemoteCameraOffOverlay(),
        if (!localIsPrimary && !widget.remoteMicrophoneEnabled)
          const Positioned(
            left: 12,
            bottom: 12,
            child: _RemoteMicrophoneOffBadge(),
          ),
        if (kDebugMode)
          Positioned(
            top: 12,
            right: 12,
            child: _ViewportBadge(label: primaryLabel),
          ),
        if (secondaryRenderer != null &&
            widget.remoteVideoAvailable &&
            widget.localStreamActive &&
            widget.showLocalPreviewPip)
          _CornerPip(
            alignment: Alignment.bottomRight,
            onTap: _toggleSwap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                RTCVideoView(
                  secondaryRenderer,
                  mirror: !localIsPrimary,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
                if (_shouldCoverVideo(isLocal: !localIsPrimary)) const _RemoteCameraOffOverlay(),
                if (localIsPrimary && !widget.remoteMicrophoneEnabled)
                  const Positioned(
                    left: 8,
                    bottom: 8,
                    child: _RemoteMicrophoneOffBadge(compact: true),
                  ),
                if (kDebugMode)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _ViewportBadge(label: secondaryLabel),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RemoteMicrophoneOffBadge extends StatelessWidget {
  const _RemoteMicrophoneOffBadge({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.black87,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.white24),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 4 : 6,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mic_off, color: Colors.white70, size: 16),
          if (!compact) ...[
            const SizedBox(width: 6),
            const Text(
              'Peer microphone is off',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ],
      ),
    ),
  );
}

class _RemoteCameraOffOverlay extends StatelessWidget {
  const _RemoteCameraOffOverlay();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: Colors.black,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_circle_outlined,
            color: Colors.white70,
            size: 32,
          ),
          SizedBox(height: 6),
          Text(
            'Peer camera is off',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _ViewportBadge extends StatelessWidget {
  const _ViewportBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.white24),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
      ),
    ),
  );
}

class _CornerPip extends StatelessWidget {
  const _CornerPip({required this.alignment, required this.onTap, required this.child});

  final Alignment alignment;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: alignment,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: GestureDetector(
        key: const ValueKey('stream-viewport-pip'),
        onTap: onTap,
        child: SizedBox(
          width: 180,
          height: 120,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(8),
              color: Colors.black,
            ),
            child: ClipRRect(borderRadius: BorderRadius.circular(8), child: child),
          ),
        ),
      ),
    ),
  );
}
