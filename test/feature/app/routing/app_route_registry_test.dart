import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rolter/rolter.dart';
import 'package:sols_stream/core/di/app_dependencies.dart';
import 'package:sols_stream/core/di/app_scope.dart';
import 'package:sols_stream/feature/app/routing/app_navigator.dart';
import 'package:sols_stream/feature/app/routing/app_route_url_codec.dart';
import 'package:sols_stream/feature/app/routing/routes/app_route.dart';
import 'package:sols_stream/feature/call/bloc/call_bloc.dart';
import 'package:sols_stream/feature/call/di/call_scope.dart';
import 'package:sols_stream/feature/home/bloc/home_bloc.dart';
import 'package:sols_stream/feature/home/di/home_scope.dart';
import 'package:sols_stream/feature/home/model/session_mode.dart';
import 'package:sols_stream/feature/home/model/web_rtc_role.dart';
import 'package:sols_stream/feature/home/view/home_screen.dart';
import 'package:sols_stream/feature/home/view/home_view.dart';

import '../../../helpers/fake_app_dependencies.dart';

void main() {
  test('external viewer URL preserves typed invite parameters', () {
    const host = '724ZZDXYHP9MsL4fbCUitXfAj8x9JqsD2LDtUVj183g8';
    final codec = AppRouteUrlCodec();
    final decoded = codec.decode(
      Uri.parse(
        'http://localhost:8080/home?'
        'intent=p2p&role=viewer&host=$host&public=1',
      ),
    );

    expect(decoded, hasLength(2));
    expect(decoded.first, isA<HubRoute>());
    final homeRoute = decoded.last as HomeRoute;
    expect(homeRoute.sessionMode, SessionMode.p2p);
    expect(homeRoute.webRtcRole, WebRtcRole.viewer);
    expect(homeRoute.hostAddress, host);
    expect(homeRoute.isPublic, isTrue);
    expect(
      homeRoute.connectionUrl(Uri.parse('http://localhost:8080/current')),
      'http://localhost:8080/home?'
      'intent=p2p&role=viewer&host=$host&public=1',
    );
  });

  test('normalized Home stack uses the canonical public invite URL', () {
    const route = HomeRoute(
      SessionMode.p2p,
      webRtcRole: WebRtcRole.viewer,
      hostAddress: 'host-address',
      isPublic: true,
    );
    final codec = AppRouteUrlCodec();
    const routes = <AppRoute>[HubRoute(), route];

    final encoded = codec.encode(routes);
    final decoded = codec.decode(encoded);

    expect(
      encoded.toString(),
      '/home?intent=p2p&role=viewer&host=host-address&public=1',
    );
    expect(decoded, routes);
  });

  test('Home route keeps page identity while URL state changes', () {
    const invite = HomeRoute(
      SessionMode.p2p,
      webRtcRole: WebRtcRole.viewer,
      hostAddress: 'host-address',
      isPublic: true,
    );
    const publisher = HomeRoute(
      SessionMode.p2p,
      webRtcRole: WebRtcRole.publisher,
    );

    expect(invite.pageKey, publisher.pageKey);
    expect(invite, isNot(publisher));
    expect(<HomeRoute>{invite, publisher}, hasLength(2));
  });

  testWidgets('Home page state survives route parameter updates', (
    tester,
  ) async {
    const invite = HomeRoute(
      SessionMode.p2p,
      webRtcRole: WebRtcRole.viewer,
      hostAddress: 'host-address',
      isPublic: true,
    );
    const publisher = HomeRoute(
      SessionMode.p2p,
      webRtcRole: WebRtcRole.publisher,
    );

    await tester.pumpWidget(const _RouteStateTestApp(route: invite));
    final initialState = tester.state(find.byType(_RouteStateProbe));

    await tester.pumpWidget(const _RouteStateTestApp(route: publisher));

    expect(tester.state(find.byType(_RouteStateProbe)), same(initialState));
  });

  testWidgets('HomeRoute updates preserve HomeBloc and CallBloc instances', (
    tester,
  ) async {
    final dependencies = fakeAppDependencies(ownEventBus: false);

    await tester.pumpWidget(
      _HomeScreenTestApp(
        dependencies: dependencies,
        webRtcRole: WebRtcRole.viewer,
        invite:
            'http://localhost:8080/home?intent=p2p&role=viewer'
            '&host=host-address&public=1',
      ),
    );
    final initialContext = tester.element(find.byType(HomeView));
    final initialHomeBloc = initialContext.read<HomeBloc>();
    final initialCallBloc = initialContext.read<CallBloc>();

    await tester.pumpWidget(
      _HomeScreenTestApp(
        dependencies: dependencies,
        webRtcRole: WebRtcRole.publisher,
      ),
    );
    await tester.pump();

    final updatedContext = tester.element(find.byType(HomeView));
    expect(updatedContext.read<HomeBloc>(), same(initialHomeBloc));
    expect(updatedContext.read<CallBloc>(), same(initialCallBloc));
    expect(initialHomeBloc.state.webRtcRole, WebRtcRole.publisher);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await dependencies.eventBus.dispose();
  });

  test('role synchronization preserves mode and clears invite parameters', () async {
    final state = RoutesState<AppRoute>(
      const <AppRoute>[
        HubRoute(),
        HomeRoute(
          SessionMode.p2p,
          webRtcRole: WebRtcRole.viewer,
          hostAddress: 'host-address',
          isPublic: true,
        ),
      ],
      (routes) => routes,
    );
    final navigator = AppNavigator(state);
    addTearDown(state.dispose);

    navigator.syncHomeRole(WebRtcRole.publisher);
    await state.processingCompleted;

    expect(
      state.top,
      const HomeRoute(
        SessionMode.p2p,
        webRtcRole: WebRtcRole.publisher,
      ),
    );
    expect(
      AppRouteUrlCodec().encode(state.root).toString(),
      '/home?intent=p2p&role=publisher',
    );

    navigator.syncHomeRole(WebRtcRole.viewer);
    await state.processingCompleted;

    expect(
      state.top,
      const HomeRoute(
        SessionMode.p2p,
        webRtcRole: WebRtcRole.viewer,
      ),
    );
    expect(
      AppRouteUrlCodec().encode(state.root).toString(),
      '/home?intent=p2p&role=viewer',
    );
  });

  test('legacy, stream, and incomplete Home URLs resolve to Not Found', () {
    final codec = AppRouteUrlCodec();
    final invalidUris = <Uri>[
      Uri.parse('/home?intent=joinRoom'),
      Uri.parse('/home?intent=p2pCall'),
      Uri.parse('/home?intent=stream&role=publisher'),
      Uri.parse('/home?intent=p2p'),
      Uri.parse('/home?intent=p2p&role=publisher&host=unexpected&public=1'),
      Uri.parse('/home?intent=p2p&role=viewer&mode=p2p'),
      Uri.parse('/home?intent=p2p&role=viewer&unexpected=value'),
      Uri.parse('/home?intent=p2p&intent=p2p&role=viewer'),
      Uri.parse('/home?intent=p2p&role=viewer&role=viewer'),
      Uri.parse(
        '/home?intent=p2p&role=viewer&host=first&host=second&public=1',
      ),
      Uri.parse(
        '/home?intent=p2p&role=viewer&host=host&public=1&public=1',
      ),
    ];

    for (final uri in invalidUris) {
      expect(
        codec.decode(uri).last,
        isA<NotFoundRoute>(),
        reason: '$uri must not silently fall back to a valid Home route',
      );
    }
  });
}

// Test-only widget intentionally stays beside the route identity scenarios.
// ignore: prefer-match-file-name
class _RouteStateTestApp extends StatelessWidget {
  const _RouteStateTestApp({required this.route});

  final HomeRoute route;

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Navigator(
      pages: [
        MaterialPage<void>(
          key: route.pageKey,
          child: const _RouteStateProbe(),
        ),
      ],
      onDidRemovePage: (_) {},
    ),
  );
}

class _HomeScreenTestApp extends StatelessWidget {
  const _HomeScreenTestApp({
    required this.dependencies,
    required this.webRtcRole,
    this.invite,
  });

  final AppDependencies dependencies;
  final WebRtcRole webRtcRole;
  final String? invite;

  @override
  Widget build(BuildContext context) => AppScope(
    dependencies: dependencies,
    child: MaterialApp(
      home: HomeScope(
        child: CallScope(
          child: HomeScreen(
            sessionMode: SessionMode.p2p,
            webRtcRole: webRtcRole,
            initialConnectionUrl: invite,
            onRoleChanged: (_) {},
            onSessionModeChanged: (_) {},
          ),
        ),
      ),
    ),
  );
}

class _RouteStateProbe extends StatefulWidget {
  const _RouteStateProbe();

  @override
  State<_RouteStateProbe> createState() => _RouteStateProbeState();
}

class _RouteStateProbeState extends State<_RouteStateProbe> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
