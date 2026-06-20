import 'package:signaling/src/data/solana_program/connect_slot_account.dart';
import 'package:signaling/src/domain/connect_slot_data.dart';
import 'package:signaling/src/domain/connect_slot_state.dart';

/// Anti-Corruption mapper: translates the wire DTO [ConnectSlotAccount] into the
/// domain [ConnectSlotData].
///
/// This is where the wire format meets the domain: the raw `stateIndex` is
/// validated and resolved to [ConnectSlotState], deposits are surfaced, and the
/// reserved protected-key fields + PDA `bump` are intentionally dropped (they
/// stay available on the wire DTO for the day access-controlled rooms need them).
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
    );
  }
}
