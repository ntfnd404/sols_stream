part of 'app_route.dart';

/// Lock screen the `LockGuard` redirects to when a protected route is requested
/// while locked. Excluded from history so it does not linger after unlock.
final class LockRoute extends AppRoute implements HistoryExcluded {
  @override
  LocalKey get pageKey => const ValueKey<String>('lock');

  @override
  String get name => 'lock';

  const LockRoute();

  @override
  Map<String, String> toParams() => const <String, String>{};

  @override
  Page<Object?> buildPage(BuildContext context) => MaterialPage<void>(key: pageKey, child: const UnlockScreen());
}
