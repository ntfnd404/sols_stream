import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:sols_stream/core/di/app_dependencies.dart';

/// Provides the application dependency graph and owns its widget-tree lifetime.
final class AppScope extends StatefulWidget {
  const AppScope({
    super.key,
    required this.dependencies,
    required this.child,
  });

  /// Returns [AppDependencies] from the nearest [AppScope].
  static AppDependencies of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<_AppDependenciesProvider>();
    if (provider == null) {
      throw StateError('AppScope not found in widget tree');
    }

    return provider.dependencies;
  }

  final AppDependencies dependencies;
  final Widget child;

  @override
  State<AppScope> createState() => _AppScopeState();
}

final class _AppScopeState extends State<AppScope> {
  late final AppDependencies _dependencies = widget.dependencies;

  @override
  void didUpdateWidget(AppScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(_dependencies, widget.dependencies)) {
      throw StateError(
        'AppScope does not support replacing the application dependency graph.',
      );
    }
  }

  @override
  void dispose() {
    unawaited(_dependencies.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _AppDependenciesProvider(
    dependencies: _dependencies,
    child: widget.child,
  );
}

final class _AppDependenciesProvider extends InheritedWidget {
  const _AppDependenciesProvider({
    required this.dependencies,
    required super.child,
  });

  final AppDependencies dependencies;

  @override
  bool updateShouldNotify(_AppDependenciesProvider oldWidget) => !identical(dependencies, oldWidget.dependencies);
}
