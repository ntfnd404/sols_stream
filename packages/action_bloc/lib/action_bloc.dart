/// One-shot BLoC side effects (navigation, SnackBars, focus) as a typed,
/// fire-and-forget action stream that lives outside BLoC state.
///
/// - [ActionBlocMixin] adds `actionStream` + `emitAction` to a `BlocBase`.
/// - [ActionBlocListener] / [ActionBlocConsumer] handle actions in the tree.
/// - [ActionBlocObserver] observes actions globally (logging/analytics).
library;

export 'src/action_bloc_consumer.dart';
export 'src/action_bloc_listener.dart';
export 'src/action_bloc_mixin.dart';
export 'src/action_bloc_observer.dart';
export 'src/action_bloc_streamable.dart';
export 'src/action_change.dart';
