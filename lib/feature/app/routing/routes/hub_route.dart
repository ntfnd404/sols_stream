part of 'app_route.dart';

/// Landing hub. Wires its few stable destinations as callbacks (D8): the screen
/// stays a pure view, the route is the controller.
final class HubRoute extends AppRoute {
  @override
  LocalKey get pageKey => const ValueKey<String>('hub');

  @override
  String get name => 'hub';

  const HubRoute();

  @override
  Map<String, String> toParams() => const <String, String>{};

  @override
  Page<Object?> buildPage(BuildContext context) => MaterialPage<void>(
    key: pageKey,
    child: HubScreen(
      onStream: null,
      onP2PCall: () => context.navigator.toHome(
        sessionMode: SessionMode.p2p,
        webRtcRole: WebRtcRole.publisher,
      ),
      onJoinRoom: () => context.navigator.toHome(
        sessionMode: SessionMode.p2p,
        webRtcRole: WebRtcRole.viewer,
      ),
      onAccount: context.navigator.toAccount,
    ),
  );
}
