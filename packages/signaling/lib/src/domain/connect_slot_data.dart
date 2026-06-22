import 'dart:typed_data';

import 'package:signaling/src/domain/connect_slot_state.dart';

/// Domain Value Object for a Solana ConnectSlot, holding only what the signaling
/// domain reasons about today.
///
/// Translated from the wire DTO `ConnectSlotAccount` by `ConnectSlotMapper` in
/// the data layer — this class knows nothing about Borsh, byte offsets, the PDA
/// `bump`, or the reserved on-chain protected-key fields. Those stay in the wire
/// DTO and are mapped through only when access-controlled rooms land
/// (monetization roadmap — see `docs/project/vision.md`).
class ConnectSlotData {
  final Uint8List room;
  final Uint8List host;
  final Uint8List viewer;
  final Uint8List offerData;
  final Uint8List answerData;
  final ConnectSlotState state;
  final BigInt createdAt;
  final BigInt expiresAt;

  /// Lamports the host deposited for room + slot. Surfaced for deposit
  /// accounting / reclaim — see `SignalingReclaimGateway`.
  final BigInt hostDeposit;

  /// Lamports the viewer deposited when claiming the slot.
  final BigInt viewerDeposit;

  /// Account-rent lamports the host paid. On close/cleanup this is returned as
  /// part of a pro-rata distribution over deposits + rent + access price, after
  /// a 1% skim to the service wallet. Surfaced for reclaim accounting. 0 for
  /// pre-Upgrade-07 slots.
  final BigInt hostRentPaid;

  /// Account-rent lamports the viewer paid; see [hostRentPaid].
  final BigInt viewerRentPaid;

  /// Access price (lamports) snapshotted at claim time; 0 for the free P2P flow.
  /// Surfaced because it is an input to the same close/cleanup refund math as
  /// [hostDeposit] and [hostRentPaid].
  final BigInt accessPrice;

  /// Whether the host has confirmed the WebRTC connection on-chain. 0/false for
  /// pre-Upgrade-07 slots.
  final bool hostConfirmed;

  /// Whether the viewer has confirmed the WebRTC connection on-chain; see
  /// [hostConfirmed].
  final bool viewerConfirmed;

  const ConnectSlotData({
    required this.room,
    required this.host,
    required this.viewer,
    required this.offerData,
    required this.answerData,
    required this.state,
    required this.createdAt,
    required this.expiresAt,
    required this.hostDeposit,
    required this.viewerDeposit,
    required this.hostRentPaid,
    required this.viewerRentPaid,
    required this.accessPrice,
    required this.hostConfirmed,
    required this.viewerConfirmed,
  });
}
