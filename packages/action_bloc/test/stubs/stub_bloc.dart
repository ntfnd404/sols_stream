import 'package:flutter_bloc/flutter_bloc.dart';

/// A plain BLoC without `ActionBlocMixin` — used to verify the runtime guard
/// in `ActionBlocListener` when the target BLoC is not `ActionBlocStreamable`.
final class StubBloc extends Bloc<Object, int> {
  StubBloc() : super(0);
}
