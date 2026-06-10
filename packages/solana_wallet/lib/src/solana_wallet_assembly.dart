import 'package:secure_storage/secure_storage.dart';
import 'package:solana/solana.dart' show RpcClient;
import 'package:solana_wallet/src/data/solana_wallet.dart';
import 'package:solana_wallet/src/data/wallet_key_store.dart';
import 'package:solana_wallet/src/domain/funding_gateway.dart';
import 'package:solana_wallet/src/domain/solana_signer.dart';
import 'package:solana_wallet/src/domain/wallet_account.dart';

/// Composition of the wallet bounded context. Resolves the keypair via the key
/// store and exposes only the published ports — never the concrete adapter,
/// the keypair, or the [RpcClient].
final class SolanaWalletAssembly {
  /// Signing port (sign only).
  final SolanaSigner signer;

  /// Account port (identity, balance, funding).
  final WalletAccount account;

  const SolanaWalletAssembly._({
    required this.signer,
    required this.account,
  });

  /// Loads or creates the wallet keypair, then wires the wallet adapter.
  ///
  /// Throws [WalletStorageException] if stored key material is unreadable.
  static Future<SolanaWalletAssembly> create({
    required SecureStorage storage,
    required RpcClient rpc,
    required FundingGateway fundingGateway,
    required String storageKey,
  }) async {
    final keypair = await WalletKeyStore(storage, storageKey).loadOrCreate();
    final wallet = SolanaWallet(keypair, rpc, fundingGateway);

    return SolanaWalletAssembly._(signer: wallet, account: wallet);
  }
}
