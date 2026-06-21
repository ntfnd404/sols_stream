import 'package:flutter/material.dart';

import 'package:sols_stream/feature/app/routing/app_navigator.dart';

/// Shown for an unknown URL. Offers a route back to the hub.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({required this.attempted, super.key});

  final Uri attempted;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text('No route for "$attempted"'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: context.navigator.toHub,
                child: const Text('Go to hub'),
              ),
            ],
          ),
        ),
      );
}
