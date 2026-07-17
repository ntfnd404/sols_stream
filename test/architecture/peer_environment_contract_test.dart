import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final tooling = _readEnvironment('config/tooling/local_web.env');
  final environments = {
    for (final name in ['local', 'dev', 'prod.example']) name: _readEnvironment('config/$name.env'),
  };
  final expectedOrigin = Uri(
    scheme: 'http',
    host: tooling['LOCAL_WEB_BIND_HOST'],
    port: int.parse(tooling['LOCAL_WEB_BIND_PORT']!),
  );

  for (final environmentName in ['local', 'dev']) {
    test('$environmentName peer invite matches the local Flutter server', () {
      final environment = environments[environmentName]!;
      final viewerUrl = Uri.parse(environment['PEER_INVITE_BASE_URL']!);

      expect(environment['APP_ENVIRONMENT'], environmentName);
      _expectWalletProvisioning(environment, expectsAirdrop: true);
      expect(viewerUrl.origin, expectedOrigin.origin);
      expect(viewerUrl.path, '/home');
      expect(viewerUrl.queryParameters['intent'], 'p2p');
      expect(viewerUrl.queryParameters['role'], 'viewer');
    });
  }

  test('production example requires a public HTTPS peer invite', () {
    final environment = environments['prod.example']!;
    final viewerUrl = Uri.parse(environment['PEER_INVITE_BASE_URL']!);

    expect(environment['APP_ENVIRONMENT'], 'prod');
    expect(environment['KEY_BROKER_MODE'], 'http');
    expect(Uri.parse(environment['KEY_BROKER_URL']!).scheme, 'https');
    _expectWalletProvisioning(environment, expectsAirdrop: false);
    expect(viewerUrl.scheme, 'https');
    expect(viewerUrl.host, isNot(anyOf('localhost', '127.0.0.1')));
  });

  test('wallet identities are isolated without legacy migration', () {
    final storageKeys = environments.values.map((environment) => environment['WALLET_STORAGE_KEY']).toSet();

    expect(storageKeys, hasLength(environments.length));
    for (final environment in environments.values) {
      expect(environment, isNot(contains('WALLET_LEGACY_STORAGE_KEY')));
    }
  });

  test('only local uses the local key broker', () {
    expect(environments['local']!['KEY_BROKER_MODE'], 'local');
    expect(environments['local'], isNot(contains('KEY_BROKER_URL')));
    expect(environments['dev']!['KEY_BROKER_MODE'], 'http');
    expect(Uri.parse(environments['dev']!['KEY_BROKER_URL']!).scheme, 'https');
  });
}

void _expectWalletProvisioning(
  Map<String, String> environment, {
  required bool expectsAirdrop,
}) {
  expect(environment['WALLET_STORAGE_KEY'], isNotEmpty);
  expect(
    int.parse(environment['WALLET_MINIMUM_BALANCE_LAMPORTS']!),
    isPositive,
  );
  if (expectsAirdrop) {
    expect(int.parse(environment['WALLET_AIRDROP_LAMPORTS']!), isPositive);
  } else {
    expect(environment, isNot(contains('WALLET_AIRDROP_LAMPORTS')));
  }
}

Map<String, String> _readEnvironment(String path) {
  final values = <String, String>{};
  for (final rawLine in File(path).readAsLinesSync()) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final separator = line.indexOf('=');
    if (separator <= 0) continue;
    values[line.substring(0, separator)] = line.substring(separator + 1);
  }

  return values;
}
