import 'package:flutter/widgets.dart';
import 'package:realtime_media/realtime_media.dart';
import 'package:sols_stream/core/di/app_scope.dart';
import 'package:sols_stream/core/di/typedefs/factory.dart';
import 'package:sols_stream/feature/call/bloc/call_bloc.dart';

class CallScope extends StatefulWidget {
  const CallScope({
    super.key,
    required this.child,
  });

  static CallBloc createBloc(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<_InheritedCallScope>();
    if (scope == null) {
      throw StateError('CallScope not found in widget tree');
    }

    return scope.blocFactory();
  }

  final Widget child;

  @override
  State<CallScope> createState() => _CallScopeState();
}

class _CallScopeState extends State<CallScope> {
  late final Factory<CallBloc> _blocFactory;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final deps = AppScope.of(context);

    _blocFactory = () => CallBloc(
      peerSignaling: deps.peerSignaling,
      mediaSession: RealtimeMediaSession(),
      eventBus: deps.eventBus,
    );
  }

  @override
  Widget build(BuildContext context) => _InheritedCallScope(
    blocFactory: _blocFactory,
    child: widget.child,
  );
}

class _InheritedCallScope extends InheritedWidget {
  const _InheritedCallScope({
    required this.blocFactory,
    required super.child,
  });

  final Factory<CallBloc> blocFactory;

  @override
  bool updateShouldNotify(_InheritedCallScope old) => false;
}
