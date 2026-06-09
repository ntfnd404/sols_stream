import 'package:flutter_bloc/flutter_bloc.dart';

/// A concrete [BlocObserver] that does NOT mix in `ActionBlocObserver` — used to
/// verify `emitAction` tolerates an observer without action support.
final class PlainBlocObserver extends BlocObserver {}
