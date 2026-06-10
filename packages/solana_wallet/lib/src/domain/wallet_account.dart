import 'package:solana/solana.dart' show Ed25519HDPublicKey;

/// The wallet's own account: identity, balance, and funding.
///
/// Published port for the UI and for contexts that need balance/funding (e.g.
/// the signaling context ensures the payer is funded before writing on-chain).
/// Holds no transport detail — implementations talk to the chain internally.
abstract interface class WalletAccount {
  /// The account's public key.
  Ed25519HDPublicKey get publicKey;

  /// Base58 address of [publicKey].
  String get address;

  /// Current balance in lamports.
  Future<int> getBalance();

  /// Ensures the account holds enough lamports to transact, funding it if the
  /// configured strategy allows. Returns true if the account is funded.
  Future<bool> ensureFunded();
}
