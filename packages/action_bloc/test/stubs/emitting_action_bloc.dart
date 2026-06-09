import 'package:action_bloc/action_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A BLoC that emits both a state change and an action from inside its event
/// handler — mirrors real usage where `emitAction` is called within `on<E>`.
///
/// Dispatching a [String] event increments the state and emits that same
/// string as an action.
final class EmittingActionBloc extends Bloc<String, int> with ActionBlocMixin<int, String> {
  EmittingActionBloc() : super(0) {
    on<String>((event, emit) {
      emit(state + 1);
      emitAction(event);
    });
  }
}
