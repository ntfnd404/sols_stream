import 'package:flutter/material.dart';

import 'package:sols_stream/feature/app/routing/app_navigator.dart';

/// Profile tab content. Rendered directly in the Account shell's `IndexedStack`,
/// so it keeps its state while the user switches tabs.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const ListTile(
          leading: Icon(Icons.person_outline),
          title: Text('Display name'),
          subtitle: Text('sols.stream user'),
        ),
        const ListTile(
          leading: Icon(Icons.key_outlined),
          title: Text('Wallet'),
          subtitle: Text('Connected'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Sign out'),
          subtitle: const Text('Dialog-as-route demo (returns a result)'),
          onTap: () async {
            final confirmed = await context.navigator.confirm('Sign out of sols.stream?');
            if ((confirmed ?? false) && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out')),
              );
            }
          },
        ),
      ],
    ),
  );
}
