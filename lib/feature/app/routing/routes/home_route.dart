part of 'app_route.dart';

/// Streaming/playback screen with optional web-interoperability invite data.
final class HomeRoute extends AppRoute {
  final SessionMode sessionMode;
  final WebRtcRole webRtcRole;
  final String? hostAddress;
  final bool isPublic;

  @override
  LocalKey get pageKey => const ValueKey<String>('home');

  @override
  String get name => 'home';

  @override
  int get hashCode => Object.hash(
    runtimeType,
    sessionMode,
    webRtcRole,
    hostAddress,
    isPublic,
  );

  const HomeRoute(
    this.sessionMode, {
    required this.webRtcRole,
    this.hostAddress,
    this.isPublic = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeRoute &&
          sessionMode == other.sessionMode &&
          webRtcRole == other.webRtcRole &&
          hostAddress == other.hostAddress &&
          isPublic == other.isPublic;

  @override
  Map<String, String> toParams() => <String, String>{
    'intent': sessionMode.name,
    'role': webRtcRole.name,
    'host': ?hostAddress,
    if (hostAddress != null) 'public': isPublic ? '1' : '0',
  };

  String? connectionUrl(Uri baseUri) {
    final host = hostAddress;
    if (host == null || host.isEmpty) return null;

    return baseUri
        .replace(
          path: '/home',
          queryParameters: <String, String>{
            'intent': sessionMode.name,
            'role': webRtcRole.name,
            'host': host,
            'public': isPublic ? '1' : '0',
          },
        )
        .toString();
  }

  @override
  Page<Object?> buildPage(BuildContext context) => MaterialPage<void>(
    key: pageKey,
    child: HomeScope(
      child: CallScope(
        child: HomeScreen(
          sessionMode: sessionMode,
          webRtcRole: webRtcRole,
          initialConnectionUrl: connectionUrl(Uri.base),
          onRoleChanged: context.navigator.syncHomeRole,
          onSessionModeChanged: context.navigator.syncHomeSessionMode,
        ),
      ),
    ),
  );
}
