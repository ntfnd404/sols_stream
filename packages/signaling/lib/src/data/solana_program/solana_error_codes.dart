/// Anchor custom-error code → name map for the sols.stream signaling program,
/// transcribed from `program-client.js` (`SOLS_ERROR_NAMES`). See
/// `SignalingProgramConstants` for source/provenance (same captured client).
///
/// Anchor custom errors start at 6000 and increase by declaration order in the
/// program's `#[error_code]` enum. This map is **defined only** — no decode site
/// is wired this phase (errors still surface generically); the reclaim flow in a
/// later phase consumes [solanaErrorName] to render an error by name instead of a
/// bare code.
abstract final class SolanaErrorCodes {
  /// First Anchor custom-error code.
  static const int firstCode = 6000;

  /// Last currently-defined custom-error code.
  static const int lastCode = 6032;

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
