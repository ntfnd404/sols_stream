import 'dart:typed_data';

/// Domain Value Object for the on-chain `ProgramConfig`, holding only what the
/// signaling domain reasons about today.
///
/// Translated from the wire DTO `ProgramConfigAccount` by `ProgramConfigMapper`
/// in the data layer. Pricing fields, governance authority, heartbeat TTL, and
/// PDA `bump` stay on the wire DTO until a phase needs them.
class ProgramConfig {
  /// Wallet that must be passed as the skim recipient on every close/cleanup
  /// instruction. Read from chain, never hardcoded.
  final Uint8List serviceWallet;

  /// Lamports charged by the program when purchasing TURN entitlement.
  final BigInt turnPriceLamports;

  /// Minimum allowed heartbeat interval, in seconds, as configured on-chain.
  /// A zero value means callers should fall back to their conservative default.
  final int minHeartbeatIntervalSeconds;

  const ProgramConfig({
    required this.serviceWallet,
    required this.turnPriceLamports,
    required this.minHeartbeatIntervalSeconds,
  });
}
