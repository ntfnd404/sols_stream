import 'package:flutter_test/flutter_test.dart';
import 'package:signaling/key_broker_assembly.dart';
import 'package:solana_wallet/solana_wallet_assembly.dart';
import 'package:sols_stream/core/config/app_environment.dart';
import 'package:sols_stream/core/config/app_environment_kind.dart';
import 'package:sols_stream/core/config/configuration_error.dart';
import 'package:sols_stream/core/config/key_broker_environment.dart';
import 'package:sols_stream/core/config/peer_invite_environment.dart';
import 'package:sols_stream/core/config/rpc_environment.dart';
import 'package:sols_stream/core/config/wallet_environment.dart';

void main() {
  test('accepts a local graph only with loopback services', () {
    expect(
      _environment(
        kind: AppEnvironmentKind.local,
        rpc: 'http://localhost:8899',
        peerInvite: 'http://localhost:8080/home?intent=p2p&role=viewer',
        broker: const LocalKeyBrokerConfig(),
        funding: RpcAirdropFundingConfig(
          minimumBalanceLamports: 1,
          airdropRpcUri: Uri.parse('http://localhost:8899'),
          airdropLamports: 1,
        ),
      ),
      isA<AppEnvironment>(),
    );
    expect(
      () => _environment(
        kind: AppEnvironmentKind.local,
        rpc: 'https://api.devnet.solana.com',
        peerInvite: 'http://localhost:8080/home?intent=p2p&role=viewer',
        broker: const LocalKeyBrokerConfig(),
        funding: const BalanceOnlyFundingConfig(
          minimumBalanceLamports: 1,
        ),
      ),
      throwsA(isA<ConfigurationError>()),
    );
  });

  test('rejects local broker outside local', () {
    expect(
      () => _environment(
        kind: AppEnvironmentKind.dev,
        rpc: 'https://api.devnet.solana.com',
        peerInvite: 'http://localhost:8080/home?intent=p2p&role=viewer',
        broker: const LocalKeyBrokerConfig(),
        funding: const BalanceOnlyFundingConfig(
          minimumBalanceLamports: 1,
        ),
      ),
      throwsA(isA<ConfigurationError>()),
    );
  });

  test('production requires HTTPS and balance-only funding', () {
    final remoteBroker = HttpKeyBrokerConfig(
      endpoint: Uri.parse('https://broker.example.com'),
    );

    expect(
      _environment(
        kind: AppEnvironmentKind.prod,
        rpc: 'https://rpc.example.com',
        peerInvite: 'https://app.example.com/home?intent=p2p&role=viewer',
        broker: remoteBroker,
        funding: const BalanceOnlyFundingConfig(
          minimumBalanceLamports: 1,
        ),
      ),
      isA<AppEnvironment>(),
    );
    expect(
      () => _environment(
        kind: AppEnvironmentKind.prod,
        rpc: 'https://rpc.example.com',
        peerInvite: 'http://app.example.com/home?intent=p2p&role=viewer',
        broker: remoteBroker,
        funding: const BalanceOnlyFundingConfig(
          minimumBalanceLamports: 1,
        ),
      ),
      throwsA(isA<ConfigurationError>()),
    );

    for (final funding in <WalletFundingConfig>[
      RpcAirdropFundingConfig(
        minimumBalanceLamports: 1,
        airdropRpcUri: Uri.parse('https://api.mainnet-beta.solana.com'),
        airdropLamports: 1,
      ),
      RpcAirdropWithFaucetFundingConfig(
        minimumBalanceLamports: 1,
        airdropRpcUri: Uri.parse('https://api.mainnet-beta.solana.com'),
        faucetUri: Uri.parse('https://faucet.example.com'),
        airdropLamports: 1,
      ),
    ]) {
      expect(
        () => _environment(
          kind: AppEnvironmentKind.prod,
          rpc: 'https://rpc.example.com',
          peerInvite: 'https://app.example.com/home?intent=p2p&role=viewer',
          broker: remoteBroker,
          funding: funding,
        ),
        throwsA(isA<ConfigurationError>()),
      );
    }
  });
}

AppEnvironment _environment({
  required AppEnvironmentKind kind,
  required String rpc,
  required String peerInvite,
  required KeyBrokerConfig broker,
  required WalletFundingConfig funding,
}) => AppEnvironment(
  kind: kind,
  rpc: RpcEnvironment(url: Uri.parse(rpc)),
  wallet: WalletEnvironment(
    storageKey: 'wallet',
    funding: funding,
  ),
  peerInvite: PeerInviteEnvironment(url: Uri.parse(peerInvite)),
  keyBroker: KeyBrokerEnvironment(config: broker),
);
