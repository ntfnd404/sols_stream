import 'package:sols_stream/core/config/app_environment.dart';
import 'package:sols_stream/core/config/app_environment_kind.dart';
import 'package:sols_stream/core/config/configuration_error.dart';
import 'package:sols_stream/core/config/key_broker_environment.dart';
import 'package:sols_stream/core/config/peer_invite_environment.dart';
import 'package:sols_stream/core/config/public_client_endpoint_policy.dart';
import 'package:sols_stream/core/config/rpc_environment.dart';
import 'package:sols_stream/core/config/wallet_environment.dart';

final class DartDefineFileValidator {
  static const Set<String> _allowedKeys = {
    'APP_ENVIRONMENT',
    'SOLANA_RPC_URL',
    'WALLET_STORAGE_KEY',
    'WALLET_MINIMUM_BALANCE_LAMPORTS',
    'WALLET_FUNDING_MODE',
    'WALLET_AIRDROP_LAMPORTS',
    'SOLANA_AIRDROP_RPC_URL',
    'SOLANA_FAUCET_URL',
    'PEER_INVITE_BASE_URL',
    'KEY_BROKER_MODE',
    'KEY_BROKER_URL',
  };

  static const Set<String> _baseKeys = {
    'APP_ENVIRONMENT',
    'SOLANA_RPC_URL',
    'WALLET_STORAGE_KEY',
    'WALLET_MINIMUM_BALANCE_LAMPORTS',
    'WALLET_FUNDING_MODE',
    'PEER_INVITE_BASE_URL',
    'KEY_BROKER_MODE',
  };

  const DartDefineFileValidator();

  void validate(String contents) {
    final values = _parse(contents);
    final kind = _environmentKind(_required(values, 'APP_ENVIRONMENT'));
    _validateKeys(values.keys.toSet(), kind);

    try {
      final rpc = RpcEnvironment(
        url: PublicClientEndpointPolicy.parse(
          key: 'SOLANA_RPC_URL',
          value: _required(values, 'SOLANA_RPC_URL'),
          kind: PublicClientEndpointKind.rpc,
        ),
      );
      final wallet = WalletEnvironment.fromValues(
        storageKey: _required(values, 'WALLET_STORAGE_KEY'),
        minimumBalanceLamports: _required(
          values,
          'WALLET_MINIMUM_BALANCE_LAMPORTS',
        ),
        airdropLamports: values['WALLET_AIRDROP_LAMPORTS'],
        fundingMode: _required(values, 'WALLET_FUNDING_MODE'),
        airdropRpcUrl: values['SOLANA_AIRDROP_RPC_URL'],
        faucetUrl: values['SOLANA_FAUCET_URL'],
      );
      final peerInviteUri = Uri.tryParse(
        _required(values, 'PEER_INVITE_BASE_URL'),
      );
      if (peerInviteUri == null) {
        throw const ConfigurationError(
          'Invalid PEER_INVITE_BASE_URL contract.',
        );
      }
      final peerInvite = PeerInviteEnvironment(url: peerInviteUri);
      final keyBroker = KeyBrokerEnvironment.fromValues(
        mode: _required(values, 'KEY_BROKER_MODE'),
        url: values['KEY_BROKER_URL'],
      );

      AppEnvironment(
        kind: kind,
        rpc: rpc,
        wallet: wallet,
        peerInvite: peerInvite,
        keyBroker: keyBroker,
      );
    } on ConfigurationError {
      throw const DartDefineValidationException(
        'Dart-define values violate the application configuration contract.',
      );
    }
  }

  Map<String, String> _parse(String contents) {
    final values = <String, String>{};
    final lines = contents.split('\n');
    for (var index = 0; index < lines.length; index++) {
      final rawLine = lines[index];
      final line = rawLine.endsWith('\r') ? rawLine.substring(0, rawLine.length - 1) : rawLine;
      final normalized = line.trim();
      if (normalized.isEmpty || normalized.startsWith('#')) continue;
      if (line != normalized) {
        throw DartDefineValidationException(
          'Invalid configuration syntax at line ${index + 1}.',
        );
      }

      final separator = line.indexOf('=');
      if (separator <= 0) {
        throw DartDefineValidationException(
          'Invalid configuration syntax at line ${index + 1}.',
        );
      }
      final key = line.substring(0, separator);
      final value = line.substring(separator + 1);
      if (key != key.trim() || value != value.trim()) {
        throw DartDefineValidationException(
          'Invalid configuration syntax at line ${index + 1}.',
        );
      }
      if (!RegExp(r'^[A-Z][A-Z0-9_]*$').hasMatch(key)) {
        throw DartDefineValidationException(
          'Invalid configuration key at line ${index + 1}.',
        );
      }
      if (!_allowedKeys.contains(key)) {
        throw DartDefineValidationException(
          'Unsupported dart-define key: $key.',
        );
      }
      if (values.containsKey(key)) {
        throw DartDefineValidationException(
          'Duplicate dart-define key: $key.',
        );
      }
      if (value.isEmpty) {
        throw DartDefineValidationException(
          'Empty dart-define value for key: $key.',
        );
      }
      values[key] = value;
    }

    return values;
  }

  AppEnvironmentKind _environmentKind(String value) => switch (value) {
    'local' => AppEnvironmentKind.local,
    'dev' => AppEnvironmentKind.dev,
    'prod' => AppEnvironmentKind.prod,
    _ => throw const DartDefineValidationException(
      'Invalid APP_ENVIRONMENT. Expected local, dev, or prod.',
    ),
  };

  String _required(Map<String, String> values, String key) {
    final value = values[key];
    if (value == null) {
      throw DartDefineValidationException(
        'Missing required dart-define key: $key.',
      );
    }

    return value;
  }

  void _validateKeys(Set<String> actual, AppEnvironmentKind kind) {
    final expected = switch (kind) {
      AppEnvironmentKind.local => {
        ..._baseKeys,
        'WALLET_AIRDROP_LAMPORTS',
        'SOLANA_AIRDROP_RPC_URL',
      },
      AppEnvironmentKind.dev => {
        ..._baseKeys,
        'WALLET_AIRDROP_LAMPORTS',
        'SOLANA_AIRDROP_RPC_URL',
        'SOLANA_FAUCET_URL',
        'KEY_BROKER_URL',
      },
      AppEnvironmentKind.prod => {
        ..._baseKeys,
        'KEY_BROKER_URL',
      },
    };
    final missing = expected.difference(actual);
    if (missing.isNotEmpty) {
      throw DartDefineValidationException(
        'Missing required dart-define key: ${missing.first}.',
      );
    }
    final forbidden = actual.difference(expected);
    if (forbidden.isNotEmpty) {
      throw DartDefineValidationException(
        'Forbidden dart-define key for ${kind.name}: ${forbidden.first}.',
      );
    }
  }
}

final class DartDefineValidationException implements Exception {
  final String message;

  const DartDefineValidationException(this.message);

  @override
  String toString() => message;
}
