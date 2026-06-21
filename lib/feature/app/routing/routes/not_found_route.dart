part of 'app_route.dart';

/// Fallback for an unknown URL. Kept out of browser history via [HistoryExcluded].
final class NotFoundRoute extends AppRoute implements HistoryExcluded {
  final Uri attempted;

  @override
  LocalKey get pageKey => ValueKey<String>('not-found:$attempted');

  @override
  String get name => 'not-found';

  const NotFoundRoute(this.attempted);

  @override
  Map<String, String> toParams() => <String, String>{'u': attempted.toString()};

  @override
  Page<Object?> buildPage(BuildContext context) => MaterialPage<void>(
    key: pageKey,
    child: NotFoundScreen(attempted: attempted),
  );
}
