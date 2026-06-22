import 'package:solana/solana.dart' show JsonRpcException;

/// Anchor custom-error code → name map for the sols.stream signaling program,
/// transcribed from `program-client.js` (`SOLS_ERROR_NAMES`). See
/// `SignalingProgramConstants` for source/provenance (same captured client).
///
/// Anchor custom errors start at 6000 and increase by declaration order in the
/// program's `#[error_code]` enum. The reclaim flow consumes [solanaErrorName]
/// (via [solanaCustomErrorCode]) to render/classify an error by name instead of
/// a bare code.
abstract final class SolanaErrorCodes {
  /// First Anchor custom-error code.
  static const int firstCode = 6000;

  /// Last currently-defined custom-error code.
  static const int lastCode = 6032;

  /// Refund/deposit accounting mismatch on a close path — retryable (the close
  /// can race a concurrent state change). Named for the reclaim retry classifier.
  static const int depositMismatch = 6023;

  /// `end_room` on a room that is already not-live — idempotent success for the
  /// reclaim flow rather than a failure.
  static const int roomAlreadyEnded = 6006;

  /// Custom-error code → Anchor error name (`SOLS_ERROR_NAMES`, codes 6000–6032).
  static const Map<int, String> names = {
    6000: 'NicknameTooLong',
    6001: 'TitleTooLong',
    6002: 'UserNotIdle',
    6003: 'NotInRoom',
    6004: 'NotViewer',
    6005: 'RoomNotLive',
    6006: 'RoomAlreadyEnded',
    6007: 'RoomHasViewers',
    6008: 'RoomMismatch',
    6009: 'NotHost',
    6010: 'NotExpired',
    6011: 'TooFrequent',
    6012: 'DataTooLarge',
    6013: 'Unauthorized',
    6014: 'InvalidSlotState',
    6015: 'SlotExpired',
    6016: 'SlotNotExpired',
    6017: 'ProtectedKeyTooLong',
    6018: 'SdpDataTooLong',
    6019: 'ZeroDeposit',
    6020: 'ZeroExpiry',
    6021: 'NotRelay',
    6022: 'HostStillActive',
    6023: 'DepositMismatch',
    6024: 'InsufficientFunds',
    6025: 'NotStaleEnough',
    6026: 'IsHostOrViewer',
    6027: 'NotConnected',
    6028: 'RentSplitOverflow',
    6029: 'AlreadyConfirmed',
    6030: 'HostingLiveRoom',
    6031: 'RoomStillLive',
    6032: 'SlotConnected',
  };
}

/// Returns the Anchor custom-error name for [code], or `null` if [code] is not a
/// known sols.stream custom error. Pure and total — never throws for any `int`.
String? solanaErrorName(int code) => SolanaErrorCodes.names[code];

/// Extracts the Anchor custom-error code (e.g. `6023` for `DepositMismatch`)
/// from a thrown RPC/transaction [error], or `null` when none is present.
///
/// The `solana` package surfaces program failures as [JsonRpcException] whose
/// `data` is the raw RPC error payload. A failed instruction carries
/// `{"err": {"InstructionError": [<index>, {"Custom": <code>}]}}`; this reads
/// that `Custom` code. Pure, total — never throws for any input.
int? solanaCustomErrorCode(Object error) {
  if (error is! JsonRpcException) return null;

  return _customCode(error.data);
}

int? _customCode(Object? data) {
  if (data is! Map) return null;
  final err = data['err'];
  // `err` is normally a map ({"InstructionError": [...]}), but tolerate the
  // payload arriving with `InstructionError` at the top level.
  final instructionError = err is Map ? err['InstructionError'] : data['InstructionError'];
  if (instructionError is! List || instructionError.length < 2) return null;
  final detail = instructionError[1];
  if (detail is! Map) return null;
  final custom = detail['Custom'];

  return custom is int ? custom : null;
}
