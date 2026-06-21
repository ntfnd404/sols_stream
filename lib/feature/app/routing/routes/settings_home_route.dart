part of 'app_route.dart';

/// Base of the Settings tab's nested navigator.
final class SettingsHomeRoute extends AppRoute {
  @override
  LocalKey get pageKey => const ValueKey<String>('settings-home');

  @override
  String get name => 'settings-home';

  const SettingsHomeRoute();

  @override
  Map<String, String> toParams() => const <String, String>{};

  @override
  Page<Object?> buildPage(BuildContext context) => MaterialPage<void>(key: pageKey, child: const SettingsScreen());
}
