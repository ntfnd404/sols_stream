part of 'wallet_funding_config.dart';

/// Requests wallet funding through a Solana JSON-RPC airdrop endpoint.
final class RpcAirdropFundingConfig extends WalletFundingConfig {
  final Uri airdropRpcUri;
  final int airdropLamports;

  const RpcAirdropFundingConfig({
    required super.minimumBalanceLamports,
    required this.airdropRpcUri,
    required this.airdropLamports,
  });
}
