import 'dart:typed_data';

/// Domain Value Object for the on-chain `ProgramConfig`, holding only what the
/// signaling domain reasons about today.
///
/// Translated from the wire DTO `ProgramConfigAccount` by `ProgramConfigMapper`
/// in the data layer. The governance authority, pricing/heartbeat parameters,
/// and PDA `bump` stay on the wire DTO — they are not needed by the reclaim
/// flow, which only routes the contract-mandated 1% skim to [serviceWallet].
class ProgramConfig {
  /// Wallet that must be passed as the skim recipient on every close/cleanup
  /// instruction. Read from chain, never hardcoded.
  final Uint8List serviceWallet;

  const ProgramConfig({required this.serviceWallet});
}
