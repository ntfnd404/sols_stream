/// Internal funding strategy used by the concrete Solana wallet adapter.
abstract interface class SolanaFundingGateway {
  Future<bool> ensureFunded(String address);
}
