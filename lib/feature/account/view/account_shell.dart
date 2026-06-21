import 'package:flutter/material.dart';

import 'package:sols_stream/feature/account/view/account_tab.dart';
import 'package:sols_stream/feature/account/view/profile_screen.dart';

/// Tabbed Account shell. The active tab comes from the route (so it is in the
/// URL and deep-linkable); `IndexedStack` keeps both tabs mounted, preserving
/// each tab's state. The Profile tab is a plain screen; the Settings tab is a
/// nested navigator ([settingsTab]) with its own back stack. Switching a tab is
/// a navigation (`onSelectTab`), so browser back moves between tabs too.
class AccountShell extends StatelessWidget {
  const AccountShell({
    required this.activeTab,
    required this.onSelectTab,
    required this.settingsTab,
    super.key,
  });

  final AccountTab activeTab;
  final ValueChanged<AccountTab> onSelectTab;
  final Widget settingsTab;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(
          index: activeTab.index,
          children: <Widget>[const ProfileScreen(), settingsTab],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: activeTab.index,
          onDestinationSelected: (index) => onSelectTab(AccountTab.values[index]),
          destinations: const <NavigationDestination>[
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
          ],
        ),
      );
}
