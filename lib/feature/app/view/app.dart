import 'package:flutter/material.dart';
import 'package:sols_stream/core/routing/app_route_config.dart';
import 'package:sols_stream/core/routing/app_route_information_parser.dart';
import 'package:sols_stream/core/routing/app_router_delegate.dart';
import 'package:sols_stream/core/routing/app_routs_state.dart';
import 'package:ui_kit/ui_kit.dart';

/// Root application widget.
///
/// [AppScope] must be placed above this widget in the tree so that
/// [AppRouterDelegate] and all feature screens can access [AppDependencies].
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Assembled once — see AppTheme.fromVariant: the theme must not be rebuilt in
  // build(), or its (intentionally ==-less) extensions rebuild the whole subtree.
  static final ThemeData _lightTheme = AppTheme.fromVariant(const LightThemeVariant());
  static final ThemeData _darkTheme = AppTheme.fromVariant(const DarkThemeVariant());

  late final AppRoutsState _appRoutsState;
  late final AppRouterDelegate _routerDelegate;
  late final AppRouteInformationParser _routeInformationParser;
  late final Router<AppRouteConfig> _router;

  @override
  void initState() {
    super.initState();

    _appRoutsState = AppRoutsState();
    _routerDelegate = AppRouterDelegate(_appRoutsState);
    _routeInformationParser = AppRouteInformationParser();
    _router = Router<AppRouteConfig>(
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }

  @override
  void dispose() {
    _routerDelegate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    title: 'Sols Stream',
    routerDelegate: _routerDelegate,
    routeInformationParser: _routeInformationParser,
    // routerConfig: _router,
    theme: _lightTheme,
    darkTheme: _darkTheme,
    builder: AppTheme.builder,
  );
}

// final appState = AppState();
// final routerDelegate = AppRouterDelegate(appState);
// final routeInformationParser = AppRouteInformationParser();

// final router = Router<AppRouteConfig>(
//   routerDelegate: routerDelegate,
//   routeInformationParser: routeInformationParser,
// );
