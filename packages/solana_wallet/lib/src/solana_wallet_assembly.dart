import 'package:secure_storage/secure_storage.dart';
import 'package:solana/solana.dart';

import 'package:solana_wallet/src/solana_wallet_manager.dart';

final class SolanaWalletAssembly {
  final SolanaWalletManager manager;

  factory SolanaWalletAssembly({
    required SecureStorage storage,
    required String rpcUrl,
    required String airdropUrl,
    required Uri faucetUri,
  }) {
    final manager = SolanaWalletManager(
      storage,
      rpc: RpcClient(rpcUrl),
      airdropRpc: RpcClient(airdropUrl),
      faucetUri: faucetUri,
    );

    return SolanaWalletAssembly._(manager: manager);
  }

  const SolanaWalletAssembly._({required this.manager});
}
