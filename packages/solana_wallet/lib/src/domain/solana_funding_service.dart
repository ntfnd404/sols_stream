/// Ensures that the configured minimum native SOL balance is confirmed.
///
/// This temporary workspace-internal boolean contract is intentionally not a
/// retry or failure-classification API. `false` only means that the minimum
/// balance could not be confirmed after the configured funding sources ran.
abstract interface class SolanaFundingService {
  Future<bool> ensureFunded();
}
