import 'package:flutter/material.dart';

import 'package:rolter/rolter.dart';
import 'package:sols_stream/feature/app/lock/lock_controller.dart';
import 'package:sols_stream/feature/app/lock/lock_scope.dart';
import 'package:sols_stream/feature/app/routing/app_navigator.dart';
import 'package:sols_stream/feature/app/routing/app_route_registry.dart';
import 'package:sols_stream/feature/app/routing/app_route_url_codec.dart';
import 'package:sols_stream/feature/app/routing/lock_guard.dart';
import 'package:sols_stream/feature/app/routing/routes/app_route.dart';
import 'package:ui_kit/ui_kit.dart';

/// Root application widget.
///
/// `AppScope` is placed above this widget (in `main`) so the routing delegate
/// and every screen can read `AppDependencies`. This widget places
/// `NavigatorScope` and `LockScope` ABOVE `MaterialApp.router` (C5) so
/// `context.navigator` and the lock state work in every `buildPage` and screen.
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

  late final LockController _lock;
  late final LockGuard _lockGuard;
  late final RoutesState<AppRoute> _state;
  late final AppNavigator _navigator;
  late final RoutingDelegate<AppRoute> _delegate;
  late final RoutingInformationParser<AppRoute> _parser;

  @override
  void initState() {
    super.initState();
    _lock = LockController();
    _lockGuard = LockGuard(_lock);
    final pipeline = GuardedPipeline<AppRoute>(
      guards: <RouteGuard<AppRoute>>[_lockGuard],
      normalize: normalizeAppStack,
      currentStack: () => _state.root,
    );
    _state = RoutesState<AppRoute>(const <AppRoute>[HubRoute()], pipeline.call);
    pipeline.refresh.addListener(_state.reevaluate);
    _navigator = AppNavigator(_state);
    _delegate = RoutingDelegate<AppRoute>(_state);
    _parser = RoutingInformationParser<AppRoute>(AppRouteUrlCodec());
  }

  @override
  void dispose() {
    _delegate.dispose();
    _state.dispose();
    _lockGuard.dispose();
    _lock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LockScope(
    controller: _lock,
    child: NavigatorScope<AppNavigator>(
      navigator: _navigator,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Sols Stream',
        routerDelegate: _delegate,
        routeInformationParser: _parser,
        theme: _lightTheme,
        darkTheme: _darkTheme,
        builder: AppTheme.builder,
      ),
    ),
  );
}
