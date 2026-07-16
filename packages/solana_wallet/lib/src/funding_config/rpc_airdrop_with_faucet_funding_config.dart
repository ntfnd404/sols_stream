part of 'wallet_funding_config.dart';

/// Tries a Solana RPC airdrop and then an HTTP faucet fallback.
final class RpcAirdropWithFaucetFundingConfig extends WalletFundingConfig {
  final Uri airdropRpcUri;
  final Uri faucetUri;
  final int airdropLamports;

  const RpcAirdropWithFaucetFundingConfig({
    required super.minimumBalanceLamports,
    required this.airdropRpcUri,
    required this.faucetUri,
    required this.airdropLamports,
  });
}
