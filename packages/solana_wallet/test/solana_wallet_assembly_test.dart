import 'package:mocktail/mocktail.dart';
import 'package:solana_wallet/solana_wallet_assembly.dart';
import 'package:test/test.dart';

import 'fakes/fake_secure_storage.dart';
import 'mocks/mock_http_client.dart';
import 'mocks/mock_rpc_client.dart';

void main() {
  test('balance-only mode does not create an HTTP client', () async {
    var clientCreated = false;
    final assembly = await SolanaWalletAssembly.create(
      storage: FakeSecureStorage(),
      rpc: MockRpcClient(),
      funding: const BalanceOnlyFundingConfig(
        minimumBalanceLamports: 1,
      ),
      storageKey: 'wallet',
      httpClientFactory: () {
        clientCreated = true;

        return MockHttpClient();
      },
    );

    expect(assembly.reader.address, isNotEmpty);
    expect(clientCreated, isFalse);
    await assembly.dispose();
  });

  test('RPC-only mode does not create an HTTP client', () async {
    var clientCreated = false;
    final assembly = await SolanaWalletAssembly.create(
      storage: FakeSecureStorage(),
      rpc: MockRpcClient(),
      funding: RpcAirdropFundingConfig(
        minimumBalanceLamports: 1,
        airdropRpcUri: Uri.parse('http://localhost:8899'),
        airdropLamports: 2,
      ),
      storageKey: 'wallet',
      httpClientFactory: () {
        clientCreated = true;

        return MockHttpClient();
      },
    );

    expect(clientCreated, isFalse);
    await assembly.dispose();
  });

  test('faucet mode owns and closes its HTTP client once', () async {
    final client = MockHttpClient();
    var closeCount = 0;
    when(() => client.close()).thenAnswer((_) {
      closeCount += 1;
    });
    final assembly = await SolanaWalletAssembly.create(
      storage: FakeSecureStorage(),
      rpc: MockRpcClient(),
      funding: RpcAirdropWithFaucetFundingConfig(
        minimumBalanceLamports: 1,
        airdropRpcUri: Uri.parse('https://api.devnet.solana.com'),
        faucetUri: Uri.parse('https://faucet.example.com'),
        airdropLamports: 2,
      ),
      storageKey: 'wallet',
      httpClientFactory: () => client,
    );

    await assembly.dispose();
    await assembly.dispose();
    expect(closeCount, 1);
  });

  test('validates funding before loading wallet storage', () async {
    final storage = FakeSecureStorage(throwOnGet: true);

    await expectLater(
      SolanaWalletAssembly.create(
        storage: storage,
        rpc: MockRpcClient(),
        funding: RpcAirdropFundingConfig(
          minimumBalanceLamports: 0,
          airdropRpcUri: Uri.parse('http://localhost:8899'),
          airdropLamports: 1,
        ),
        storageKey: 'wallet',
      ),
      throwsArgumentError,
    );
  });

  test('rejects an airdrop that cannot fund a new wallet to the floor', () async {
    await expectLater(
      SolanaWalletAssembly.create(
        storage: FakeSecureStorage(throwOnGet: true),
        rpc: MockRpcClient(),
        funding: RpcAirdropFundingConfig(
          minimumBalanceLamports: 2,
          airdropRpcUri: Uri.parse('http://localhost:8899'),
          airdropLamports: 1,
        ),
        storageKey: 'wallet',
      ),
      throwsArgumentError,
    );
  });

  test('rejects values that are not exactly representable on Flutter Web', () async {
    await expectLater(
      SolanaWalletAssembly.create(
        storage: FakeSecureStorage(throwOnGet: true),
        rpc: MockRpcClient(),
        funding: const BalanceOnlyFundingConfig(
          minimumBalanceLamports: 0x20000000000000,
        ),
        storageKey: 'wallet',
      ),
      throwsArgumentError,
    );
  });

  test('rejects funding endpoints that violate runtime invariants', () async {
    for (final uri in [
      Uri.parse('relative-rpc-path'),
      Uri.parse('ftp://api.devnet.solana.com'),
      Uri.parse('https://user@example.com'),
      Uri.parse('https://api.devnet.solana.com#fragment'),
    ]) {
      await expectLater(
        SolanaWalletAssembly.create(
          storage: FakeSecureStorage(throwOnGet: true),
          rpc: MockRpcClient(),
          funding: RpcAirdropFundingConfig(
            minimumBalanceLamports: 1,
            airdropRpcUri: uri,
            airdropLamports: 1,
          ),
          storageKey: 'wallet',
        ),
        throwsArgumentError,
      );
    }
  });
}
