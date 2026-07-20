import 'package:flutter_test/flutter_test.dart';
import 'package:solana_wallet/solana_wallet_assembly.dart';
import 'package:sols_stream/core/config/configuration_error.dart';
import 'package:sols_stream/core/config/wallet_environment.dart';

void main() {
  test('parses RPC airdrop configuration without nullable provider fields', () {
    final environment = WalletEnvironment.fromValues(
      storageKey: 'sols_stream_wallet_dev_v1',
      minimumBalanceLamports: '20000000',
      airdropLamports: '40000000',
      fundingMode: 'rpc_airdrop',
      airdropRpcUrl: 'http://localhost:8899',
    );

    expect(environment.storageKey, 'sols_stream_wallet_dev_v1');
    expect(
      environment.funding,
      isA<RpcAirdropFundingConfig>()
          .having(
            (config) => config.minimumBalanceLamports,
            'minimum balance',
            20_000_000,
          )
          .having(
            (config) => config.airdropLamports,
            'airdrop',
            40_000_000,
          ),
    );
  });

  test('parses balance-only configuration', () {
    final environment = WalletEnvironment.fromValues(
      storageKey: 'wallet',
      minimumBalanceLamports: '1',
      fundingMode: 'balance_only',
    );

    expect(environment.funding, isA<BalanceOnlyFundingConfig>());
  });

  test('parses RPC and faucet fallback configuration', () {
    final environment = WalletEnvironment.fromValues(
      storageKey: 'wallet',
      minimumBalanceLamports: '1',
      airdropLamports: '2',
      fundingMode: 'rpc_airdrop_with_faucet',
      airdropRpcUrl: 'https://api.devnet.solana.com',
      faucetUrl: 'https://faucet.example.com',
    );

    expect(
      environment.funding,
      isA<RpcAirdropWithFaucetFundingConfig>(),
    );
  });

  test('leaves numeric invariants to the wallet assembly', () {
    final environment = WalletEnvironment.fromValues(
      storageKey: 'wallet',
      minimumBalanceLamports: '0',
      airdropLamports: '-1',
      fundingMode: 'rpc_airdrop',
      airdropRpcUrl: 'https://api.devnet.solana.com',
    );
    final funding = environment.funding as RpcAirdropFundingConfig;

    expect(funding.minimumBalanceLamports, 0);
    expect(funding.airdropLamports, -1);
    expect(
      funding.airdropRpcUri,
      Uri.parse('https://api.devnet.solana.com'),
    );
  });

  test('rejects credential-bearing client funding endpoints', () {
    for (final endpoint in [
      'relative-rpc-path',
      'https://user@example.com',
      'https://api.devnet.solana.com/path',
      'https://api.devnet.solana.com?token=secret',
      'https://api.devnet.solana.com#fragment',
    ]) {
      expect(
        () => WalletEnvironment.fromValues(
          storageKey: 'wallet',
          minimumBalanceLamports: '1',
          airdropLamports: '2',
          fundingMode: 'rpc_airdrop',
          airdropRpcUrl: endpoint,
        ),
        throwsA(isA<ConfigurationError>()),
      );
    }
  });

  test('allows a public faucet path without credentials', () {
    final environment = WalletEnvironment.fromValues(
      storageKey: 'wallet',
      minimumBalanceLamports: '1',
      airdropLamports: '2',
      fundingMode: 'rpc_airdrop_with_faucet',
      airdropRpcUrl: 'https://api.devnet.solana.com',
      faucetUrl: 'https://faucet.example.com/fund',
    );

    final funding = environment.funding as RpcAirdropWithFaucetFundingConfig;
    expect(funding.faucetUri.path, '/fund');
  });

  test('rejects invalid combinations and identity keys', () {
    expect(
      () => WalletEnvironment.fromValues(
        storageKey: 'wallet',
        minimumBalanceLamports: '1',
        airdropLamports: '2',
        fundingMode: 'balance_only',
      ),
      throwsA(isA<ConfigurationError>()),
    );
    expect(
      () => WalletEnvironment.fromValues(
        storageKey: 'wallet',
        minimumBalanceLamports: '1',
        fundingMode: 'rpc_airdrop',
        airdropRpcUrl: 'https://api.devnet.solana.com',
      ),
      throwsA(isA<ConfigurationError>()),
    );
  });
}
