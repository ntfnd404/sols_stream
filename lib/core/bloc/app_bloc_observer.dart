import 'dart:developer';

import 'package:ephemeral_bloc/ephemeral_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sols_stream/core/security/safe_error_formatter.dart';

/// Observes all BLoC instances in the app.
///
/// [onError] is the single integration point for error reporting:
/// errors reported via `addError(e, stack)` inside any BLoC flow through
/// here before reaching crash reporters (Sentry, Firebase Crashlytics).
///
/// Registered in [AppBootstrap.initialize].
final class AppBlocObserver extends BlocObserver with EphemeralBlocObserver {
  @override
  void onEvent(Bloc<Object?, Object?> bloc, Object? event) {
    log(
      '${bloc.runtimeType}: ${event.runtimeType}',
      name: 'BlocObserver.event',
    );

    super.onEvent(bloc, event);
  }

  @override
  void onAction(BlocBase<Object?> bloc, EphemeralBlocChange<Object?> change) {
    log(
      '${bloc.runtimeType}: ${change.current.runtimeType}',
      name: 'BlocObserver.action',
    );
  }

  @override
  void onError(BlocBase<Object?> bloc, Object error, StackTrace stackTrace) {
    log(
      safeErrorFormatter.format(
        error,
        context: SafeDiagnosticContext.blocObserver,
        componentType: bloc.runtimeType,
        stackTrace: stackTrace,
      ),
      name: 'BlocObserver',
      level: 1000,
    );

    // Future reporters must receive an allowlisted normalized failure rather
    // than the original error object.

    super.onError(bloc, error, stackTrace);
  }
}
