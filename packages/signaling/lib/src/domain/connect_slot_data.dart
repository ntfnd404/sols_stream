import 'dart:typed_data';

import 'package:signaling/src/domain/connect_slot_state.dart';

/// Value Object representing the current state of a Solana ConnectSlot account.
///
/// Parsing from raw binary is handled by [ConnectSlotAccountParser]
/// in the data layer — this class knows nothing about Borsh or byte offsets.
class ConnectSlotData {
  final Uint8List room;
  final Uint8List host;
  final Uint8List viewer;
  final Uint8List hostProtectedKey;
  final Uint8List offerData;
  final Uint8List viewerProtectedKey;
  final Uint8List answerData;
  final ConnectSlotState state;
  final int createdAt;
  final int expiresAt;
  final int bump;

  const ConnectSlotData({
    required this.room,
    required this.host,
    required this.viewer,
    required this.hostProtectedKey,
    required this.offerData,
    required this.viewerProtectedKey,
    required this.answerData,
    required this.state,
    required this.createdAt,
    required this.expiresAt,
    required this.bump,
  });
}
