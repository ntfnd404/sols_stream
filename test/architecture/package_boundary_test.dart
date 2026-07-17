import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DDD packages do not import Flutter', () {
    const packages = [
      'packages/solana_wallet',
      'packages/signaling',
      'packages/signaling_solana',
    ];

    for (final package in packages) {
      final imports = _dartFiles(
        package,
      ).expand((file) => file.readAsLinesSync()).where((line) => line.contains('package:flutter/')).toList();

      expect(imports, isEmpty, reason: '$package must stay Flutter-free');
    }
  });

  test('signaling context does not depend on Solana wallet adapter', () {
    final pubspec = File('packages/signaling/pubspec.yaml').readAsStringSync();

    expect(pubspec, isNot(contains('solana_wallet:')));
    expect(pubspec, isNot(contains('signaling_solana:')));
  });

  test('generic wallet shared kernel is absent', () {
    expect(Directory('packages/wallet').existsSync(), isFalse);

    final forbidden = RegExp(r'\b(?:WalletAccount|FundingGateway)\b');
    final offenders =
        [
              ..._dartFiles('packages/solana_wallet/lib'),
              ..._dartFiles('packages/signaling/lib'),
            ]
            .expand(
              (file) => file.readAsLinesSync().where(forbidden.hasMatch).map((line) => '${file.path}: $line'),
            )
            .toList();

    expect(offenders, isEmpty);
  });

  test('app code does not deep-import local package src internals', () {
    final offenders = _dartFiles('lib')
        .expand(
          (file) => file
              .readAsLinesSync()
              .where(
                (line) => RegExp(
                  r'package:(wallet|solana_wallet|signaling|signaling_solana|realtime_media|streaming|secure_storage|ui_kit)/src/',
                ).hasMatch(line),
              )
              .map((line) => '${file.path}: $line'),
        )
        .toList();

    expect(offenders, isEmpty);
  });

  test('pure core config and DI files do not import Flutter', () {
    final offenders =
        [
              ..._dartFiles('lib/core/config'),
              ..._dartFiles(
                'lib/core/di',
              ).where((file) => !file.path.endsWith('/app_scope.dart')),
            ]
            .expand(
              (file) => file
                  .readAsLinesSync()
                  .where((line) => line.contains('package:flutter/'))
                  .map((line) => '${file.path}: $line'),
            )
            .toList();

    expect(offenders, isEmpty);
  });

  test('composition root does not import concrete module adapters', () {
    final builder = File(
      'lib/core/di/app_dependencies_builder.dart',
    ).readAsStringSync();

    expect(builder, isNot(contains('/src/')));
    expect(builder, isNot(contains('ConfirmedBalanceFundingGateway')));
    expect(builder, isNot(contains('HttpKeyBrokerGateway')));
    expect(builder, isNot(contains('LocalKeyBrokerGateway')));
  });

  test('application code never broadcasts through the wallet signer directly', () {
    final offenders = _dartFiles('lib')
        .expand(
          (file) => file
              .readAsLinesSync()
              .where((line) => line.contains('.signAndSend('))
              .map((line) => '${file.path}: $line'),
        )
        .toList();

    expect(
      offenders,
      isEmpty,
      reason: 'broadcasts must cross the signaling transaction coordinator',
    );
  });

  test('Solana broadcasts are wired through one transaction coordinator', () {
    final assembly = File(
      'packages/signaling_solana/lib/src/signaling_solana_assembly.dart',
    ).readAsStringSync();
    final dependencies = File(
      'lib/core/di/app_dependencies.dart',
    ).readAsStringSync();

    expect(dependencies, isNot(contains('SolanaSigner')));
    expect(dependencies, isNot(contains('walletSigner')));
    expect(assembly, contains('SolanaTransactionCoordinator('));
    expect(assembly, contains('final fundedSigner = transactions.fundedSigner;'));
    expect(assembly, contains('final bypassSigner = transactions.bypassSigner;'));
    expect(assembly, contains('SolanaSignalingChainGateway(\n      fundedSigner,'));
    expect(assembly, contains('cleanupSigner: bypassSigner'));
    expect(assembly, contains('SolanaSignalingReclaimGateway(\n      bypassSigner,'));
    expect(assembly, contains('SolanaProtectedSlotGateway(\n      fundedSigner,'));
  });

  test('signaling Solana barrel exports only its assembly', () {
    final exports = File(
      'packages/signaling_solana/lib/signaling_solana.dart',
    ).readAsLinesSync().where((line) => line.trimLeft().startsWith('export ')).toList();

    expect(exports, ["export 'src/signaling_solana_assembly.dart';"]);
  });

  test('application depends only on the PeerSignaling port', () {
    final callBloc = File(
      'lib/feature/call/bloc/call_bloc.dart',
    ).readAsStringSync();

    expect(callBloc, contains('PeerSignaling'));
    expect(callBloc, isNot(contains('OnChainPeerSignaling')));
    expect(callBloc, isNot(contains('SolanaSignaling')));
    expect(callBloc, isNot(contains('WebInterop')));
  });

  test('legacy and Web-prefixed signaling APIs are absent', () {
    const forbidden = [
      'WebInteropSignaling',
      'WebHostSession',
      'WebFetchedOffer',
      'WebConnectionUrlCodec',
      'SolanaSignaling',
      'sols://',
    ];
    final offenders = _dartFiles('packages/signaling/lib')
        .expand(
          (file) =>
              file.readAsLinesSync().where((line) => forbidden.any(line.contains)).map((line) => '${file.path}: $line'),
        )
        .toList();

    expect(offenders, isEmpty);
  });

  test('owned core and bounded-context APIs do not use dynamic', () {
    const roots = [
      'lib/core/config',
      'lib/core/di',
      'packages/solana_wallet/lib',
      'packages/signaling/lib',
    ];
    final offenders = roots
        .expand(_dartFiles)
        .expand(
          (file) => file
              .readAsLinesSync()
              .where((line) => RegExp(r'\bdynamic\b').hasMatch(line))
              .map((line) => '${file.path}: $line'),
        )
        .toList();

    expect(offenders, isEmpty);
  });
}

Iterable<File> _dartFiles(String root) =>
    Directory(root).listSync(recursive: true).whereType<File>().where((file) => file.path.endsWith('.dart'));
