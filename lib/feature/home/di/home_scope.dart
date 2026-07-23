import 'package:flutter/widgets.dart';
import 'package:sols_stream/core/di/app_scope.dart';
import 'package:sols_stream/core/di/typedefs/factory.dart';
import 'package:sols_stream/feature/home/bloc/home_bloc.dart';
import 'package:sols_stream/feature/home/model/home_launch_config.dart';

class HomeScope extends StatefulWidget {
  const HomeScope({
    super.key,
    required this.child,
  });

  static HomeBloc createBloc(
    BuildContext context, {
    required HomeLaunchConfig config,
  }) {
    final scope = context.getInheritedWidgetOfExactType<_InheritedHomeScope>();
    if (scope == null) {
      throw StateError('HomeScope not found in widget tree');
    }

    return scope.blocFactory(config);
  }

  final Widget child;

  @override
  State<HomeScope> createState() => _HomeScopeState();
}

class _HomeScopeState extends State<HomeScope> {
  late final ParamFactory<HomeBloc, HomeLaunchConfig> _blocFactory;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final deps = AppScope.of(context);

    _blocFactory = (config) => HomeBloc(
      eventBus: deps.eventBus,
      initialRole: config.webRtcRole,
      initialSessionMode: config.sessionMode,
    );
  }

  @override
  Widget build(BuildContext context) => _InheritedHomeScope(
    blocFactory: _blocFactory,
    child: widget.child,
  );
}

class _InheritedHomeScope extends InheritedWidget {
  const _InheritedHomeScope({
    required this.blocFactory,
    required super.child,
  });

  final ParamFactory<HomeBloc, HomeLaunchConfig> blocFactory;

  @override
  bool updateShouldNotify(_InheritedHomeScope old) => false;
}
