import 'package:flutter/material.dart';

/// Detail pushed inside the Settings tab's nested navigator. Its app-bar back
/// pops only this nested stack; the tab bar and the Profile tab stay put. The
/// page is in the URL (`/hub/account~tab=settings/.settings-home/.settings-detail~id=N`),
/// so it survives a refresh and is deep-linkable.
class SettingsDetailScreen extends StatelessWidget {
  const SettingsDetailScreen({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Network #$id')),
        body: Center(child: Text('Details for network #$id')),
      );
}
