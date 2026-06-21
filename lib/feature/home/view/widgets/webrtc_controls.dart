import 'package:flutter/material.dart';
import 'package:sols_stream/feature/home/view/enums/web_rtc_role.dart';

class WebRtcControls extends StatelessWidget {
  const WebRtcControls({
    super.key,
    required this.role,
    required this.onRoleChanged,
    required this.hasLocalStream,
    required this.publisherControls,
    required this.viewerControls,
    required this.stunTurnSection,
    required this.onDisconnect,
  });

  final WebRtcRole role;
  final ValueChanged<WebRtcRole> onRoleChanged;
  final bool hasLocalStream;
  final Widget publisherControls;
  final Widget viewerControls;
  final Widget stunTurnSection;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SegmentedButton<WebRtcRole>(
        segments: const [
          ButtonSegment(value: WebRtcRole.publisher, label: Text('Publisher')),
          ButtonSegment(value: WebRtcRole.viewer, label: Text('Viewer')),
        ],
        selected: {role},
        onSelectionChanged: (v) => onRoleChanged(v.first),
      ),
      const SizedBox(height: 16),
      if (role == WebRtcRole.publisher) publisherControls else viewerControls,
      const SizedBox(height: 12),
      stunTurnSection,
      const SizedBox(height: 12),
      if (hasLocalStream)
        FilledButton.tonalIcon(
          onPressed: onDisconnect,
          icon: const Icon(Icons.call_end),
          label: const Text('Disconnect'),
        ),
    ],
  );
}
