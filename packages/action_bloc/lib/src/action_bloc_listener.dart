import 'dart:async';

import 'package:action_bloc/src/action_bloc_mixin.dart';
import 'package:action_bloc/src/action_bloc_streamable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';

/// Listens to one-shot actions emitted by a BLoC that uses [ActionBlocMixin].
///
/// Compatible with [MultiBlocListener] via [SingleChildStatefulWidget].
///
/// If [bloc] is omitted the nearest [BlocProvider] ancestor is used.
///
/// Usage:
/// ```dart
/// ActionBlocListener<MyBloc, MyAction>(
///   listener: (context, action) => switch (action) {
///     MyActionA() => ...,
///     MyActionB(:final data) => ...,
///   },
///   child: ...,
/// )
/// ```
///
/// Only the BLoC type [B] and action type [A] are needed — the state type is
/// irrelevant here (state is handled by `BlocBuilder`/`BlocListener`).
class ActionBlocListener<B extends BlocBase<Object?>, A> extends SingleChildStatefulWidget {
  const ActionBlocListener({
    super.key,
    required this.listener,
    this.bloc,
    this.listenWhen,
    super.child,
  });

  /// The BLoC to subscribe to. When null, resolved via [context.read].
  final B? bloc;

  /// Called on the main isolate for each emitted action.
  final void Function(BuildContext context, A action) listener;

  /// Optional filter for actions. Return false to suppress the [listener] call.
  /// When null, every action is forwarded.
  ///
  /// Called with the previous action this listener received ([previous], null
  /// on the first action and after a bloc swap) and the [current] one — mirrors
  /// [BlocListener.listenWhen]. [previous] is **listener-local**: it tracks
  /// actions delivered to *this* subscription, and updates on every action
  /// whether or not it passed the filter. Useful for e.g. suppressing a
  /// duplicate action emitted twice in a row.
  final bool Function(A? previous, A current)? listenWhen;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<B?>('bloc', bloc))
      ..add(
        ObjectFlagProperty<void Function(BuildContext, A)>.has(
          'listener',
          listener,
        ),
      )
      ..add(
        ObjectFlagProperty<bool Function(A?, A)?>.has(
          'listenWhen',
          listenWhen,
        ),
      );
  }

  @override
  SingleChildState<ActionBlocListener<B, A>> createState() => _ActionBlocListenerState<B, A>();
}

class _ActionBlocListenerState<B extends BlocBase<Object?>, A> extends SingleChildState<ActionBlocListener<B, A>> {
  StreamSubscription<A>? _subscription;
  late B _bloc;

  /// The last action delivered to this subscription, passed to
  /// [ActionBlocListener.listenWhen] as `previous`. Reset on (re)subscribe.
  A? _previousAction;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? context.read<B>();
    _subscribe();
  }

  void _subscribe() {
    if (_bloc is! ActionBlocStreamable<A>) {
      throw StateError(
        '$B does not implement ActionBlocStreamable<$A>. '
        'Mix ActionBlocMixin into $B or implement the streamable contract '
        'to use ActionBlocListener.',
      );
    }
    final actionBloc = _bloc as ActionBlocStreamable<A>;
    _previousAction = null;
    _subscription = actionBloc.actionStream.listen((action) {
      if (!mounted) return;
      final shouldCall = widget.listenWhen?.call(_previousAction, action) ?? true;
      if (shouldCall) {
        widget.listener(context, action);
      }
      _previousAction = action;
    });
  }

  @override
  void didUpdateWidget(ActionBlocListener<B, A> old) {
    super.didUpdateWidget(old);
    // When both [old.bloc] and [widget.bloc] are null the BLoC is resolved from
    // the nearest provider — [context.read<B>()] returns the same instance, so
    // [oldBloc == current] and no resubscription occurs. This is intentional.
    final oldBloc = old.bloc ?? context.read<B>();
    final current = widget.bloc ?? oldBloc;
    if (oldBloc != current) {
      _subscription?.cancel();
      _bloc = current;
      _subscribe();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.bloc ?? context.read<B>();
    if (_bloc != bloc) {
      _subscription?.cancel();
      _bloc = bloc;
      _subscribe();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) => child ?? const SizedBox.shrink();
}
