import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sols_stream/core/bloc/app_bloc_observer.dart';
import 'package:sols_stream/core/bootstrap/url_strategy.dart';
import 'package:sols_stream/core/security/redactor.dart';

/// One-time framework-level initialization performed before [runApp].
///
/// Intentionally separate from [AppDependenciesBuilder] (DI composition root)
/// and from `main` (zone guard + app entry) so that each unit has a single
/// responsibility:
///
/// - `AppBootstrap` — configure Flutter and third-party frameworks
/// - `AppDependenciesBuilder` — assemble the dependency graph
/// - `main` — guard the async zone, load config, start the app
///
/// ### Error handling strategy
///
/// Steps are split into two categories:
///
/// - **Fatal** (e.g. [WidgetsFlutterBinding.ensureInitialized]) — the app
///   cannot start; the exception propagates to `runZonedGuarded`.
/// - **Non-fatal** (e.g. Sentry, Firebase) — observability is degraded but
///   the app must still launch; each step catches its own error and logs it.
final class AppBootstrap {
  AppBootstrap._();

  /// Configures all framework-level globals.
  ///
  /// Synchronous for now. Will become `Future<void>` once async initializations
  /// (Sentry, Firebase) are added — update [main] to `await` it at that point.
  ///
  /// Must be called once inside `runZonedGuarded` before
  /// `AppDependenciesBuilder.build`.
  static void initialize() {
    WidgetsFlutterBinding.ensureInitialized();
    configureUrlStrategy();
    _initBlocObserver();

    // TODO(ntfnd404): await _initSentry();
    // TODO(ntfnd404): await _initFirebase();
  }

  static void _initBlocObserver() {
    try {
      Bloc.observer = AppBlocObserver();
    } catch (e, stack) {
      log(
        'BlocObserver init failed: ${Redactor.redact(e)}\n$stack',
        name: 'AppBootstrap',
        level: 1000,
      );
    }
  }
}
