import 'package:meta/meta.dart';

part 'balance_only_funding_config.dart';
part 'rpc_airdrop_funding_config.dart';
part 'rpc_airdrop_with_faucet_funding_config.dart';

/// Configuration accepted by the Solana wallet funding assembly.
@immutable
sealed class WalletFundingConfig {
  /// Confirmed balance required before wallet-dependent operations can run.
  final int minimumBalanceLamports;

  const WalletFundingConfig({
    required this.minimumBalanceLamports,
  });
}
