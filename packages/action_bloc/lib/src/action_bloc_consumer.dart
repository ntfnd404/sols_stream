import 'package:action_bloc/src/action_bloc_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Combines [ActionBlocListener], an optional [BlocListener], and [BlocBuilder]
/// into a single widget.
///
/// If [bloc] is omitted the nearest [BlocProvider] ancestor is used.
///
/// Usage:
/// ```dart
/// ActionBlocConsumer<MyBloc, MyState, MyAction>(
///   actionListener: (context, action) => switch (action) {
///     MyError(:final exception) => showSnackBar(exception.toString()),
///     _ => null,
///   },
///   stateListener: (context, state) { /* react to state changes */ },
///   builder: (context, state) => Text(state.value),
/// )
/// ```
///
/// Both [actionListener] and [stateListener] are optional. Omitting both
/// reduces this widget to a plain [BlocBuilder].
class ActionBlocConsumer<B extends BlocBase<S>, S, A> extends StatelessWidget {
  const ActionBlocConsumer({
    super.key,
    required this.builder,
    this.bloc,
    this.actionListener,
    this.stateListener,
    this.actionListenWhen,
    this.stateListenWhen,
    this.buildWhen,
  });

  /// The BLoC to subscribe to. When null, resolved via [context.read].
  final B? bloc;

  /// Builds the widget tree from the current state.
  final BlocWidgetBuilder<S> builder;

  /// Called for each action emitted by the BLoC.
  ///
  /// Actions are fire-and-forget effects and carry their own data. If the
  /// handler needs current BLoC state, read `bloc.state` directly at that
  /// point — no state snapshot is passed, to avoid implying a state value
  /// captured at any particular moment.
  final void Function(BuildContext context, A action)? actionListener;

  /// Called for each state change. Mirrors [BlocListener.listener].
  final void Function(BuildContext context, S state)? stateListener;

  /// Optional filter for actions, forwarded to [ActionBlocListener.listenWhen].
  /// Called with the previous action this consumer received ([previous], null
  /// on the first action and after a bloc swap) and the [current] one. Return
  /// false to suppress [actionListener]. Symmetric with [stateListenWhen].
  final bool Function(A? previous, A current)? actionListenWhen;

  /// Optional filter for state changes. Mirrors [BlocListener.listenWhen].
  final bool Function(S previous, S current)? stateListenWhen;

  /// Optional rebuild filter. When null, rebuilds on every state change.
  final BlocBuilderCondition<S>? buildWhen;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<B?>('bloc', bloc))
      ..add(
        ObjectFlagProperty<void Function(BuildContext, A)?>.has(
          'actionListener',
          actionListener,
        ),
      )
      ..add(
        ObjectFlagProperty<void Function(BuildContext, S)?>.has(
          'stateListener',
          stateListener,
        ),
      )
      ..add(ObjectFlagProperty<BlocWidgetBuilder<S>>.has('builder', builder))
      ..add(
        ObjectFlagProperty<bool Function(A?, A)?>.has(
          'actionListenWhen',
          actionListenWhen,
        ),
      )
      ..add(
        ObjectFlagProperty<bool Function(S, S)?>.has(
          'stateListenWhen',
          stateListenWhen,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = BlocBuilder<B, S>(
      bloc: bloc,
      buildWhen: buildWhen,
      builder: builder,
    );

    if (stateListener != null) {
      child = BlocListener<B, S>(
        bloc: bloc,
        listenWhen: stateListenWhen,
        listener: stateListener!,
        child: child,
      );
    }

    if (actionListener != null) {
      child = ActionBlocListener<B, A>(
        bloc: bloc,
        listenWhen: actionListenWhen,
        listener: actionListener!,
        child: child,
      );
    }

    return child;
  }
}
