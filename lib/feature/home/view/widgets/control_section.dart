import 'package:flutter/material.dart';
import 'package:sols_stream/feature/home/model/transport_mode.dart';

class ControlSection extends StatelessWidget {
  const ControlSection({
    super.key,
    required this.transportMode,
    required this.onTransportChanged,
    required this.webRtcControls,
    required this.hlsControls,
    required this.walletTile,
    this.scrollable = true,
  });

  final TransportMode transportMode;
  final ValueChanged<TransportMode> onTransportChanged;
  final Widget webRtcControls;
  final Widget hlsControls;
  final Widget walletTile;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<TransportMode>(
          segments: const [
            ButtonSegment(value: TransportMode.webrtc, label: Text('WebRTC')),
            ButtonSegment(value: TransportMode.hls, label: Text('HLS / LL-HLS')),
          ],
          selected: {transportMode},
          onSelectionChanged: (v) => onTransportChanged(v.first),
        ),
        const SizedBox(height: 16),
        if (transportMode == TransportMode.webrtc) webRtcControls else hlsControls,
        const SizedBox(height: 16),
        walletTile,
      ],
    );

    return scrollable ? SingleChildScrollView(child: content) : content;
  }
}
