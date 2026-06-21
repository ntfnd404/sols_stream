import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:signaling/signaling.dart';

class PublisherControls extends StatelessWidget {
  const PublisherControls({
    super.key,
    required this.session,
    required this.goingLive,
    required this.onGoLive,
  });

  final SignalingSession? session;
  final bool goingLive;
  final VoidCallback onGoLive;

  @override
  Widget build(BuildContext context) {
    final s = session;
    if (s != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('🔴 Live',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.redAccent)),
          const SizedBox(height: 8),
          const Text('Share this link or QR with the viewer:',
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Center(child: QrImageView(data: s.url, size: 180)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SelectableText(s.url,
                    style: const TextStyle(fontSize: 11, color: Colors.white54)),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                tooltip: 'Copy link',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: s.url));
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Link copied')));
                },
              ),
            ],
          ),
        ],
      );
    }

    return FilledButton.icon(
      onPressed: goingLive ? null : onGoLive,
      icon: goingLive
          ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.stream),
      label: Text(goingLive ? 'Going live…' : 'Go Live'),
    );
  }
}
