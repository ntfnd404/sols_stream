import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:signaling/key_broker_assembly.dart';
import 'package:solana_wallet/solana_wallet_assembly.dart';
import 'package:sols_stream/core/config/app_environment.dart';
import 'package:sols_stream/core/config/app_environment_kind.dart';
import 'package:sols_stream/core/config/key_broker_environment.dart';
import 'package:sols_stream/core/config/peer_invite_environment.dart';
import 'package:sols_stream/core/config/rpc_environment.dart';
import 'package:sols_stream/core/config/wallet_environment.dart';
import 'package:sols_stream/core/di/app_dependencies.dart';

import '../../helpers/fake_app_dependencies.dart';
import 'test_app_dependencies_builder.dart';

void main() {
  test('reports and rethrows a DI failure after partial cleanup', () async {
    final buildFailure = StateError('build failed');
    var cleanupCount = 0;
    final reported = <Object>[];

    await expectLater(
      TestAppDependenciesBuilder(
        environment: _localEnvironment(),
        builder: (_) => fail('builder must not run after a DI failure'),
        onError: (error, _) => reported.add(error),
        graphBuilder: (stack) {
          stack.register(Object(), (_) => cleanupCount += 1);

          return Future<AppDependencies>.error(buildFailure);
        },
      ).build(),
      throwsA(same(buildFailure)),
    );

    expect(cleanupCount, 1);
    expect(reported, [buildFailure]);
  });

  test('reports every cleanup failure before the build failure', () async {
    final firstCleanup = StateError('first cleanup');
    final secondCleanup = StateError('second cleanup');
    final buildFailure = StateError('build');
    final reported = <Object>[];

    await expectLater(
      TestAppDependenciesBuilder(
        environment: _localEnvironment(),
        builder: (_) => fail('builder must not run'),
        onError: (error, _) => reported.add(error),
        graphBuilder: (stack) {
          stack
            ..register(Object(), (_) => throw firstCleanup)
            ..register(Object(), (_) => throw secondCleanup);

          return Future<AppDependencies>.error(buildFailure);
        },
      ).build(),
      throwsA(same(buildFailure)),
    );

    expect(reported, [secondCleanup, firstCleanup, buildFailure]);
  });

  test('awaits an asynchronous reporter before rethrowing the DI failure', () async {
    final buildFailure = StateError('build');
    var reportingCompleted = false;

    await expectLater(
      TestAppDependenciesBuilder(
        environment: _localEnvironment(),
        builder: (_) => fail('builder must not run'),
        onError: (_, _) async {
          await Future<void>.delayed(Duration.zero);
          reportingCompleted = true;
        },
        graphBuilder: (_) => Future<AppDependencies>.error(buildFailure),
      ).build(),
      throwsA(same(buildFailure)),
    );

    expect(reportingCompleted, isTrue);
  });

  test('sends reporter failures to the zone and preserves the DI failure', () async {
    final buildFailure = StateError('build');
    final reporterFailure = StateError('reporter');
    final zoneErrors = <Object>[];

    final run = runZonedGuarded(
      () => expectLater(
        TestAppDependenciesBuilder(
          environment: _localEnvironment(),
          builder: (_) => fail('builder must not run'),
          onError: (_, _) => throw reporterFailure,
          graphBuilder: (_) => Future<AppDependencies>.error(buildFailure),
        ).build(),
        throwsA(same(buildFailure)),
      ),
      (error, _) => zoneErrors.add(error),
    );
    if (run == null) {
      fail('Guarded zone did not return the test future.');
    }
    await run;

    expect(zoneErrors, [reporterFailure]);
  });

  test('disposes the graph when the success callback throws', () async {
    final callbackFailure = StateError('callback failed');
    var cleanupCount = 0;

    await expectLater(
      TestAppDependenciesBuilder(
        environment: _localEnvironment(),
        builder: (_) => throw callbackFailure,
        onError: (_, _) {},
        graphBuilder: (stack) async {
          stack.register(Object(), (_) => cleanupCount += 1);

          return fakeAppDependencies(resourceDisposalStack: stack);
        },
      ).build(),
      throwsA(same(callbackFailure)),
    );

    expect(cleanupCount, 1);
  });

  test('reports callback cleanup failures and rethrows the callback failure', () async {
    final callbackFailure = StateError('callback');
    final cleanupFailure = StateError('cleanup');
    final reported = <Object>[];

    await expectLater(
      TestAppDependenciesBuilder(
        environment: _localEnvironment(),
        builder: (_) => throw callbackFailure,
        onError: (error, _) => reported.add(error),
        graphBuilder: (stack) async {
          stack.register(Object(), (_) => throw cleanupFailure);

          return fakeAppDependencies(resourceDisposalStack: stack);
        },
      ).build(),
      throwsA(same(callbackFailure)),
    );

    expect(reported, [cleanupFailure]);
  });

  test('transfers ownership after a successful callback', () async {
    var cleanupCount = 0;
    late final AppDependencies dependencies;

    await TestAppDependenciesBuilder(
      environment: _localEnvironment(),
      builder: (value) => dependencies = value,
      onError: (_, _) {},
      graphBuilder: (stack) async {
        stack.register(Object(), (_) => cleanupCount += 1);

        return fakeAppDependencies(resourceDisposalStack: stack);
      },
    ).build();

    expect(cleanupCount, 0);
    await dependencies.dispose();
    expect(cleanupCount, 1);
  });
}

AppEnvironment _localEnvironment() => AppEnvironment(
  kind: AppEnvironmentKind.local,
  rpc: RpcEnvironment(url: Uri.parse('http://localhost:8899')),
  wallet: WalletEnvironment(
    storageKey: 'wallet_test_v1',
    funding: RpcAirdropFundingConfig(
      minimumBalanceLamports: 1,
      airdropRpcUri: Uri.parse('http://localhost:8899'),
      airdropLamports: 1,
    ),
  ),
  peerInvite: PeerInviteEnvironment(
    url: Uri.parse('http://localhost:8080/home?intent=p2p&role=viewer'),
  ),
  keyBroker: const KeyBrokerEnvironment(
    config: LocalKeyBrokerConfig(),
  ),
);
