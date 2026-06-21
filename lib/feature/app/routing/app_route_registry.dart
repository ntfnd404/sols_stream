import 'package:rolter/rolter.dart';
import 'package:sols_stream/feature/account/view/account_tab.dart';
import 'package:sols_stream/feature/app/routing/routes/app_route.dart';
import 'package:sols_stream/feature/home/view/enums/home_intent.dart';

/// The route table: name → typed decoder. Adding a route = a class + one line here.
final RouteRegistry<AppRoute> appRouteRegistry = RouteRegistry<AppRoute>(
  <String, RouteDecoder<AppRoute>>{
    'hub': (_, _) => const HubRoute(),
    'home': (params, _) => HomeRoute(HomeIntent.values.asNameMap()[params['intent']] ?? HomeIntent.stream),
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
