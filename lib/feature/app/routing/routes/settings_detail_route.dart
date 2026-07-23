part of 'app_route.dart';

/// A detail pushed inside the Settings tab's nested navigator.
final class SettingsDetailRoute extends AppRoute {
  final int id;

  @override
  LocalKey get pageKey => ValueKey<String>('settings-detail:$id');

  @override
  String get name => 'settings-detail';

  const SettingsDetailRoute(this.id);

  @override
  Map<String, String> toParams() => <String, String>{'id': '$id'};

  @override
  Page<Object?> buildPage(BuildContext context) => MaterialPage<void>(
    key: pageKey,
    child: SettingsDetailScreen(id: id),
  );
}
