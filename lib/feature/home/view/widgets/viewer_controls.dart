import 'package:flutter/material.dart';
import 'package:sols_stream/feature/home/view/widgets/labeled_field.dart';

class ViewerControls extends StatelessWidget {
  const ViewerControls({
    super.key,
    required this.connectionLinkController,
    required this.connecting,
    required this.connected,
    required this.onConnect,
  });

  final TextEditingController connectionLinkController;
  final bool connecting;
  final bool connected;
  final VoidCallback onConnect;

  String _label() {
    if (connecting) return 'Connecting…';
    if (connected) return 'Connected';

    return 'Connect';
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      LabeledField(
        label: 'Publisher invite link',
        child: TextField(
          controller: connectionLinkController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'https://…/home?intent=p2p&role=viewer&host=…',
            helperText: 'Paste the invite link copied from the publisher.',
          ),
        ),
      ),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: (connecting || connected) ? null : onConnect,
        icon: _ViewerConnectIcon(
          connecting: connecting,
          connected: connected,
        ),
        label: Text(_label()),
      ),
    ],
  );
}

final class _ViewerConnectIcon extends StatelessWidget {
  const _ViewerConnectIcon({
    required this.connecting,
    required this.connected,
  });

  final bool connecting;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    if (connecting) {
      return const SizedBox.square(
        dimension: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (connected) return const Icon(Icons.check_circle_outline);

    return const Icon(Icons.call);
  }
}
