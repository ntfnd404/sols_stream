import 'package:flutter/material.dart';
import 'package:sols_stream/feature/home/model/transport_mode.dart';

class ViewportSection extends StatelessWidget {
  const ViewportSection({
    super.key,
    required this.rtcState,
    required this.transportMode,
    required this.viewport,
    required this.micEnabled,
    required this.cameraEnabled,
    required this.localStreamActive,
    required this.remoteVideoAvailable,
    required this.showLocalPreviewPip,
    required this.onToggleMic,
    required this.onToggleCamera,
    required this.onTogglePip,
    this.status,
    this.diagnostics,
  });

  final String rtcState;
  final TransportMode transportMode;
  final Widget viewport;
  final bool micEnabled;
  final bool cameraEnabled;
  final bool localStreamActive;
  final bool remoteVideoAvailable;
  final bool showLocalPreviewPip;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final ValueChanged<bool> onTogglePip;
  final String? status;
  final String? diagnostics;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ColoredBox(color: Colors.black, child: viewport),
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          Chip(avatar: const Icon(Icons.network_check, size: 18), label: Text(rtcState)),
          if (transportMode == TransportMode.webrtc) ...[
            FilterChip(
              selected: micEnabled,
              onSelected: localStreamActive ? (_) => onToggleMic() : null,
              label: Text(micEnabled ? 'Mic on' : 'Mic off'),
            ),
            FilterChip(
              selected: cameraEnabled,
              onSelected: localStreamActive ? (_) => onToggleCamera() : null,
              label: Text(cameraEnabled ? 'Camera on' : 'Camera off'),
            ),
            FilterChip(
              selected: showLocalPreviewPip,
              onSelected: remoteVideoAvailable && localStreamActive ? onTogglePip : null,
              label: const Text('Local PiP'),
            ),
          ],
        ],
      ),
      if (status case final status?) ...[
        const SizedBox(height: 8),
        SelectableText(
          status,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ],
      if (diagnostics case final diagnostics?) ...[
        const SizedBox(height: 6),
        SelectableText(
          'Media: $diagnostics',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ],
  );
}
