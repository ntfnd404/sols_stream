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
  final int createdAt;
  final int expiresAt;

  /// Lamports the host deposited for room + slot. Surfaced for deposit
  /// accounting / reclaim — see `SignalingReclaimGateway`.
  final int hostDeposit;

  /// Lamports the viewer deposited when claiming the slot.
  final int viewerDeposit;

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
  });
}
