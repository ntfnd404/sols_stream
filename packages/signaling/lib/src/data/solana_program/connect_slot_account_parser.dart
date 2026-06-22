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
/// --- Upgrade-07 tail (appended, +26 bytes) ---
/// [8 host_rent_paid][8 viewer_rent_paid][8 access_price]
/// [1 host_confirmed][1 viewer_confirmed]
///
/// Slots written before Upgrade-07 lack the tail; the tail is read only when
/// the full 26 bytes are present, otherwise those fields default to 0/false
/// (matching the web client `fetchConnectSlotFromData`).
final class ConnectSlotAccountParser {
  /// Byte length of the Upgrade-07 tail: three `u64` + two `bool`.
  static const int _upgrade07TailLength = 8 + 8 + 8 + 1 + 1;

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

    // Upgrade-07 tail. Pre-upgrade slots lack it; default to 0/false. Such slots
    // expire within minutes of deploy and settle via the cleanup paths, so this
    // branch only matters during the transition window.
    //
    // Layout-version is inferred from the bytes left after `bump` (deterministic:
    // exactly 0 for a pre-upgrade slot or 26 for an Upgrade-07 slot), not from a
    // version marker — both layouts share the ConnectSlot discriminator. This
    // stays correct only while the contract evolves append-only; a field inserted
    // mid-struct would break the inference. The tail is read all-or-nothing
    // (matching the web client), so a 1..25-byte remainder defaults silently.
    var hostRentPaid = BigInt.zero;
    var viewerRentPaid = BigInt.zero;
    var accessPrice = BigInt.zero;
    var hostConfirmed = false;
    var viewerConfirmed = false;
    if (reader.remaining >= _upgrade07TailLength) {
      hostRentPaid = reader.readU64();
      viewerRentPaid = reader.readU64();
      accessPrice = reader.readU64();
      hostConfirmed = reader.readBool();
      viewerConfirmed = reader.readBool();
    }

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
      hostRentPaid: hostRentPaid,
      viewerRentPaid: viewerRentPaid,
      accessPrice: accessPrice,
      hostConfirmed: hostConfirmed,
      viewerConfirmed: viewerConfirmed,
    );
  }
}
