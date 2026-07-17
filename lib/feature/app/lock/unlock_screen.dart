import 'package:flutter/material.dart';

import 'package:sols_stream/feature/app/lock/lock_scope.dart';

/// Shown by the `LockGuard` when a protected route is requested while locked.
/// Unlocking reruns the guards, which restore the originally intended location.
class UnlockScreen extends StatelessWidget {
  const UnlockScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Locked')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.lock_outline, size: 64),
          const SizedBox(height: 16),
          const Text('Account is locked'),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => LockScope.of(context).unlock(),
            child: const Text('Unlock'),
          ),
        ],
      ),
    ),
  );
}
