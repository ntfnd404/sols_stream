import 'package:sols_stream/core/di/app_dependencies.dart';
import 'package:sols_stream/core/di/app_dependencies_builder.dart';
import 'package:sols_stream/core/di/app_resource_disposal_stack.dart';

/// Test implementation that replaces only the graph-construction step.
final class TestAppDependenciesBuilder extends AppDependenciesBuilder {
  final Future<AppDependencies> Function(AppResourceDisposalStack stack) graphBuilder;

  const TestAppDependenciesBuilder({
    required super.environment,
    required super.builder,
    required super.onError,
    required this.graphBuilder,
  });

  @override
  Future<AppDependencies> buildDependencies(
    AppResourceDisposalStack resourceDisposalStack,
  ) => graphBuilder(resourceDisposalStack);
}
