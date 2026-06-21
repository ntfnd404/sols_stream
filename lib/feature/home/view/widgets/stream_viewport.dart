import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sols_stream/feature/home/view/enums/transport_mode.dart';
import 'package:sols_stream/feature/home/view/enums/web_rtc_role.dart';
import 'package:sols_stream/feature/home/view/widgets/viewport_placeholder.dart';
import 'package:video_player/video_player.dart';

class StreamViewport extends StatelessWidget {
  const StreamViewport({
    super.key,
    required this.transportMode,
    required this.webRtcRole,
    required this.videoController,
    required this.localStreamActive,
    required this.remoteVideoAvailable,
    required this.showLocalPreviewPip,
    required this.localRenderer,
    required this.remoteRenderer,
  });

  final TransportMode transportMode;
  final WebRtcRole webRtcRole;
  final VideoPlayerController? videoController;
  final bool localStreamActive;
  final bool remoteVideoAvailable;
  final bool showLocalPreviewPip;
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;

  @override
  Widget build(BuildContext context) {
    if (transportMode == TransportMode.hls) {
      final ctrl = videoController;
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

    if (!remoteVideoAvailable && !localStreamActive) {
      return ViewportPlaceholder(
        title: 'WebRTC',
        subtitle: webRtcRole == WebRtcRole.publisher
            ? 'Tap "Go Live" to start broadcasting.'
            : 'Paste a connection link and tap "Connect".',
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        RTCVideoView(
          remoteVideoAvailable ? remoteRenderer : localRenderer,
          mirror: !remoteVideoAvailable,
        ),
        if (remoteVideoAvailable && localStreamActive && showLocalPreviewPip)
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
                    localRenderer,
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
}
