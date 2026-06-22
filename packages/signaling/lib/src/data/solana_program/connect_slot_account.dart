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
  final BigInt hostDeposit;
  final BigInt viewerDeposit;

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
  final BigInt createdAt;
  final BigInt expiresAt;
  final int bump;

  /// Rent (lamports) the host paid to allocate the slot account. On close /
  /// cleanup the program returns this as part of a pro-rata distribution over
  /// deposits + rent + access price, after a 1% skim to the service wallet
  /// (+ a bounty to a third-party caller) — see `reference/program-client.js`
  /// (`cleanup_expired_slot` / `close_connect_slot`). Part of the Upgrade-07
  /// appended tail — defaults to 0 for slots written before the upgrade.
  final BigInt hostRentPaid;

  /// Rent (lamports) the viewer paid; see [hostRentPaid]. Upgrade-07 tail.
  final BigInt viewerRentPaid;

  /// Access price (lamports) snapshotted at claim time; 0 in the free P2P flow.
  /// Upgrade-07 tail. An input to the same close/cleanup refund math as the
  /// deposits and rent, so the mapper surfaces it to the domain.
  final BigInt accessPrice;

  /// Whether the host has confirmed the WebRTC connection (flips via
  /// `confirm_connection`). Upgrade-07 tail; defaults to `false` pre-upgrade.
  final bool hostConfirmed;

  /// Whether the viewer has confirmed the WebRTC connection; see
  /// [hostConfirmed]. Upgrade-07 tail.
  final bool viewerConfirmed;

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
    required this.hostRentPaid,
    required this.viewerRentPaid,
    required this.accessPrice,
    required this.hostConfirmed,
    required this.viewerConfirmed,
  });
}
