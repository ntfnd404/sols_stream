import 'package:flutter_bloc/flutter_bloc.dart';

/// Exposes a stream of one-shot actions.
///
/// Implemented by [ActionBlocMixin], or directly by any object that wants to
/// be observed by [ActionBlocListener] / [ActionBlocConsumer].
abstract interface class ActionBlocStreamable<A> {
  /// Broadcast stream of one-shot actions. Late subscribers do not receive
  /// past actions.
  Stream<A> get actionStream;
}

/// Exposes regular BLoC state ([StateStreamable]) plus one-shot actions
/// ([ActionBlocStreamable]).
///
/// This is the contract [ActionBlocMixin] satisfies, letting a single object
/// drive both `BlocBuilder`/`BlocListener` (state) and `ActionBlocListener`
/// (actions).
abstract interface class ActionBlocStateStreamable<S, A> implements StateStreamable<S>, ActionBlocStreamable<A> {}
