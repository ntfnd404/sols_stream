part of 'app_route.dart';

/// Streaming/playback screen. [intent] is a typed field; on the wire it is only
/// `intent=<name>` and no screen ever sees the map.
final class HomeRoute extends AppRoute {
  final HomeIntent intent;

  @override
  LocalKey get pageKey => ValueKey<String>('home:${intent.name}');

  @override
  String get name => 'home';

  const HomeRoute(this.intent);

  @override
  Map<String, String> toParams() => <String, String>{'intent': intent.name};

  @override
  Page<Object?> buildPage(BuildContext context) => MaterialPage<void>(
    key: pageKey,
    child: HomeScreen(intent: intent),
  );
}
