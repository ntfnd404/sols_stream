import 'package:signaling/src/data/solana_program/program_config_account.dart';
import 'package:signaling/src/domain/program_config.dart';

/// Anti-Corruption mapper: translates the wire DTO [ProgramConfigAccount] into
/// the domain [ProgramConfig].
///
/// Boundary rule: the domain receives only `serviceWallet` (the skim recipient
/// the reclaim flow must route to). Governance authority, pricing/heartbeat
/// parameters, and the PDA `bump` stay wire-only until a phase needs them.
final class ProgramConfigMapper {
  const ProgramConfigMapper._();

  static ProgramConfig toDomain(ProgramConfigAccount account) =>
      ProgramConfig(serviceWallet: account.serviceWallet);
}
