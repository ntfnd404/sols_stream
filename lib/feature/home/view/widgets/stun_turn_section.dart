import 'package:flutter/material.dart';
import 'package:sols_stream/feature/home/view/widgets/labeled_field.dart';

class StunTurnSection extends StatelessWidget {
  const StunTurnSection({
    super.key,
    required this.urlsController,
    required this.usernameController,
    required this.passwordController,
  });

  final TextEditingController urlsController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: ExpansionTile(
      title: const Text('STUN / TURN settings'),
      children: [
        LabeledField(
          label: 'STUN / TURN URLs',
          child: TextField(
            controller: urlsController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'One per line or comma-separated',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 8),
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
            const SizedBox(width: 8),
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
        const SizedBox(height: 8),
      ],
    ),
  );
}
