part of 'app_route.dart';

/// Tabbed Account shell. [activeTab] is typed (`tab=<name>`); [stack] is the
/// Settings tab's nested back stack and projects to the URL as the children of
/// `account`. [pageKey] stays STABLE across tab switches so `IndexedStack` keeps
/// each tab's state. Equality includes [activeTab] + [stack] (the base derives
/// it from [pageKey] only), so a tab switch or a nested push is a real change.
final class AccountRoute extends AppRoute {
  final AccountTab activeTab;
  final List<AppRoute> stack;

  @override
  List<AppRoute> get children => stack;

  @override
  LocalKey get pageKey => const ValueKey<String>('account');

  @override
  String get name => 'account';

  @override
  int get hashCode => Object.hash(AccountRoute, activeTab, Object.hashAll(stack));

  const AccountRoute({
    this.activeTab = AccountTab.profile,
    this.stack = const <AppRoute>[SettingsHomeRoute()],
  });

  @override
  AppRoute withChildren(List<RouteNode> children) =>
      AccountRoute(activeTab: activeTab, stack: children.cast<AppRoute>());

  @override
  Map<String, String> toParams() => <String, String>{'tab': activeTab.name};

  @override
  Page<Object?> buildPage(BuildContext context) => MaterialPage<void>(
    key: pageKey,
    child: AccountShell(
      activeTab: activeTab,
      onSelectTab: context.navigator.selectAccountTab,
      settingsTab: NestedNavigatorHost<AppRoute>(
        service: context.navigator,
        path: const <String>['account'],
        active: activeTab == AccountTab.settings,
      ),
    ),
  );

  @override
  bool operator ==(Object other) =>
      other is AccountRoute && other.activeTab == activeTab && listEquals(other.stack, stack);
}
