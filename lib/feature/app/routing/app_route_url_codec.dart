import 'package:rolter/rolter.dart';
import 'package:sols_stream/feature/app/routing/app_route_registry.dart';
import 'package:sols_stream/feature/app/routing/routes/app_route.dart';

/// Keeps shareable Home URLs conventional while retaining rolter's tree
/// encoding for route stacks that cannot be represented by a single URL.
final class AppRouteUrlCodec implements RouteUrlCodec<AppRoute> {
  final TreeUrlCodec<AppRoute> _treeCodec;

  AppRouteUrlCodec() : _treeCodec = TreeUrlCodec<AppRoute>(appRouteRegistry);

  @override
  List<AppRoute> decode(Uri uri) {
    final segments = uri.pathSegments.where((segment) => segment.isNotEmpty).toList();
    final isExternalSingleRoute =
        segments.length == 1 &&
        !segments.single.startsWith('.') &&
        !segments.single.contains('~') &&
        uri.queryParameters.isNotEmpty;
    if (!isExternalSingleRoute) {
      return _treeCodec.decode(uri);
    }
    if (uri.queryParametersAll.values.any((values) => values.length != 1)) {
      return <AppRoute>[NotFoundRoute(uri)];
    }

    final route = appRouteRegistry.decode(
      segments.single,
      uri.queryParameters,
      const <AppRoute>[],
    );

    // Hub is implicit in public Home URLs. Restoring it here makes
    // decode(encode(stack)) round-trip without exposing rolter's tree syntax.
    return route is HomeRoute ? <AppRoute>[const HubRoute(), route] : <AppRoute>[route];
  }

  @override
  Uri encode(List<AppRoute> roots) {
    if (roots.length == 2 && roots.first is HubRoute && roots.last is HomeRoute) {
      final home = roots.last as HomeRoute;

      return Uri(path: '/home', queryParameters: home.toParams());
    }

    return _treeCodec.encode(roots);
  }
}
