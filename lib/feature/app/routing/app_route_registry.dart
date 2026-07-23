import 'package:rolter/rolter.dart';
import 'package:sols_stream/feature/account/view/account_tab.dart';
import 'package:sols_stream/feature/app/routing/routes/app_route.dart';
import 'package:sols_stream/feature/home/model/session_mode.dart';
import 'package:sols_stream/feature/home/model/web_rtc_role.dart';

/// The route table: name → typed decoder. Adding a route = a class + one line here.
final RouteRegistry<AppRoute> appRouteRegistry = RouteRegistry<AppRoute>(
  <String, RouteDecoder<AppRoute>>{
    'hub': (_, _) => const HubRoute(),
    'home': (params, _) => _decodeHomeRoute(params),
    'account': (params, children) => AccountRoute(
      activeTab: AccountTab.values.asNameMap()[params['tab']] ?? AccountTab.profile,
      stack: children.isEmpty ? const <AppRoute>[SettingsHomeRoute()] : children,
    ),
    'settings-home': (_, _) => const SettingsHomeRoute(),
    'settings-detail': (params, _) => SettingsDetailRoute(int.tryParse(params['id'] ?? '') ?? 0),
    'lock': (_, _) => const LockRoute(),
    'network-picker': (_, _) => const NetworkPickerRoute(),
    'confirm': (params, _) => ConfirmDialogRoute(params['message'] ?? ''),
  },
  fallback: NotFoundRoute.new,
);

AppRoute _decodeHomeRoute(Map<String, String> params) {
  final attempted = Uri(path: '/home', queryParameters: params);
  const allowedParams = <String>{'intent', 'role', 'host', 'public'};
  if (params.keys.any((key) => !allowedParams.contains(key))) {
    return NotFoundRoute(attempted);
  }

  final sessionMode = SessionMode.values.asNameMap()[params['intent']];
  final webRtcRole = WebRtcRole.values.asNameMap()[params['role']];
  if (sessionMode == null || sessionMode != SessionMode.p2p || webRtcRole == null) {
    return NotFoundRoute(attempted);
  }

  final host = params['host'];
  final publicValue = params['public'];
  final hasHost = host != null && host.isNotEmpty;
  final hasPublic = publicValue != null;
  if (hasHost != hasPublic ||
      (hasPublic && publicValue != '0' && publicValue != '1') ||
      (hasHost && webRtcRole != WebRtcRole.viewer)) {
    return NotFoundRoute(attempted);
  }

  return HomeRoute(
    sessionMode,
    webRtcRole: webRtcRole,
    hostAddress: hasHost ? host : null,
    isPublic: publicValue == '1',
  );
}

/// Ensures Hub is always the root of the stack, so a deep link lands beneath it
/// and browser back can always reach the hub.
List<AppRoute> normalizeAppStack(List<AppRoute> stack) {
  if (stack.isEmpty) {
    return const <AppRoute>[HubRoute()];
  }

  if (stack.first is HubRoute) {
    return stack;
  }

  return <AppRoute>[const HubRoute(), ...stack];
}
