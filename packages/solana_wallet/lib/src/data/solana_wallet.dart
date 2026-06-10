import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';
import 'package:solana_wallet/src/domain/funding_gateway.dart';
import 'package:solana_wallet/src/domain/solana_signer.dart';
import 'package:solana_wallet/src/domain/wallet_account.dart';

/// Data-layer adapter implementing the wallet's published ports over a Solana
/// [RpcClient] and a locally-held keypair.
///
/// The private key lives inside [_keypair] and is never exposed — callers get
/// [SolanaSigner] (sign) or [WalletAccount] (identity/balance/funding), never
/// the key or the [RpcClient].
final class SolanaWallet implements SolanaSigner, WalletAccount {
  final Ed25519HDKeyPair _keypair;
  final RpcClient _rpc;
  final FundingGateway _fundingGateway;

  @override
  Ed25519HDPublicKey get publicKey => _keypair.publicKey;

  @override
  String get address => _keypair.publicKey.toBase58();

  SolanaWallet(
    this._keypair,
    this._rpc,
    this._fundingGateway,
  );

  @override
  Future<int> getBalance() async {
    final balance = await _rpc.getBalance(address, commitment: Commitment.confirmed);

    return balance.value;
  }

  @override
  Future<bool> ensureFunded() => _fundingGateway.ensureFunded(_keypair.publicKey);

  @override
  Future<String> signAndSend(List<Instruction> instructions) => _rpc.signAndSendTransaction(
    Message(instructions: instructions),
    [_keypair],
    commitment: Commitment.confirmed,
  );
}
