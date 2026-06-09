import 'dart:async';

import 'package:action_bloc/src/action_bloc_observer.dart';
import 'package:action_bloc/src/action_bloc_streamable.dart';
import 'package:action_bloc/src/action_change.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Adds a one-shot action stream to any [BlocBase].
///
/// Actions are fire-and-forget UI effects (SnackBar, navigation, focus).
/// They are NOT stored in state — they arrive once and are consumed.
///
/// **Delivery is best-effort.** [actionStream] is a broadcast stream with no
/// buffer: an action emitted while no listener is subscribed is dropped, and a
/// late subscriber does not receive past actions. This is intentional — a UI
/// effect with no one to handle it is a no-op.
///
/// Usage:
/// ```dart
/// class MyBloc extends Bloc<MyEvent, MyState>
///     with ActionBlocMixin<MyState, MyAction> { ... }
/// ```
mixin ActionBlocMixin<S, A> on BlocBase<S> implements ActionBlocStateStreamable<S, A> {
  final StreamController<A> _actionController = StreamController<A>.broadcast();
  A? _currentAction;

  /// Broadcast stream of one-shot UI actions.
  ///
  /// Late subscribers do not receive past actions.
  @override
  Stream<A> get actionStream => _actionController.stream;

  /// Emits [action] to all current [actionStream] subscribers.
  ///
  /// Unlike [Bloc.emit], [emitAction] may be called from anywhere — not only
  /// inside an event handler — since actions are a side-effect channel, not
  /// state. Emitting in response to an event is the common case.
  ///
  /// **Closed-BLoC contract:** deliberate no-op when the BLoC is already
  /// closed. Callers do not need to guard against a closed BLoC before calling
  /// [emitAction]. This differs from [Bloc.emit], which throws on a closed
  /// BLoC, because actions are fire-and-forget effects — missing one during
  /// teardown is harmless.
  void emitAction(A action) {
    if (!isClosed) {
      final observer = Bloc.observer;
      if (observer case final ActionBlocObserver actionObserver) {
        actionObserver.onAction(
          this,
          ActionChange(previous: _currentAction, current: action),
        );
      }
      _actionController.add(action);
      _currentAction = action;
    }
  }

  @override
  Future<void> close() async {
    await _actionController.close();

    return super.close();
  }
}
