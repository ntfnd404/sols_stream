import 'dart:typed_data';

import 'package:signaling/src/data/solana_program/borsh_reader.dart';
import 'package:signaling/src/data/solana_program/program_config_account.dart';
import 'package:signaling/src/data/solana_program/signaling_program_constants.dart';

/// Parses a raw Solana `ProgramConfig` account (Borsh binary) into the wire DTO
/// [ProgramConfigAccount].
///
/// Returns `null` when the account discriminator does not match
/// `ProgramConfig` (e.g. the config PDA is absent or holds a different account),
/// mirroring the web client's `fetchConfig`, which treats a discriminator
/// mismatch as "no config".
///
/// Borsh layout (all little-endian, after the 8-byte discriminator):
/// [32 authority][32 service_wallet]
/// [8 turn_price][8 signal_fee][8 heartbeat_ttl][8 min_heartbeat_interval]
/// [1 bump]
final class ProgramConfigAccountParser {
  const ProgramConfigAccountParser._();

  static ProgramConfigAccount? parse(Uint8List data) {
    const disc = SignalingProgramConstants.discProgramConfigAccount;
    if (data.length < SignalingProgramConstants.discriminatorLength) return null;
    for (var i = 0; i < disc.length; i++) {
      if (data[i] != disc[i]) return null;
    }

    final reader = BorshReader(data, SignalingProgramConstants.discriminatorLength);

    final authority = reader.readFixed(SignalingProgramConstants.pubkeyLength);
    final serviceWallet = reader.readFixed(SignalingProgramConstants.pubkeyLength);
    final turnPrice = reader.readU64();
    final signalFee = reader.readU64();
    final heartbeatTtl = reader.readU64();
    final minHeartbeatInterval = reader.readU64();
    final bump = reader.readU8();

    return ProgramConfigAccount(
      authority: authority,
      serviceWallet: serviceWallet,
      turnPrice: turnPrice,
      signalFee: signalFee,
      heartbeatTtl: heartbeatTtl,
      minHeartbeatInterval: minHeartbeatInterval,
      bump: bump,
    );
  }
}
