import 'package:flutter/material.dart';

import 'package:sols_stream/feature/app/lock/lock_scope.dart';
import 'package:sols_stream/feature/app/routing/app_navigator.dart';

/// Base screen of the Settings tab's nested stack. Tapping an item pushes a
/// detail onto the nested navigator (the URL gains `/.settings-detail~id=N`);
/// back then pops within this tab only, leaving the Profile tab untouched.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        for (var id = 1; id <= 3; id++)
          ListTile(
            leading: const Icon(Icons.dns_outlined),
            title: Text('Network #$id'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.navigator.openSettingsDetail(id),
          ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.lan_outlined),
          title: const Text('Select network'),
          subtitle: const Text('Push-for-result demo'),
          onTap: () async {
            final network = await context.navigator.pickNetwork();
            if (network != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Picked: $network')),
              );
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text('Lock account'),
          subtitle: const Text('Redirects to the unlock screen (guard demo)'),
          onTap: () => LockScope.of(context).lock(),
        ),
      ],
    ),
  );
}
