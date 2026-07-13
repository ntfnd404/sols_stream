// GENERATED CODE - DO NOT MODIFY BY HAND.
// tool: solana_idl_codegen
// generator-version: 0.2.0
// source-sha256: e967590f776990a88746c52fff70bb1e412706ceefa537870b711bb1dfe2279d
// semantic-ir-sha256: 06de736cba994a28c486121c3344a50591093167febb525a8227d85946d809fe
// SPDX-License-Identifier: MIT
/// Generated program errors for `sols_stream`.
library;

import 'sols_stream_solana_support.dart';

/// Origin reported by Anchor error logs.
sealed class SolsStreamErrorOrigin {
  /// Creates a error origin.
  const SolsStreamErrorOrigin();
}

/// Account-name error origin.
final class SolsStreamAccountErrorOrigin extends SolsStreamErrorOrigin {
  /// Creates Account-name error origin.
  const SolsStreamAccountErrorOrigin(this.name);

  /// IDL account name.
  final String name;
}

/// Program-address error origin.
final class SolsStreamProgramErrorOrigin extends SolsStreamErrorOrigin {
  /// Creates Program-address error origin.
  const SolsStreamProgramErrorOrigin(this.address);

  /// Program address.
  final SolsStreamAddress address;
}

/// Compared values reported by Anchor error logs.
sealed class SolsStreamComparedValues {
  /// Creates a compared values.
  const SolsStreamComparedValues();
}

/// Compared textual values whose wire type is unknown.
final class SolsStreamTextComparedValues extends SolsStreamComparedValues {
  /// Creates Compared textual values whose wire type is unknown.
  const SolsStreamTextComparedValues({required this.left, required this.right});

  /// Left value.
  final String left;

  /// Right value.
  final String right;
}

/// Base typed program exception.
sealed class SolsStreamProgramException implements Exception {
  /// Creates a program exception and copies logs.
  SolsStreamProgramException({
    required this.code,
    required this.idlName,
    required this.idlMessage,
    required this.origin,
    required this.comparedValues,
    required this.signature,
    required this.failure,
    required List<String> rawLogs,
  }) : rawLogs = List.unmodifiable(rawLogs);

  /// Numeric program error code.
  final int code;

  /// Optional IDL error name.
  final String? idlName;

  /// Optional IDL message.
  final String? idlMessage;

  /// Optional typed origin.
  final SolsStreamErrorOrigin? origin;

  /// Optional values compared by the failed constraint.
  final SolsStreamComparedValues? comparedValues;

  /// Ordered raw logs.
  final List<String> rawLogs;

  /// Optional transaction signature.
  final String? signature;

  /// Optional transport-neutral transaction failure.
  final SolsStreamTransactionFailure? failure;
}

/// IDL error `NicknameTooLong` (6000).
final class SolsStreamNicknameTooLongException
    extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamNicknameTooLongException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6000,
         idlName: 'NicknameTooLong',
         idlMessage: 'Nickname exceeds 32 bytes',
       );
}

/// IDL error `TitleTooLong` (6001).
final class SolsStreamTitleTooLongException extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamTitleTooLongException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6001,
         idlName: 'TitleTooLong',
         idlMessage: 'Title exceeds 64 bytes',
       );
}

/// IDL error `UserNotIdle` (6002).
final class SolsStreamUserNotIdleException extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamUserNotIdleException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6002,
         idlName: 'UserNotIdle',
         idlMessage: 'User is not idle',
       );
}

/// IDL error `NotInRoom` (6003).
final class SolsStreamNotInRoomException extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamNotInRoomException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6003,
         idlName: 'NotInRoom',
         idlMessage: 'User is not in a room',
       );
}

/// IDL error `NotViewer` (6004).
final class SolsStreamNotViewerException extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamNotViewerException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6004,
         idlName: 'NotViewer',
         idlMessage: 'User is not a viewer',
       );
}

/// IDL error `RoomNotLive` (6005).
final class SolsStreamRoomNotLiveException extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamRoomNotLiveException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6005,
         idlName: 'RoomNotLive',
         idlMessage: 'Room is not live',
       );
}

/// IDL error `RoomAlreadyEnded` (6006).
final class SolsStreamRoomAlreadyEndedException
    extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamRoomAlreadyEndedException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6006,
         idlName: 'RoomAlreadyEnded',
         idlMessage: 'Room is already ended',
       );
}

/// IDL error `RoomHasViewers` (6007).
final class SolsStreamRoomHasViewersException
    extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamRoomHasViewersException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6007,
         idlName: 'RoomHasViewers',
         idlMessage: 'Room still has viewers',
       );
}

/// IDL error `RoomMismatch` (6008).
final class SolsStreamRoomMismatchException extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamRoomMismatchException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6008,
         idlName: 'RoomMismatch',
         idlMessage: 'User room does not match provided room',
       );
}

/// IDL error `NotHost` (6009).
final class SolsStreamNotHostException extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamNotHostException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(code: 6009, idlName: 'NotHost', idlMessage: 'Not the room host');
}

/// IDL error `NotExpired` (6010).
final class SolsStreamNotExpiredException extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamNotExpiredException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6010,
         idlName: 'NotExpired',
         idlMessage: 'Viewer has not expired yet',
       );
}

/// IDL error `TooFrequent` (6011).
final class SolsStreamTooFrequentException extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamTooFrequentException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6011,
         idlName: 'TooFrequent',
         idlMessage: 'Heartbeat sent too frequently',
       );
}

/// IDL error `DataTooLarge` (6012).
final class SolsStreamDataTooLargeException extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamDataTooLargeException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6012,
         idlName: 'DataTooLarge',
         idlMessage: 'Memo data exceeds 900 bytes',
       );
}

/// IDL error `Unauthorized` (6013).
final class SolsStreamUnauthorizedException extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamUnauthorizedException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(code: 6013, idlName: 'Unauthorized', idlMessage: 'Unauthorized');
}

/// IDL error `InvalidSlotState` (6014).
final class SolsStreamInvalidSlotStateException
    extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamInvalidSlotStateException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6014,
         idlName: 'InvalidSlotState',
         idlMessage: 'Invalid slot state transition',
       );
}

/// IDL error `SlotExpired` (6015).
final class SolsStreamSlotExpiredException extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamSlotExpiredException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6015,
         idlName: 'SlotExpired',
         idlMessage: 'Connect slot has expired',
       );
}

/// IDL error `SlotNotExpired` (6016).
final class SolsStreamSlotNotExpiredException
    extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamSlotNotExpiredException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6016,
         idlName: 'SlotNotExpired',
         idlMessage: 'Connect slot has not expired yet',
       );
}

/// IDL error `ProtectedKeyTooLong` (6017).
final class SolsStreamProtectedKeyTooLongException
    extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamProtectedKeyTooLongException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6017,
         idlName: 'ProtectedKeyTooLong',
         idlMessage: 'Protected key exceeds 256 bytes',
       );
}

/// IDL error `SdpDataTooLong` (6018).
final class SolsStreamSdpDataTooLongException
    extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamSdpDataTooLongException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6018,
         idlName: 'SdpDataTooLong',
         idlMessage: 'Offer/answer data exceeds 10240 bytes',
       );
}

/// IDL error `ZeroDeposit` (6019).
final class SolsStreamZeroDepositException extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamZeroDepositException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6019,
         idlName: 'ZeroDeposit',
         idlMessage: 'Deposit amount must be greater than zero',
       );
}

/// IDL error `ZeroExpiry` (6020).
final class SolsStreamZeroExpiryException extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamZeroExpiryException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6020,
         idlName: 'ZeroExpiry',
         idlMessage: 'Expires-in seconds must be greater than zero',
       );
}

/// IDL error `NotRelay` (6021).
final class SolsStreamNotRelayException extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamNotRelayException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6021,
         idlName: 'NotRelay',
         idlMessage: 'User is not a relay',
       );
}

/// IDL error `HostStillActive` (6022).
final class SolsStreamHostStillActiveException
    extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamHostStillActiveException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6022,
         idlName: 'HostStillActive',
         idlMessage: 'Host is still active — cannot clean up',
       );
}

/// IDL error `DepositMismatch` (6023).
final class SolsStreamDepositMismatchException
    extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamDepositMismatchException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6023,
         idlName: 'DepositMismatch',
         idlMessage: 'Deposit does not match the value stored on the Room',
       );
}

/// IDL error `InsufficientFunds` (6024).
final class SolsStreamInsufficientFundsException
    extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamInsufficientFundsException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6024,
         idlName: 'InsufficientFunds',
         idlMessage:
             'Caller does not have enough lamports to cover the deposit',
       );
}

/// IDL error `NotStaleEnough` (6025).
final class SolsStreamNotStaleEnoughException
    extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamNotStaleEnoughException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6025,
         idlName: 'NotStaleEnough',
         idlMessage: 'Target user is not stale enough to clean up',
       );
}

/// IDL error `IsHostOrViewer` (6026).
final class SolsStreamIsHostOrViewerException
    extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamIsHostOrViewerException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6026,
         idlName: 'IsHostOrViewer',
         idlMessage: 'Caller is the slot host or viewer — use cleanup_expired_slot instead',
       );
}

/// IDL error `NotConnected` (6027).
final class SolsStreamNotConnectedException extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamNotConnectedException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6027,
         idlName: 'NotConnected',
         idlMessage: 'Slot is not in the Connected state',
       );
}

/// IDL error `RentSplitOverflow` (6028).
final class SolsStreamRentSplitOverflowException
    extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamRentSplitOverflowException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6028,
         idlName: 'RentSplitOverflow',
         idlMessage: 'Arithmetic overflow during rent or fee split',
       );
}

/// IDL error `AlreadyConfirmed` (6029).
final class SolsStreamAlreadyConfirmedException
    extends SolsStreamProgramException {
  /// Creates this typed program exception.
  SolsStreamAlreadyConfirmedException({
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(
         code: 6029,
         idlName: 'AlreadyConfirmed',
         idlMessage: 'Connection already confirmed by this party',
       );
}

/// Unknown custom or framework program error.
final class SolsStreamUnknownProgramException
    extends SolsStreamProgramException {
  /// Creates an unknown program exception.
  SolsStreamUnknownProgramException({
    required super.code,
    super.origin,
    super.comparedValues,
    super.rawLogs = const [],
    super.signature,
    super.failure,
  }) : super(idlName: null, idlMessage: null);
}

/// Parses numeric program failures into typed exceptions.
abstract final class SolsStreamProgramErrorParser {
  /// Returns the IDL error name for [code], if known.
  static String? nameForCode(int code) {
    return switch (code) {
      6000 => 'NicknameTooLong',
      6001 => 'TitleTooLong',
      6002 => 'UserNotIdle',
      6003 => 'NotInRoom',
      6004 => 'NotViewer',
      6005 => 'RoomNotLive',
      6006 => 'RoomAlreadyEnded',
      6007 => 'RoomHasViewers',
      6008 => 'RoomMismatch',
      6009 => 'NotHost',
      6010 => 'NotExpired',
      6011 => 'TooFrequent',
      6012 => 'DataTooLarge',
      6013 => 'Unauthorized',
      6014 => 'InvalidSlotState',
      6015 => 'SlotExpired',
      6016 => 'SlotNotExpired',
      6017 => 'ProtectedKeyTooLong',
      6018 => 'SdpDataTooLong',
      6019 => 'ZeroDeposit',
      6020 => 'ZeroExpiry',
      6021 => 'NotRelay',
      6022 => 'HostStillActive',
      6023 => 'DepositMismatch',
      6024 => 'InsufficientFunds',
      6025 => 'NotStaleEnough',
      6026 => 'IsHostOrViewer',
      6027 => 'NotConnected',
      6028 => 'RentSplitOverflow',
      6029 => 'AlreadyConfirmed',
      _ => null,
    };
  }

  /// Returns the IDL error message for [code], if known.
  static String? messageForCode(int code) {
    return switch (code) {
      6000 => 'Nickname exceeds 32 bytes',
      6001 => 'Title exceeds 64 bytes',
      6002 => 'User is not idle',
      6003 => 'User is not in a room',
      6004 => 'User is not a viewer',
      6005 => 'Room is not live',
      6006 => 'Room is already ended',
      6007 => 'Room still has viewers',
      6008 => 'User room does not match provided room',
      6009 => 'Not the room host',
      6010 => 'Viewer has not expired yet',
      6011 => 'Heartbeat sent too frequently',
      6012 => 'Memo data exceeds 900 bytes',
      6013 => 'Unauthorized',
      6014 => 'Invalid slot state transition',
      6015 => 'Connect slot has expired',
      6016 => 'Connect slot has not expired yet',
      6017 => 'Protected key exceeds 256 bytes',
      6018 => 'Offer/answer data exceeds 10240 bytes',
      6019 => 'Deposit amount must be greater than zero',
      6020 => 'Expires-in seconds must be greater than zero',
      6021 => 'User is not a relay',
      6022 => 'Host is still active — cannot clean up',
      6023 => 'Deposit does not match the value stored on the Room',
      6024 => 'Caller does not have enough lamports to cover the deposit',
      6025 => 'Target user is not stale enough to clean up',
      6026 =>
        'Caller is the slot host or viewer — use cleanup_expired_slot instead',
      6027 => 'Slot is not in the Connected state',
      6028 => 'Arithmetic overflow during rent or fee split',
      6029 => 'Connection already confirmed by this party',
      _ => null,
    };
  }

  /// Returns the numeric code for [name], if known.
  static int? codeForName(String name) {
    return switch (name) {
      'NicknameTooLong' => 6000,
      'TitleTooLong' => 6001,
      'UserNotIdle' => 6002,
      'NotInRoom' => 6003,
      'NotViewer' => 6004,
      'RoomNotLive' => 6005,
      'RoomAlreadyEnded' => 6006,
      'RoomHasViewers' => 6007,
      'RoomMismatch' => 6008,
      'NotHost' => 6009,
      'NotExpired' => 6010,
      'TooFrequent' => 6011,
      'DataTooLarge' => 6012,
      'Unauthorized' => 6013,
      'InvalidSlotState' => 6014,
      'SlotExpired' => 6015,
      'SlotNotExpired' => 6016,
      'ProtectedKeyTooLong' => 6017,
      'SdpDataTooLong' => 6018,
      'ZeroDeposit' => 6019,
      'ZeroExpiry' => 6020,
      'NotRelay' => 6021,
      'HostStillActive' => 6022,
      'DepositMismatch' => 6023,
      'InsufficientFunds' => 6024,
      'NotStaleEnough' => 6025,
      'IsHostOrViewer' => 6026,
      'NotConnected' => 6027,
      'RentSplitOverflow' => 6028,
      'AlreadyConfirmed' => 6029,
      _ => null,
    };
  }

  /// Whether [code] is declared by this IDL.
  static bool isKnownCode(int code) => nameForCode(code) != null;

  /// Creates a typed error for [code].
  static SolsStreamProgramException fromCode(
    int code, {
    SolsStreamErrorOrigin? origin,
    SolsStreamComparedValues? comparedValues,
    List<String> logs = const [],
    String? signature,
    SolsStreamTransactionFailure? failure,
  }) {
    return switch (code) {
      6000 => SolsStreamNicknameTooLongException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6001 => SolsStreamTitleTooLongException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6002 => SolsStreamUserNotIdleException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6003 => SolsStreamNotInRoomException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6004 => SolsStreamNotViewerException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6005 => SolsStreamRoomNotLiveException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6006 => SolsStreamRoomAlreadyEndedException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6007 => SolsStreamRoomHasViewersException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6008 => SolsStreamRoomMismatchException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6009 => SolsStreamNotHostException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6010 => SolsStreamNotExpiredException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6011 => SolsStreamTooFrequentException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6012 => SolsStreamDataTooLargeException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6013 => SolsStreamUnauthorizedException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6014 => SolsStreamInvalidSlotStateException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6015 => SolsStreamSlotExpiredException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6016 => SolsStreamSlotNotExpiredException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6017 => SolsStreamProtectedKeyTooLongException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6018 => SolsStreamSdpDataTooLongException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6019 => SolsStreamZeroDepositException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6020 => SolsStreamZeroExpiryException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6021 => SolsStreamNotRelayException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6022 => SolsStreamHostStillActiveException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6023 => SolsStreamDepositMismatchException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6024 => SolsStreamInsufficientFundsException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6025 => SolsStreamNotStaleEnoughException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6026 => SolsStreamIsHostOrViewerException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6027 => SolsStreamNotConnectedException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6028 => SolsStreamRentSplitOverflowException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      6029 => SolsStreamAlreadyConfirmedException(
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
      _ => SolsStreamUnknownProgramException(
        code: code,
        origin: origin,
        comparedValues: comparedValues,
        rawLogs: logs,
        signature: signature,
        failure: failure,
      ),
    };
  }

  /// Parses a numeric code from Anchor or custom-program logs.
  static SolsStreamProgramException? parseLogs(
    List<String> logs, {
    String? signature,
    SolsStreamTransactionFailure? failure,
  }) {
    int? code;
    SolsStreamErrorOrigin? origin;
    String? left;
    String? right;
    for (var index = 0; index < logs.length; index++) {
      final line = logs[index];
      final anchor = RegExp(r'Error Number: ([0-9]+)').firstMatch(line);
      if (anchor != null) {
        code = int.parse(anchor.group(1)!);
      }
      final custom = RegExp(r'custom program error: 0x([0-9a-fA-F]+)')
          .firstMatch(line);
      if (custom != null) {
        code = int.parse(custom.group(1)!, radix: 16);
      }
      final account = RegExp(
        r'AnchorError caused by account: ([A-Za-z_][A-Za-z0-9_]*)',
      ).firstMatch(line);
      if (account != null) {
        origin = SolsStreamAccountErrorOrigin(account.group(1)!);
      }
      final program = RegExp(
        r'AnchorError caused by program: ([1-9A-HJ-NP-Za-km-z]+)',
      ).firstMatch(line);
      if (program != null) {
        try {
          origin = SolsStreamProgramErrorOrigin(
            SolsStreamAddress.fromBase58(program.group(1)!),
          );
        } on FormatException {
          origin = null;
        } on ArgumentError {
          origin = null;
        }
      }
      if (line.endsWith('Left:') && index + 1 < logs.length) {
        left = logs[index + 1].replaceFirst('Program log: ', '');
      }
      if (line.endsWith('Right:') && index + 1 < logs.length) {
        right = logs[index + 1].replaceFirst('Program log: ', '');
      }
    }
    final compared = left == null || right == null
        ? null
        : SolsStreamTextComparedValues(left: left, right: right);
    return code == null
        ? null
        : fromCode(
            code,
            origin: origin,
            comparedValues: compared,
            logs: logs,
            signature: signature,
            failure: failure,
          );
  }
}
