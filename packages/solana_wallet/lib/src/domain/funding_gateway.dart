import 'package:solana/solana.dart' show Ed25519HDPublicKey;

/// Port for ensuring a wallet account holds enough lamports to transact.
///
/// This is a gateway to an external funding source (e.g. devnet airdrop +
/// faucet); adapters encapsulate the concrete mechanism. The composition root
/// injects the adapter, making "how funding works" an explicit, swappable
/// decision rather than a hidden default.
abstract interface class FundingGateway {
  /// Funds [account] if it is below the adapter's threshold. Returns true if
  /// the account ends up sufficiently funded.
  Future<bool> ensureFunded(Ed25519HDPublicKey account);
}
