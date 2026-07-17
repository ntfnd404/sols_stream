import 'package:flutter/material.dart';
import 'package:sols_stream/feature/home/view/widgets/labeled_field.dart';

class HlsControls extends StatelessWidget {
  const HlsControls({
    super.key,
    required this.hlsSupported,
    required this.isStartingHls,
    required this.urlController,
    required this.usernameController,
    required this.passwordController,
    required this.tokenController,
    required this.onPlay,
    required this.onStop,
  });

  final bool hlsSupported;
  final bool isStartingHls;
  final TextEditingController urlController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController tokenController;
  final VoidCallback onPlay;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (!hlsSupported)
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text('HLS is available on Android, iOS, macOS and Web.', style: TextStyle(color: Colors.orange)),
        ),
      LabeledField(
        label: 'Stream URL',
        child: TextField(
          controller: urlController,
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
            child: LabeledField(
              label: 'Username',
              child: TextField(
                controller: usernameController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LabeledField(
              label: 'Password',
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      LabeledField(
        label: 'Token',
        child: TextField(
          controller: tokenController,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilledButton.icon(
            onPressed: !hlsSupported || isStartingHls ? null : onPlay,
            icon: isStartingHls
                ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.play_arrow),
            label: const Text('Play'),
          ),
          FilledButton.tonalIcon(
            onPressed: onStop,
            icon: const Icon(Icons.stop),
            label: const Text('Stop'),
          ),
        ],
      ),
    ],
  );
}
