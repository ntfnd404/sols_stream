import 'package:solana_wallet/src/data/funding/funding_request_outcome.dart';

/// Provider-specific request that may add lamports to [address].
///
/// Confirmation belongs to the coordinating funding gateway. An
/// [FundingRequestOutcome.indeterminate] result must be reconciled against the
/// confirmed balance before another source is attempted.
abstract interface class FundingSource {
  Future<FundingRequestOutcome> requestFunding(String address);
}
