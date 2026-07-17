import 'package:meta/meta.dart';
import 'package:solana_wallet/solana_wallet_assembly.dart';
import 'package:sols_stream/core/config/configuration_error.dart';

/// Validated wallet identity and funding configuration.
@immutable
final class WalletEnvironment {
  /// Secure-storage record used for the app-managed wallet identity.
  final String storageKey;

  /// Validated provider-specific funding configuration.
  final WalletFundingConfig funding;

  static const String _storageKeyKey = 'WALLET_STORAGE_KEY';
  static const String _minimumBalanceKey = 'WALLET_MINIMUM_BALANCE_LAMPORTS';
  static const String _airdropLamportsKey = 'WALLET_AIRDROP_LAMPORTS';
  static const String _fundingModeKey = 'WALLET_FUNDING_MODE';
  static const String _airdropRpcKey = 'SOLANA_AIRDROP_RPC_URL';
  static const String _faucetKey = 'SOLANA_FAUCET_URL';

  static const String _storageKeyRaw = String.fromEnvironment(_storageKeyKey);
  static const String _minimumBalanceRaw = String.fromEnvironment(
    _minimumBalanceKey,
  );
  static const String _airdropLamportsRaw = String.fromEnvironment(
    _airdropLamportsKey,
  );
  static const String _fundingModeRaw = String.fromEnvironment(_fundingModeKey);
  static const String _airdropRpcRaw = String.fromEnvironment(_airdropRpcKey);
  static const String _faucetRaw = String.fromEnvironment(_faucetKey);

  const WalletEnvironment({
    required this.storageKey,
    required this.funding,
  });

  /// Loads wallet configuration from compile-time dart defines.
  static WalletEnvironment fromDartDefines() => fromValues(
    storageKey: _storageKeyRaw,
    minimumBalanceLamports: _minimumBalanceRaw,
    airdropLamports: _airdropLamportsRaw,
    fundingMode: _fundingModeRaw,
    airdropRpcUrl: _airdropRpcRaw,
    faucetUrl: _faucetRaw,
  );

  /// Parses and validates wallet configuration values.
  @visibleForTesting
  static WalletEnvironment fromValues({
    required String storageKey,
    required String minimumBalanceLamports,
    String? airdropLamports,
    required String fundingMode,
    String? airdropRpcUrl,
    String? faucetUrl,
  }) {
    final normalizedStorageKey = storageKey.trim();
    if (normalizedStorageKey.isEmpty) {
      throw const ConfigurationError(
        'Invalid or missing $_storageKeyKey.',
      );
    }

    final minimumBalance = _integer(
      _minimumBalanceKey,
      minimumBalanceLamports,
    );
    final normalizedAirdropLamports = airdropLamports?.trim();
    final parsedAirdropLamports = normalizedAirdropLamports == null || normalizedAirdropLamports.isEmpty
        ? null
        : _integer(_airdropLamportsKey, normalizedAirdropLamports);
    final airdropRpcUri = _optionalUri(_airdropRpcKey, airdropRpcUrl);
    final faucetUri = _optionalUri(_faucetKey, faucetUrl);

    final WalletFundingConfig funding;
    switch (fundingMode.trim()) {
      case 'balance_only':
        if (parsedAirdropLamports != null || airdropRpcUri != null || faucetUri != null) {
          throw const ConfigurationError(
            'balance_only funding must not configure airdrop or faucet values.',
          );
        }

        funding = BalanceOnlyFundingConfig(
          minimumBalanceLamports: minimumBalance,
        );
      case 'rpc_airdrop':
        if (parsedAirdropLamports == null || airdropRpcUri == null || faucetUri != null) {
          throw const ConfigurationError(
            'rpc_airdrop requires $_airdropLamportsKey and '
            '$_airdropRpcKey and forbids $_faucetKey.',
          );
        }

        funding = RpcAirdropFundingConfig(
          minimumBalanceLamports: minimumBalance,
          airdropRpcUri: airdropRpcUri,
          airdropLamports: parsedAirdropLamports,
        );
      case 'rpc_airdrop_with_faucet':
        if (parsedAirdropLamports == null || airdropRpcUri == null || faucetUri == null) {
          throw const ConfigurationError(
            'rpc_airdrop_with_faucet requires $_airdropLamportsKey, '
            '$_airdropRpcKey, and $_faucetKey.',
          );
        }

        funding = RpcAirdropWithFaucetFundingConfig(
          minimumBalanceLamports: minimumBalance,
          airdropRpcUri: airdropRpcUri,
          faucetUri: faucetUri,
          airdropLamports: parsedAirdropLamports,
        );
      default:
        throw const ConfigurationError(
          'Invalid or missing $_fundingModeKey. Expected balance_only, '
          'rpc_airdrop, or rpc_airdrop_with_faucet.',
        );
    }

    return WalletEnvironment(
      storageKey: normalizedStorageKey,
      funding: funding,
    );
  }

  static Uri? _optionalUri(String key, String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null) {
      throw ConfigurationError(
        '$key must be a valid URI.',
      );
    }

    return uri;
  }

  static int _integer(String key, String raw) {
    final value = int.tryParse(raw.trim());
    if (value == null) {
      throw ConfigurationError('$key must be an integer.');
    }

    return value;
  }
}
