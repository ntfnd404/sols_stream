import 'dart:typed_data';

import 'package:signaling/src/data/solana_program/borsh_reader.dart';
import 'package:signaling/src/data/solana_program/signaling_program_constants.dart';
import 'package:signaling/src/domain/connect_slot_data.dart';
import 'package:signaling/src/domain/connect_slot_state.dart';

/// Parses a raw Solana ConnectSlot account (Borsh binary) into [ConnectSlotData].
///
/// Borsh layout (all little-endian):
/// [8 disc][32 room][32 host][32 viewer]
/// [8 host_deposit][8 viewer_deposit]
/// [4+N host_protected_key][4+N offer_data]
/// [4+N viewer_protected_key][4+N answer_data]
/// [1 state][8 created_at][8 expires_at][1 bump]
final class ConnectSlotAccountParser {
  const ConnectSlotAccountParser._();

  static ConnectSlotData parse(Uint8List data) {
    final reader = BorshReader(data, SignalingProgramConstants.discriminatorLength);

    final room = reader.readFixed(SignalingProgramConstants.pubkeyLength);
    final host = reader.readFixed(SignalingProgramConstants.pubkeyLength);
    final viewer = reader.readFixed(SignalingProgramConstants.pubkeyLength);
    reader.skipU64(); // host_deposit
    reader.skipU64(); // viewer_deposit
    final hostProtectedKey = reader.readVec();
    final offerData = reader.readVec();
    final viewerProtectedKey = reader.readVec();
    final answerData = reader.readVec();
    final rawStateIdx = reader.readU8();
    if (rawStateIdx >= ConnectSlotState.values.length) {
      throw FormatException('Unknown ConnectSlotState index: $rawStateIdx');
    }
    final stateIdx = rawStateIdx;
    final createdAt = reader.readI64();
    final expiresAt = reader.readI64();
    final bump = reader.readU8();

    return ConnectSlotData(
      room: room,
      host: host,
      viewer: viewer,
      hostProtectedKey: hostProtectedKey,
      offerData: offerData,
      viewerProtectedKey: viewerProtectedKey,
      answerData: answerData,
      state: ConnectSlotState.values[stateIdx],
      createdAt: createdAt,
      expiresAt: expiresAt,
      bump: bump,
    );
  }
}
