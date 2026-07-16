/// Result of asking an external source to fund a wallet.
enum FundingRequestOutcome {
  /// The source accepted the request; balance confirmation is still required.
  accepted,

  /// Source policy permits the coordinator to try the next source.
  ///
  /// This does not claim exactly-once delivery or prove that an external
  /// system could not complete a late side effect.
  fallbackAllowed,

  /// The transport failed after dispatch, so funding may still complete.
  indeterminate,
}
