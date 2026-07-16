part of 'wallet_funding_config.dart';

/// Checks the existing balance without requesting external funding.
final class BalanceOnlyFundingConfig extends WalletFundingConfig {
  const BalanceOnlyFundingConfig({
    required super.minimumBalanceLamports,
  });
}
