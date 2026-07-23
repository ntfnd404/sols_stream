import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/quality/dart_define_file_validator.dart';

void main() {
  const validator = DartDefineFileValidator();

  test('accepts every tracked application environment', () {
    for (final path in [
      'config/local.env',
      'config/dev.env',
      'config/prod.example.env',
    ]) {
      expect(
        () => validator.validate(File(path).readAsStringSync()),
        returnsNormally,
      );
    }
  });

  test('rejects malformed, duplicate, unknown, and missing keys', () {
    final local = File('config/local.env').readAsStringSync();
    final cases = {
      'MALFORMED': 'Invalid configuration syntax',
      'APP_ENVIRONMENT =local': 'Invalid configuration syntax',
      'APP_ENVIRONMENT= local': 'Invalid configuration syntax',
      '$local\nAPP_ENVIRONMENT=local': 'Duplicate dart-define key',
      '$local\nAPI_SECRET=do-not-render': 'Unsupported dart-define key',
      local.replaceFirst('SOLANA_RPC_URL=', 'REMOVED_SOLANA_RPC_URL='): 'Unsupported dart-define key',
    };

    for (final MapEntry(key: contents, value: expected) in cases.entries) {
      expect(
        () => validator.validate(contents),
        throwsA(
          isA<DartDefineValidationException>().having(
            (error) => error.message,
            'safe message',
            contains(expected),
          ),
        ),
      );
    }
  });

  test('never includes rejected values in diagnostics', () {
    const secret = 'credential-value-must-not-appear';
    final local = File('config/local.env').readAsStringSync();
    final hostile = local.replaceFirst(
      'SOLANA_RPC_URL=http://localhost:8899',
      'SOLANA_RPC_URL=https://rpc.example.com?token=$secret',
    );

    try {
      validator.validate(hostile);
      fail('Expected the hostile endpoint to be rejected.');
    } on DartDefineValidationException catch (error) {
      expect(error.message, isNot(contains(secret)));
      expect(error.message, isNot(contains('rpc.example.com')));
    }
  });

  test('normalizes nested validator diagnostics', () {
    const hostileHost = 'credential-host-must-not-appear.example.com';
    final dev = File('config/dev.env').readAsStringSync();
    final hostile = dev.replaceFirst(
      'KEY_BROKER_URL=https://turn.sols.stream',
      'KEY_BROKER_URL=https://user@$hostileHost?token=secret',
    );

    try {
      validator.validate(hostile);
      fail('Expected the hostile endpoint to be rejected.');
    } on DartDefineValidationException catch (error) {
      expect(error.message, isNot(contains(hostileHost)));
      expect(error.message, isNot(contains('token')));
    }
  });

  test('does not render malformed key text', () {
    const hostileKey = r'BAD[31mKEY';

    expect(
      () => validator.validate('$hostileKey=value'),
      throwsA(
        isA<DartDefineValidationException>()
            .having(
              (error) => error.message,
              'safe message',
              isNot(contains(hostileKey)),
            )
            .having(
              (error) => error.message,
              'reason',
              contains('Invalid configuration key'),
            ),
      ),
    );
  });

  test('enforces environment-specific required and forbidden keys', () {
    final local = File('config/local.env').readAsStringSync();
    final missing = local.split('\n').where((line) => !line.startsWith('SOLANA_AIRDROP_RPC_URL=')).join('\n');
    final forbidden = '$local\nKEY_BROKER_URL=https://broker.example.com';

    expect(
      () => validator.validate(missing),
      throwsA(isA<DartDefineValidationException>()),
    );
    expect(
      () => validator.validate(forbidden),
      throwsA(isA<DartDefineValidationException>()),
    );
  });
}
