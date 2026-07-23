import 'package:signaling/signaling.dart';
import 'package:signaling_solana/src/generated/sols_stream_solana.dart';

/// Anti-Corruption mapper: translates the generated wire DTO into
/// the domain [ProgramConfig].
///
/// Boundary rule: the domain receives `serviceWallet` (skim + TURN recipient),
/// `turnPrice`, and `minHeartbeatInterval` because application flows need those
/// facts. Governance authority, signal fee, heartbeat TTL, and the PDA `bump`
/// stay wire-only until a phase needs them.
final class ProgramConfigMapper {
  const ProgramConfigMapper._();

  static ProgramConfig toDomain(SolsStreamProgramConfig account) => ProgramConfig(
    serviceWallet: account.serviceWallet.bytes,
    turnPriceLamports: account.turnPrice,
    minHeartbeatIntervalSeconds: account.minHeartbeatInterval.toInt(),
  );
}
