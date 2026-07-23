// GENERATED CODE - DO NOT MODIFY BY HAND.
// tool: solana_idl_codegen
// generator-version: 0.2.0
// source-sha256: e967590f776990a88746c52fff70bb1e412706ceefa537870b711bb1dfe2279d
// semantic-ir-sha256: 06de736cba994a28c486121c3344a50591093167febb525a8227d85946d809fe
// SPDX-License-Identifier: MIT
/// Generated client facades for `sols_stream`.
library;

import 'sols_stream_solana_accounts.dart';
import 'sols_stream_solana_events.dart';
import 'sols_stream_solana_instructions.dart';
import 'sols_stream_solana_support.dart';

/// Instruction construction facade.
final class SolsStreamInstructionsClient {
  /// Creates a stateless instruction facade.
  const SolsStreamInstructionsClient();

  /// Builds `admin_force_close_room` from a prepared request.
  SolsStreamInstruction adminForceCloseRoom(
    SolsStreamAdminForceCloseRoomRequest request,
  ) => request.instruction();

  /// Builds `become_relay` from a prepared request.
  SolsStreamInstruction becomeRelay(SolsStreamBecomeRelayRequest request) =>
      request.instruction();

  /// Builds `claim_connect_slot` from a prepared request.
  SolsStreamInstruction claimConnectSlot(
    SolsStreamClaimConnectSlotRequest request,
  ) => request.instruction();

  /// Builds `cleanup_expired_slot` from a prepared request.
  SolsStreamInstruction cleanupExpiredSlot(
    SolsStreamCleanupExpiredSlotRequest request,
  ) => request.instruction();

  /// Builds `cleanup_expired_slot_third_party` from a prepared request.
  SolsStreamInstruction cleanupExpiredSlotThirdParty(
    SolsStreamCleanupExpiredSlotThirdPartyRequest request,
  ) => request.instruction();

  /// Builds `cleanup_stale_room` from a prepared request.
  SolsStreamInstruction cleanupStaleRoom(
    SolsStreamCleanupStaleRoomRequest request,
  ) => request.instruction();

  /// Builds `cleanup_stale_user` from a prepared request.
  SolsStreamInstruction cleanupStaleUser(
    SolsStreamCleanupStaleUserRequest request,
  ) => request.instruction();

  /// Builds `close_connect_slot` from a prepared request.
  SolsStreamInstruction closeConnectSlot(
    SolsStreamCloseConnectSlotRequest request,
  ) => request.instruction();

  /// Builds `close_room` from a prepared request.
  SolsStreamInstruction closeRoom(SolsStreamCloseRoomRequest request) =>
      request.instruction();

  /// Builds `close_user` from a prepared request.
  SolsStreamInstruction closeUser(SolsStreamCloseUserRequest request) =>
      request.instruction();

  /// Builds `confirm_connection` from a prepared request.
  SolsStreamInstruction confirmConnection(
    SolsStreamConfirmConnectionRequest request,
  ) => request.instruction();

  /// Builds `create_room` from a prepared request.
  SolsStreamInstruction createRoom(SolsStreamCreateRoomRequest request) =>
      request.instruction();

  /// Builds `create_user` from a prepared request.
  SolsStreamInstruction createUser(SolsStreamCreateUserRequest request) =>
      request.instruction();

  /// Builds `end_room` from a prepared request.
  SolsStreamInstruction endRoom(SolsStreamEndRoomRequest request) =>
      request.instruction();

  /// Builds `expire_viewer` from a prepared request.
  SolsStreamInstruction expireViewer(SolsStreamExpireViewerRequest request) =>
      request.instruction();

  /// Builds `heartbeat` from a prepared request.
  SolsStreamInstruction heartbeat(SolsStreamHeartbeatRequest request) =>
      request.instruction();

  /// Builds `initialize` from a prepared request.
  SolsStreamInstruction initialize(SolsStreamInitializeRequest request) =>
      request.instruction();

  /// Builds `join_room` from a prepared request.
  SolsStreamInstruction joinRoom(SolsStreamJoinRoomRequest request) =>
      request.instruction();

  /// Builds `leave_room` from a prepared request.
  SolsStreamInstruction leaveRoom(SolsStreamLeaveRoomRequest request) =>
      request.instruction();

  /// Builds `open_connect_slot` from a prepared request.
  SolsStreamInstruction openConnectSlot(
    SolsStreamOpenConnectSlotRequest request,
  ) => request.instruction();

  /// Builds `open_relay_slot` from a prepared request.
  SolsStreamInstruction openRelaySlot(SolsStreamOpenRelaySlotRequest request) =>
      request.instruction();

  /// Builds `post_memo` from a prepared request.
  SolsStreamInstruction postMemo(SolsStreamPostMemoRequest request) =>
      request.instruction();

  /// Builds `purchase_turn` from a prepared request.
  SolsStreamInstruction purchaseTurn(SolsStreamPurchaseTurnRequest request) =>
      request.instruction();

  /// Builds `update_config` from a prepared request.
  SolsStreamInstruction updateConfig(SolsStreamUpdateConfigRequest request) =>
      request.instruction();

  /// Builds `update_profile` from a prepared request.
  SolsStreamInstruction updateProfile(SolsStreamUpdateProfileRequest request) =>
      request.instruction();

  /// Builds `write_answer` from a prepared request.
  SolsStreamInstruction writeAnswer(SolsStreamWriteAnswerRequest request) =>
      request.instruction();

  /// Builds `write_offer` from a prepared request.
  SolsStreamInstruction writeOffer(SolsStreamWriteOfferRequest request) =>
      request.instruction();
}

/// Typed read-only instruction simulation client.
final class SolsStreamViewClient {
  /// Creates a view client from a simulation capability.
  const SolsStreamViewClient(this.simulator);

  /// Single-instruction simulation capability.
  final SolsStreamTransactionSimulator simulator;
}

/// Optional facade over specialized generated clients.
final class SolsStreamClient {
  /// Creates a facade from only the capabilities an application uses.
  const SolsStreamClient({
    this.instructions = const SolsStreamInstructionsClient(),
    this.accounts,
    this.events,
    this.views,
  });

  /// Instruction construction client.
  final SolsStreamInstructionsClient instructions;

  /// Optional account client.
  final SolsStreamAccountsClient? accounts;

  /// Optional event client.
  final SolsStreamEventsClient? events;

  /// Optional typed view client.
  final SolsStreamViewClient? views;
}
