import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';

// These syntax-level checks are regression guardrails, not a resolved semantic
// model. Behavioral tests remain authoritative for coordinator wiring.
const _workspacePackages = {
  '.': 'sols_stream',
  'packages/secure_storage': 'secure_storage',
  'packages/signaling': 'signaling',
  'packages/signaling_solana': 'signaling_solana',
  'packages/solana_wallet': 'solana_wallet',
  'packages/realtime_media': 'realtime_media',
  'packages/streaming': 'streaming',
  'packages/ui_kit': 'ui_kit',
};

void main() {
  test('owned protocol, provider, and adapter packages do not import Flutter', () {
    const packages = [
      'packages/solana_wallet',
      'packages/signaling',
      'packages/signaling_solana',
    ];

    for (final package in packages) {
      final imports = _dartFiles(
        package,
      ).expand(_importUris).where((uri) => uri.startsWith('package:flutter/')).toList();

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

  test('workspace packages do not deep-import each other src internals', () {
    final localNames = _workspacePackages.values.toSet();
    final deepImport = RegExp(r'^package:([^/]+)/src/');
    final offenders = <String>[];

    for (final entry in _workspacePackages.entries) {
      final libRoot = entry.key == '.' ? 'lib' : '${entry.key}/lib';
      for (final file in _dartFiles(libRoot)) {
        for (final uri in _importUris(file)) {
          final importedPackage = deepImport.firstMatch(uri)?.group(1);
          if (importedPackage != null && importedPackage != entry.value && localNames.contains(importedPackage)) {
            offenders.add('${file.path}: $uri');
          }
        }
      }
    }

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
              (file) => _importUris(
                file,
              ).where((uri) => uri.startsWith('package:flutter/')).map((uri) => '${file.path}: $uri'),
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
    final offenders = _dartFiles(
      'lib',
    ).expand((file) => _methodInvocations(file, 'signAndSend').map((offset) => '${file.path}:$offset')).toList();

    expect(
      offenders,
      isEmpty,
      reason: 'broadcasts must cross the signaling transaction coordinator',
    );
  });

  test('application dependency graph does not expose the raw Solana signer', () {
    final dependencies = File('lib/core/di/app_dependencies.dart');

    expect(_namedTypes(dependencies), isNot(contains('SolanaSigner')));
  });

  test('signaling Solana barrel exports only its assembly', () {
    final exports = _exportUris(File('packages/signaling_solana/lib/signaling_solana.dart'));

    expect(exports, ['src/signaling_solana_assembly.dart']);
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

  test('owned core, protocol, and provider APIs do not use dynamic', () {
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

CompilationUnit _parse(File file) => parseString(content: file.readAsStringSync(), path: file.path).unit;

Iterable<String> _importUris(File file) =>
    _parse(file).directives.whereType<ImportDirective>().map((directive) => directive.uri.stringValue).nonNulls;

List<String> _exportUris(File file) => _parse(
  file,
).directives.whereType<ExportDirective>().map((directive) => directive.uri.stringValue).nonNulls.toList();

List<int> _methodInvocations(File file, String methodName) {
  final visitor = _MethodInvocationVisitor(methodName);
  _parse(file).accept(visitor);
  return visitor.offsets;
}

List<String> _namedTypes(File file) {
  final visitor = _NamedTypeVisitor();
  _parse(file).accept(visitor);
  return visitor.types;
}

final class _MethodInvocationVisitor extends RecursiveAstVisitor<void> {
  _MethodInvocationVisitor(this.methodName);

  final String methodName;
  final List<int> offsets = [];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == methodName) offsets.add(node.offset);
    super.visitMethodInvocation(node);
  }
}

final class _NamedTypeVisitor extends RecursiveAstVisitor<void> {
  final List<String> types = [];

  @override
  void visitNamedType(NamedType node) {
    types.add(node.toSource());
    super.visitNamedType(node);
  }
}
