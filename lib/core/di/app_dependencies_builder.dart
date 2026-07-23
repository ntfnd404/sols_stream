// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:developer';

import 'package:meta/meta.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:signaling/key_broker_assembly.dart';
import 'package:signaling/signaling.dart';
import 'package:signaling_solana/signaling_solana.dart';
import 'package:solana/solana.dart' show RpcClient;
import 'package:solana_wallet/solana_wallet_assembly.dart';
import 'package:sols_stream/core/config/app_environment.dart';
import 'package:sols_stream/core/di/app_dependencies.dart';
import 'package:sols_stream/core/di/app_resource_disposal_exception.dart';
import 'package:sols_stream/core/di/app_resource_disposal_stack.dart';
import 'package:sols_stream/core/event_bus/app_event_bus.dart';
import 'package:sols_stream/core/security/redactor.dart';

/// Composition root that coordinates application module assemblies.
base class AppDependenciesBuilder {
  final AppEnvironment _environment;
  final void Function(AppDependencies dependencies) _builder;
  final AppErrorReporter _onError;

  const AppDependenciesBuilder({
    required AppEnvironment environment,
    required void Function(AppDependencies dependencies) builder,
    required AppErrorReporter onError,
  }) : _environment = environment,
       _builder = builder,
       _onError = onError;

  /// Builds the graph and transfers its ownership to [_builder].
  @nonVirtual
  Future<void> build() async {
    final resourceDisposalStack = AppResourceDisposalStack();
    final AppDependencies dependencies;

    try {
      dependencies = await buildDependencies(resourceDisposalStack);
    } catch (error, stackTrace) {
      await _handleBuildFailure(
        resourceDisposalStack: resourceDisposalStack,
        error: error,
        stackTrace: stackTrace,
      );
    }

    try {
      _builder(dependencies);
    } catch (error, stackTrace) {
      await _disposeAndReport(resourceDisposalStack);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  /// Creates the concrete graph inside the ownership boundary.
  ///
  /// Subclasses may replace graph construction while retaining the lifecycle
  /// and error semantics implemented by [build].
  @protected
  Future<AppDependencies> buildDependencies(
    AppResourceDisposalStack resourceDisposalStack,
  ) async {
    const secureStorage = SecureStorageImpl();
    final rpcEnvironment = _environment.rpc;
    final walletEnvironment = _environment.wallet;
    final rpc = RpcClient(rpcEnvironment.url.toString());
    void diagnostics(String event) => log(
      event,
      name: 'Signaling',
    );

    log(
      'rpc=${Redactor.redactUrl(rpcEnvironment.url.toString())} '
      'invite=${Redactor.redactUrl(_environment.peerInvite.url.toString())} '
      'broker=${_safeBrokerDescription(_environment.keyBroker.config)}',
      name: 'Environment',
    );

    final wallet = resourceDisposalStack.register(
      await SolanaWalletAssembly.create(
        storage: secureStorage,
        rpc: rpc,
        funding: walletEnvironment.funding,
        storageKey: walletEnvironment.storageKey,
      ),
      (assembly) => assembly.dispose(),
    );
    final keyBroker = resourceDisposalStack.register(
      KeyBrokerAssembly.create(_environment.keyBroker.config),
      (assembly) => assembly.dispose(),
    );
    final signalingAssembly = SignalingSolanaAssembly(
      signer: wallet.signer,
      fundingService: wallet.fundingService,
      reader: rpc,
      peerInviteBase: _environment.peerInvite.base,
      broker: keyBroker.gateway,
      diagnostics: diagnostics,
    );
    final eventBus = resourceDisposalStack.register(
      AppEventBus(),
      (resource) => resource.dispose(),
    );

    return AppDependencies(
      eventBus: eventBus,
      peerSignaling: signalingAssembly.peerSignaling,
      walletReader: wallet.reader,
      resourceDisposalStack: resourceDisposalStack,
      errorReporter: _onError,
    );
  }

  Future<Never> _handleBuildFailure({
    required AppResourceDisposalStack resourceDisposalStack,
    required Object error,
    required StackTrace stackTrace,
  }) async {
    await _disposeAndReport(resourceDisposalStack);
    await _reportSafely(error, stackTrace);
    Error.throwWithStackTrace(error, stackTrace);
  }

  Future<void> _disposeAndReport(
    AppResourceDisposalStack resourceDisposalStack,
  ) async {
    try {
      await resourceDisposalStack.dispose();
    } on AppResourceDisposalException catch (error) {
      for (final failure in error.failures) {
        await _reportSafely(failure.error, failure.stackTrace);
      }
    }
  }

  Future<void> _reportSafely(
    Object error,
    StackTrace stackTrace,
  ) async {
    try {
      await _onError(error, stackTrace);
    } catch (reportError, reportStackTrace) {
      Zone.current.handleUncaughtError(reportError, reportStackTrace);
    }
  }

  String _safeBrokerDescription(KeyBrokerConfig config) => switch (config) {
    LocalKeyBrokerConfig() => 'local',
    HttpKeyBrokerConfig(:final endpoint) => Redactor.redactUrl(
      endpoint.toString(),
    ),
  };
}
