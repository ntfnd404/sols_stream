import 'package:signaling_solana/src/generated/sols_stream_solana.dart';

/// Subset of the User PDA fields needed before opening a new room.
///
/// Borsh layout (after 8-byte discriminator):
///   [32] authority
///   [4+n] nickname (length-prefixed)
///   [1]  role  - 0=Idle, 1=Host, 2=Viewer
///   [32] room  - current room PDA (zeros if no room)
///   [32] connected_to
///   [8]  last_heartbeat
///   [8]  expires_at
///   [8]  turn_expires_at
///   [4]  stream_count
final class UserAccount {
  final SolsStreamUserRole role;
  final SolsStreamAddress room;
  final BigInt turnExpiresAt;
  final int streamCount;

  bool get isIdle => role is SolsStreamUserRoleIdle;
  bool get isHost => role is SolsStreamUserRoleHost;

  const UserAccount({
    required this.role,
    required this.room,
    required this.turnExpiresAt,
    required this.streamCount,
  });

  bool hasActiveTurnEntitlement({required int nowSeconds}) => turnExpiresAt > BigInt.from(nowSeconds);
}
