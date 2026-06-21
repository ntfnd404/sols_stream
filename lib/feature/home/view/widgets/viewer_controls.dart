import 'package:flutter/material.dart';
import 'package:sols_stream/feature/home/view/widgets/labeled_field.dart';

class ViewerControls extends StatelessWidget {
  const ViewerControls({
    super.key,
    required this.connectionLinkController,
    required this.connecting,
    required this.onConnect,
  });

  final TextEditingController connectionLinkController;
  final bool connecting;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledField(
            label: 'Connection link',
            child: TextField(
              controller: connectionLinkController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'sols://connect?host=…',
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: connecting ? null : onConnect,
            icon: connecting
                ? const SizedBox.square(
                    dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.call),
            label: Text(connecting ? 'Connecting…' : 'Connect'),
          ),
        ],
      );
}
