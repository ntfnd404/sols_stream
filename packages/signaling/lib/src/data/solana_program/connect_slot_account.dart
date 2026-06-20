import 'dart:typed_data';

/// Wire-layer DTO: a faithful 1:1 image of the on-chain ConnectSlot account's
/// Borsh layout. Lives in the data layer as the Anti-Corruption boundary — the
/// domain never sees Borsh field names, the PDA `bump`, or the reserved
/// protected-key fields.
///
/// Translated into the domain [ConnectSlotData] by [ConnectSlotMapper]. Holds
/// the raw `state` index (un-validated); the mapper resolves it to the domain
/// enum.
class ConnectSlotAccount {
  final Uint8List room;
  final Uint8List host;
  final Uint8List viewer;
  final int hostDeposit;
  final int viewerDeposit;

  /// Host's on-chain per-offer access key. Empty in the P2P flow (the key ships
  /// in the `prot` URL param). Reserved for access-controlled / paid rooms
  /// (monetization roadmap — see `docs/project/vision.md`); preserved here so
  /// the wire schema stays self-documenting even though the domain drops it.
  final Uint8List hostProtectedKey;
  final Uint8List offerData;

  /// Viewer's on-chain access key — see [hostProtectedKey]. Empty today.
  final Uint8List viewerProtectedKey;
  final Uint8List answerData;

  /// Raw on-chain state index. Resolved to `ConnectSlotState` by the mapper,
  /// which validates the range.
  final int stateIndex;
  final int createdAt;
  final int expiresAt;
  final int bump;

  const ConnectSlotAccount({
    required this.room,
    required this.host,
    required this.viewer,
    required this.hostDeposit,
    required this.viewerDeposit,
    required this.hostProtectedKey,
    required this.offerData,
    required this.viewerProtectedKey,
    required this.answerData,
    required this.stateIndex,
    required this.createdAt,
    required this.expiresAt,
    required this.bump,
  });
}
