/// Read-only Solana wallet capabilities intended for UI and diagnostics.
abstract interface class SolanaWalletReader {
  String get address;

  Future<int> getBalanceLamports();
}
