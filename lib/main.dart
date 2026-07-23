import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sols_stream/core/bootstrap/app_bootstrap.dart';
import 'package:sols_stream/core/config/environment_loader.dart';
import 'package:sols_stream/core/di/app_dependencies_builder.dart';
import 'package:sols_stream/core/di/app_scope.dart';
import 'package:sols_stream/core/security/safe_error_formatter.dart';
import 'package:sols_stream/feature/app/view/app.dart';

void main() => runZonedGuarded(
  () {
    AppBootstrap.initialize();
    final environment = loadEnvironment();

    unawaited(
      AppDependenciesBuilder(
        environment: environment,
        builder: (dependencies) => runApp(
          AppScope(
            dependencies: dependencies,
            child: const App(),
          ),
        ),
        onError: _onError,
      ).build(),
    );
  },
  _onError,
);

void _onError(Object error, StackTrace stack) => log(
  safeErrorFormatter.format(
    error,
    context: SafeDiagnosticContext.rootZone,
    stackTrace: stack,
  ),
  name: 'main',
  level: 1000,
);
