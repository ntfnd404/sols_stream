import 'dart:typed_data';

/// Wire-layer DTO: a faithful 1:1 image of the on-chain `ProgramConfig`
/// account's Borsh layout. Lives in the data layer as the Anti-Corruption
/// boundary — the domain never sees Borsh field names or the PDA `bump`.
///
/// Translated into the domain [ProgramConfig] by [ProgramConfigMapper], which
/// keeps only what the signaling domain reasons about today (`serviceWallet`).
/// The governance/pricing fields are preserved here so the wire schema stays
/// self-documenting even though the domain drops them.
class ProgramConfigAccount {
  /// Governance authority allowed to mutate the config.
  final Uint8List authority;

  /// Wallet that receives the 1% skim on every close/cleanup.
  final Uint8List serviceWallet;

  final BigInt turnPrice;
  final BigInt signalFee;
  final BigInt heartbeatTtl;
  final BigInt minHeartbeatInterval;
  final int bump;

  const ProgramConfigAccount({
    required this.authority,
    required this.serviceWallet,
    required this.turnPrice,
    required this.signalFee,
    required this.heartbeatTtl,
    required this.minHeartbeatInterval,
    required this.bump,
  });
}
