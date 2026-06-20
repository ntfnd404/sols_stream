import 'dart:typed_data';

import 'package:signaling/src/data/solana_program/borsh_reader.dart';
import 'package:signaling/src/data/solana_program/connect_slot_account.dart';
import 'package:signaling/src/data/solana_program/signaling_program_constants.dart';

/// Parses a raw Solana ConnectSlot account (Borsh binary) into the wire DTO
/// [ConnectSlotAccount]. Stays at the wire boundary — it reads every field
/// faithfully (incl. deposits and reserved protected keys) but does not validate
/// or translate to the domain; that is [ConnectSlotMapper]'s job.
///
/// Borsh layout (all little-endian):
/// [8 disc][32 room][32 host][32 viewer]
/// [8 host_deposit][8 viewer_deposit]
/// [4+N host_protected_key][4+N offer_data]
/// [4+N viewer_protected_key][4+N answer_data]
/// [1 state][8 created_at][8 expires_at][1 bump]
final class ConnectSlotAccountParser {
  const ConnectSlotAccountParser._();

  static ConnectSlotAccount parse(Uint8List data) {
    final reader = BorshReader(data, SignalingProgramConstants.discriminatorLength);

    final room = reader.readFixed(SignalingProgramConstants.pubkeyLength);
    final host = reader.readFixed(SignalingProgramConstants.pubkeyLength);
    final viewer = reader.readFixed(SignalingProgramConstants.pubkeyLength);
    final hostDeposit = reader.readU64();
    final viewerDeposit = reader.readU64();
    final hostProtectedKey = reader.readVec();
    final offerData = reader.readVec();
    final viewerProtectedKey = reader.readVec();
    final answerData = reader.readVec();
    final stateIndex = reader.readU8();
    final createdAt = reader.readI64();
    final expiresAt = reader.readI64();
    final bump = reader.readU8();

    return ConnectSlotAccount(
      room: room,
      host: host,
      viewer: viewer,
      hostDeposit: hostDeposit,
      viewerDeposit: viewerDeposit,
      hostProtectedKey: hostProtectedKey,
      offerData: offerData,
      viewerProtectedKey: viewerProtectedKey,
      answerData: answerData,
      stateIndex: stateIndex,
      createdAt: createdAt,
      expiresAt: expiresAt,
      bump: bump,
    );
  }
}
