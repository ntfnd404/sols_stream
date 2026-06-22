import 'package:signaling/src/data/solana_program/connect_slot_account.dart';
import 'package:signaling/src/domain/connect_slot_data.dart';
import 'package:signaling/src/domain/connect_slot_state.dart';

/// Anti-Corruption mapper: translates the wire DTO [ConnectSlotAccount] into the
/// domain [ConnectSlotData].
///
/// This is where the wire format meets the domain. Boundary rule: the domain
/// receives the slot's financial / accounting fields (deposits, rent, access
/// price) and its signaling state (resolved `state`, confirmation flags,
/// offer/answer payloads). It does NOT receive access-control crypto (the
/// protected keys) or PDA mechanics (`bump`); those stay on the wire DTO until
/// access-controlled rooms need them. The raw `stateIndex` is validated and
/// resolved to [ConnectSlotState] here.
final class ConnectSlotMapper {
  const ConnectSlotMapper._();

  static ConnectSlotData toDomain(ConnectSlotAccount account) {
    if (account.stateIndex >= ConnectSlotState.values.length) {
      throw FormatException('Unknown ConnectSlotState index: ${account.stateIndex}');
    }

    return ConnectSlotData(
      room: account.room,
      host: account.host,
      viewer: account.viewer,
      offerData: account.offerData,
      answerData: account.answerData,
      state: ConnectSlotState.values[account.stateIndex],
      createdAt: account.createdAt,
      expiresAt: account.expiresAt,
      hostDeposit: account.hostDeposit,
      viewerDeposit: account.viewerDeposit,
      hostRentPaid: account.hostRentPaid,
      viewerRentPaid: account.viewerRentPaid,
      accessPrice: account.accessPrice,
      hostConfirmed: account.hostConfirmed,
      viewerConfirmed: account.viewerConfirmed,
    );
  }
}
