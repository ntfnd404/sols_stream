import 'package:flutter/material.dart';

import 'package:sols_stream/feature/app/routing/app_navigator.dart';

/// Full-screen picker pushed for a result via `pushForResult`. Tapping an item
/// returns it with `popWith`; system / app-bar back returns null.
class NetworkPickerScreen extends StatelessWidget {
  const NetworkPickerScreen({super.key});

  static const List<String> _networks = <String>['devnet', 'testnet', 'mainnet-beta'];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Select network')),
        body: ListView(
          children: <Widget>[
            for (final network in _networks)
              ListTile(
                leading: const Icon(Icons.dns_outlined),
                title: Text(network),
                onTap: () => context.navigator.popWith<String>(network),
              ),
          ],
        ),
      );
}
