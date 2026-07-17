import 'package:flutter/material.dart';

class PublisherControls extends StatelessWidget {
  const PublisherControls({
    super.key,
    required this.goingLive,
    required this.connectionUrl,
    required this.onGoLive,
    required this.onCopyInvite,
    required this.onRegenerateInvite,
  });

  final bool goingLive;
  final String? connectionUrl;
  final VoidCallback onGoLive;
  final ValueChanged<String> onCopyInvite;
  final VoidCallback onRegenerateInvite;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FilledButton.icon(
        onPressed: goingLive || connectionUrl != null ? null : onGoLive,
        icon: goingLive
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.stream),
        label: Text(goingLive ? 'Going live…' : 'Go Live'),
      ),
      if (connectionUrl case final connectionUrl?) ...[
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SelectableText(
                connectionUrl,
                maxLines: 3,
              ),
            ),
            IconButton(
              tooltip: 'Copy invite link',
              onPressed: () => onCopyInvite(connectionUrl),
              icon: const Icon(Icons.copy),
            ),
            IconButton(
              tooltip: 'Regenerate invite link',
              onPressed: goingLive ? null : onRegenerateInvite,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ],
    ],
  );
}
