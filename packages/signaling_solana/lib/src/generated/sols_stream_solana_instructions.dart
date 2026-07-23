// GENERATED CODE - DO NOT MODIFY BY HAND.
// tool: solana_idl_codegen
// generator-version: 0.2.0
// source-sha256: e967590f776990a88746c52fff70bb1e412706ceefa537870b711bb1dfe2279d
// semantic-ir-sha256: 06de736cba994a28c486121c3344a50591093167febb525a8227d85946d809fe
// SPDX-License-Identifier: MIT
/// Generated instruction API for `sols_stream`.
library;

import 'dart:typed_data';

import 'sols_stream_solana_support.dart';
import 'sols_stream_solana_types.dart';

/// Immutable arguments for `admin_force_close_room`.
final class SolsStreamAdminForceCloseRoomArgs {
  /// Creates empty instruction arguments.
  const SolsStreamAdminForceCloseRoomArgs();

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamAdminForceCloseRoomArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamAdminForceCloseRoomArgs>(
        (reader) => SolsStreamAdminForceCloseRoomArgs(),
        (writer, value) {},
      );
}

/// Fully resolved accounts for `admin_force_close_room`.
final class SolsStreamAdminForceCloseRoomAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamAdminForceCloseRoomAccounts({
    required this.authority,
    required this.config,
    required this.room,
    required this.hostUser,
  });

  /// Resolved account `authority`.
  final SolsStreamAddress authority;

  /// Resolved account `config`.
  final SolsStreamAddress config;

  /// Resolved account `room`.
  final SolsStreamAddress room;

  /// Resolved account `host_user`.
  final SolsStreamAddress hostUser;
}

/// Immutable request for `admin_force_close_room`.
final class SolsStreamAdminForceCloseRoomRequest {
  /// Creates a prepared instruction request.
  SolsStreamAdminForceCloseRoomRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'admin_force_close_room';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    51,
    57,
    192,
    247,
    45,
    239,
    103,
    94,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'authority',
            path: 'authority',
            isSigner: true,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'config',
            path: 'config',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'room',
            path: 'room',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'host_user',
            path: 'host_user',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamAdminForceCloseRoomArgs args;

  /// Fully resolved accounts.
  final SolsStreamAdminForceCloseRoomAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[51, 57, 192, 247, 45, 239, 103, 94]);
    SolsStreamAdminForceCloseRoomArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.authority,
          isSigner: true,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.config,
          isSigner: false,
          isWritable: false,
        ),
        SolsStreamAccountMeta(
          address: accounts.room,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.hostUser,
          isSigner: false,
          isWritable: true,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `become_relay`.
final class SolsStreamBecomeRelayArgs {
  /// Creates empty instruction arguments.
  const SolsStreamBecomeRelayArgs();

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamBecomeRelayArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamBecomeRelayArgs>(
        (reader) => SolsStreamBecomeRelayArgs(),
        (writer, value) {},
      );
}

/// Fully resolved accounts for `become_relay`.
final class SolsStreamBecomeRelayAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamBecomeRelayAccounts({
    required this.viewer,
    required this.viewerUser,
  });

  /// Resolved account `viewer`.
  final SolsStreamAddress viewer;

  /// Resolved account `viewer_user`.
  final SolsStreamAddress viewerUser;
}

/// Immutable request for `become_relay`.
final class SolsStreamBecomeRelayRequest {
  /// Creates a prepared instruction request.
  SolsStreamBecomeRelayRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'become_relay';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    101,
    244,
    32,
    158,
    31,
    72,
    124,
    238,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'viewer',
            path: 'viewer',
            isSigner: true,
            isWritable: false,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'viewer_user',
            path: 'viewer_user',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamBecomeRelayArgs args;

  /// Fully resolved accounts.
  final SolsStreamBecomeRelayAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[101, 244, 32, 158, 31, 72, 124, 238]);
    SolsStreamBecomeRelayArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.viewer,
          isSigner: true,
          isWritable: false,
        ),
        SolsStreamAccountMeta(
          address: accounts.viewerUser,
          isSigner: false,
          isWritable: true,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `claim_connect_slot`.
final class SolsStreamClaimConnectSlotArgs {
  /// Creates instruction arguments.
  SolsStreamClaimConnectSlotArgs({required this.depositLamports});

  /// IDL argument `deposit_lamports`.
  final BigInt depositLamports;

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamClaimConnectSlotArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamClaimConnectSlotArgs>(
        (reader) => SolsStreamClaimConnectSlotArgs(
          depositLamports: reader.field(
            'deposit_lamports',
            () => reader.readUnsigned(8),
          ),
        ),
        (writer, value) {
          writer.writeUnsigned(value.depositLamports, 8);
        },
      );
}

/// Fully resolved accounts for `claim_connect_slot`.
final class SolsStreamClaimConnectSlotAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamClaimConnectSlotAccounts({
    required this.viewer,
    required this.slot,
    required this.room,
    required this.systemProgram,
  });

  /// Resolved account `viewer`.
  final SolsStreamAddress viewer;

  /// Resolved account `slot`.
  final SolsStreamAddress slot;

  /// Resolved account `room`.
  final SolsStreamAddress room;

  /// Resolved account `system_program`.
  final SolsStreamAddress systemProgram;
}

/// Immutable request for `claim_connect_slot`.
final class SolsStreamClaimConnectSlotRequest {
  /// Creates a prepared instruction request.
  SolsStreamClaimConnectSlotRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'claim_connect_slot';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    110,
    60,
    180,
    109,
    39,
    35,
    5,
    140,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'viewer',
            path: 'viewer',
            isSigner: true,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'slot',
            path: 'slot',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'room',
            path: 'room',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'system_program',
            path: 'system_program',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamClaimConnectSlotArgs args;

  /// Fully resolved accounts.
  final SolsStreamClaimConnectSlotAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[110, 60, 180, 109, 39, 35, 5, 140]);
    SolsStreamClaimConnectSlotArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.viewer,
          isSigner: true,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.slot,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.room,
          isSigner: false,
          isWritable: false,
        ),
        SolsStreamAccountMeta(
          address: accounts.systemProgram,
          isSigner: false,
          isWritable: false,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `cleanup_expired_slot`.
final class SolsStreamCleanupExpiredSlotArgs {
  /// Creates empty instruction arguments.
  const SolsStreamCleanupExpiredSlotArgs();

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamCleanupExpiredSlotArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamCleanupExpiredSlotArgs>(
        (reader) => SolsStreamCleanupExpiredSlotArgs(),
        (writer, value) {},
      );
}

/// Fully resolved accounts for `cleanup_expired_slot`.
final class SolsStreamCleanupExpiredSlotAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamCleanupExpiredSlotAccounts({
    required this.caller,
    required this.slot,
    required this.host,
    required this.viewer,
    required this.config,
    required this.serviceWallet,
  });

  /// Resolved account `caller`.
  final SolsStreamAddress caller;

  /// Resolved account `slot`.
  final SolsStreamAddress slot;

  /// Resolved account `host`.
  final SolsStreamAddress host;

  /// Resolved account `viewer`.
  final SolsStreamAddress viewer;

  /// Resolved account `config`.
  final SolsStreamAddress config;

  /// Resolved account `service_wallet`.
  final SolsStreamAddress serviceWallet;
}

/// Immutable request for `cleanup_expired_slot`.
final class SolsStreamCleanupExpiredSlotRequest {
  /// Creates a prepared instruction request.
  SolsStreamCleanupExpiredSlotRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'cleanup_expired_slot';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    47,
    245,
    123,
    125,
    160,
    82,
    36,
    111,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'caller',
            path: 'caller',
            isSigner: true,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'slot',
            path: 'slot',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'host',
            path: 'host',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'viewer',
            path: 'viewer',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'config',
            path: 'config',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'service_wallet',
            path: 'service_wallet',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamCleanupExpiredSlotArgs args;

  /// Fully resolved accounts.
  final SolsStreamCleanupExpiredSlotAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[47, 245, 123, 125, 160, 82, 36, 111]);
    SolsStreamCleanupExpiredSlotArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.caller,
          isSigner: true,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.slot,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.host,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.viewer,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.config,
          isSigner: false,
          isWritable: false,
        ),
        SolsStreamAccountMeta(
          address: accounts.serviceWallet,
          isSigner: false,
          isWritable: true,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `cleanup_expired_slot_third_party`.
final class SolsStreamCleanupExpiredSlotThirdPartyArgs {
  /// Creates empty instruction arguments.
  const SolsStreamCleanupExpiredSlotThirdPartyArgs();

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamCleanupExpiredSlotThirdPartyArgs>
  codec =
      SolsStreamFunctionalBorshCodec<
        SolsStreamCleanupExpiredSlotThirdPartyArgs
      >(
        (reader) => SolsStreamCleanupExpiredSlotThirdPartyArgs(),
        (writer, value) {},
      );
}

/// Fully resolved accounts for `cleanup_expired_slot_third_party`.
final class SolsStreamCleanupExpiredSlotThirdPartyAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamCleanupExpiredSlotThirdPartyAccounts({
    required this.caller,
    required this.slot,
    required this.host,
    required this.viewer,
    required this.config,
    required this.serviceWallet,
  });

  /// Resolved account `caller`.
  final SolsStreamAddress caller;

  /// Resolved account `slot`.
  final SolsStreamAddress slot;

  /// Resolved account `host`.
  final SolsStreamAddress host;

  /// Resolved account `viewer`.
  final SolsStreamAddress viewer;

  /// Resolved account `config`.
  final SolsStreamAddress config;

  /// Resolved account `service_wallet`.
  final SolsStreamAddress serviceWallet;
}

/// Immutable request for `cleanup_expired_slot_third_party`.
final class SolsStreamCleanupExpiredSlotThirdPartyRequest {
  /// Creates a prepared instruction request.
  SolsStreamCleanupExpiredSlotThirdPartyRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'cleanup_expired_slot_third_party';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    17,
    128,
    134,
    184,
    174,
    144,
    182,
    83,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'caller',
            path: 'caller',
            isSigner: true,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'slot',
            path: 'slot',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'host',
            path: 'host',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'viewer',
            path: 'viewer',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'config',
            path: 'config',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'service_wallet',
            path: 'service_wallet',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamCleanupExpiredSlotThirdPartyArgs args;

  /// Fully resolved accounts.
  final SolsStreamCleanupExpiredSlotThirdPartyAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[17, 128, 134, 184, 174, 144, 182, 83]);
    SolsStreamCleanupExpiredSlotThirdPartyArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.caller,
          isSigner: true,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.slot,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.host,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.viewer,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.config,
          isSigner: false,
          isWritable: false,
        ),
        SolsStreamAccountMeta(
          address: accounts.serviceWallet,
          isSigner: false,
          isWritable: true,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `cleanup_stale_room`.
final class SolsStreamCleanupStaleRoomArgs {
  /// Creates empty instruction arguments.
  const SolsStreamCleanupStaleRoomArgs();

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamCleanupStaleRoomArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamCleanupStaleRoomArgs>(
        (reader) => SolsStreamCleanupStaleRoomArgs(),
        (writer, value) {},
      );
}

/// Fully resolved accounts for `cleanup_stale_room`.
final class SolsStreamCleanupStaleRoomAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamCleanupStaleRoomAccounts({
    required this.caller,
    required this.room,
    required this.hostUser,
    required this.hostWallet,
  });

  /// Resolved account `caller`.
  final SolsStreamAddress caller;

  /// Resolved account `room`.
  final SolsStreamAddress room;

  /// Resolved account `host_user`.
  final SolsStreamAddress hostUser;

  /// Resolved account `host_wallet`.
  final SolsStreamAddress hostWallet;
}

/// Immutable request for `cleanup_stale_room`.
final class SolsStreamCleanupStaleRoomRequest {
  /// Creates a prepared instruction request.
  SolsStreamCleanupStaleRoomRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'cleanup_stale_room';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    197,
    165,
    55,
    4,
    228,
    181,
    208,
    64,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'caller',
            path: 'caller',
            isSigner: true,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'room',
            path: 'room',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'host_user',
            path: 'host_user',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'host_wallet',
            path: 'host_wallet',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamCleanupStaleRoomArgs args;

  /// Fully resolved accounts.
  final SolsStreamCleanupStaleRoomAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[197, 165, 55, 4, 228, 181, 208, 64]);
    SolsStreamCleanupStaleRoomArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.caller,
          isSigner: true,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.room,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.hostUser,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.hostWallet,
          isSigner: false,
          isWritable: true,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `cleanup_stale_user`.
final class SolsStreamCleanupStaleUserArgs {
  /// Creates empty instruction arguments.
  const SolsStreamCleanupStaleUserArgs();

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamCleanupStaleUserArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamCleanupStaleUserArgs>(
        (reader) => SolsStreamCleanupStaleUserArgs(),
        (writer, value) {},
      );
}

/// Fully resolved accounts for `cleanup_stale_user`.
final class SolsStreamCleanupStaleUserAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamCleanupStaleUserAccounts({
    required this.caller,
    required this.targetUser,
  });

  /// Resolved account `caller`.
  final SolsStreamAddress caller;

  /// Resolved account `target_user`.
  final SolsStreamAddress targetUser;
}

/// Immutable request for `cleanup_stale_user`.
final class SolsStreamCleanupStaleUserRequest {
  /// Creates a prepared instruction request.
  SolsStreamCleanupStaleUserRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'cleanup_stale_user';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    110,
    83,
    233,
    184,
    208,
    207,
    11,
    177,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'caller',
            path: 'caller',
            isSigner: true,
            isWritable: false,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'target_user',
            path: 'target_user',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamCleanupStaleUserArgs args;

  /// Fully resolved accounts.
  final SolsStreamCleanupStaleUserAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[110, 83, 233, 184, 208, 207, 11, 177]);
    SolsStreamCleanupStaleUserArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.caller,
          isSigner: true,
          isWritable: false,
        ),
        SolsStreamAccountMeta(
          address: accounts.targetUser,
          isSigner: false,
          isWritable: true,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `close_connect_slot`.
final class SolsStreamCloseConnectSlotArgs {
  /// Creates empty instruction arguments.
  const SolsStreamCloseConnectSlotArgs();

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamCloseConnectSlotArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamCloseConnectSlotArgs>(
        (reader) => SolsStreamCloseConnectSlotArgs(),
        (writer, value) {},
      );
}

/// Fully resolved accounts for `close_connect_slot`.
final class SolsStreamCloseConnectSlotAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamCloseConnectSlotAccounts({
    required this.host,
    required this.slot,
    required this.viewer,
    required this.config,
    required this.serviceWallet,
  });

  /// Resolved account `host`.
  final SolsStreamAddress host;

  /// Resolved account `slot`.
  final SolsStreamAddress slot;

  /// Resolved account `viewer`.
  final SolsStreamAddress viewer;

  /// Resolved account `config`.
  final SolsStreamAddress config;

  /// Resolved account `service_wallet`.
  final SolsStreamAddress serviceWallet;
}

/// Immutable request for `close_connect_slot`.
final class SolsStreamCloseConnectSlotRequest {
  /// Creates a prepared instruction request.
  SolsStreamCloseConnectSlotRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'close_connect_slot';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    11,
    246,
    107,
    98,
    155,
    124,
    27,
    192,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'host',
            path: 'host',
            isSigner: true,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'slot',
            path: 'slot',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'viewer',
            path: 'viewer',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'config',
            path: 'config',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'service_wallet',
            path: 'service_wallet',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamCloseConnectSlotArgs args;

  /// Fully resolved accounts.
  final SolsStreamCloseConnectSlotAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[11, 246, 107, 98, 155, 124, 27, 192]);
    SolsStreamCloseConnectSlotArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.host,
          isSigner: true,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.slot,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.viewer,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.config,
          isSigner: false,
          isWritable: false,
        ),
        SolsStreamAccountMeta(
          address: accounts.serviceWallet,
          isSigner: false,
          isWritable: true,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `close_room`.
final class SolsStreamCloseRoomArgs {
  /// Creates empty instruction arguments.
  const SolsStreamCloseRoomArgs();

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamCloseRoomArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamCloseRoomArgs>(
        (reader) => SolsStreamCloseRoomArgs(),
        (writer, value) {},
      );
}

/// Fully resolved accounts for `close_room`.
final class SolsStreamCloseRoomAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamCloseRoomAccounts({
    required this.host,
    required this.hostUser,
    required this.room,
  });

  /// Resolved account `host`.
  final SolsStreamAddress host;

  /// Resolved account `host_user`.
  final SolsStreamAddress hostUser;

  /// Resolved account `room`.
  final SolsStreamAddress room;
}

/// Immutable request for `close_room`.
final class SolsStreamCloseRoomRequest {
  /// Creates a prepared instruction request.
  SolsStreamCloseRoomRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'close_room';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    152,
    197,
    88,
    192,
    98,
    197,
    51,
    211,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'host',
            path: 'host',
            isSigner: true,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'host_user',
            path: 'host_user',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'room',
            path: 'room',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamCloseRoomArgs args;

  /// Fully resolved accounts.
  final SolsStreamCloseRoomAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[152, 197, 88, 192, 98, 197, 51, 211]);
    SolsStreamCloseRoomArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.host,
          isSigner: true,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.hostUser,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.room,
          isSigner: false,
          isWritable: true,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `close_user`.
final class SolsStreamCloseUserArgs {
  /// Creates empty instruction arguments.
  const SolsStreamCloseUserArgs();

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamCloseUserArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamCloseUserArgs>(
        (reader) => SolsStreamCloseUserArgs(),
        (writer, value) {},
      );
}

/// Fully resolved accounts for `close_user`.
final class SolsStreamCloseUserAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamCloseUserAccounts({
    required this.authority,
    required this.user,
  });

  /// Resolved account `authority`.
  final SolsStreamAddress authority;

  /// Resolved account `user`.
  final SolsStreamAddress user;
}

/// Immutable request for `close_user`.
final class SolsStreamCloseUserRequest {
  /// Creates a prepared instruction request.
  SolsStreamCloseUserRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'close_user';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    86,
    219,
    138,
    140,
    236,
    24,
    118,
    200,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'authority',
            path: 'authority',
            isSigner: true,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'user',
            path: 'user',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamCloseUserArgs args;

  /// Fully resolved accounts.
  final SolsStreamCloseUserAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[86, 219, 138, 140, 236, 24, 118, 200]);
    SolsStreamCloseUserArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.authority,
          isSigner: true,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.user,
          isSigner: false,
          isWritable: true,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `confirm_connection`.
final class SolsStreamConfirmConnectionArgs {
  /// Creates empty instruction arguments.
  const SolsStreamConfirmConnectionArgs();

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamConfirmConnectionArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamConfirmConnectionArgs>(
        (reader) => SolsStreamConfirmConnectionArgs(),
        (writer, value) {},
      );
}

/// Fully resolved accounts for `confirm_connection`.
final class SolsStreamConfirmConnectionAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamConfirmConnectionAccounts({
    required this.signer,
    required this.slot,
  });

  /// Resolved account `signer`.
  final SolsStreamAddress signer;

  /// Resolved account `slot`.
  final SolsStreamAddress slot;
}

/// Immutable request for `confirm_connection`.
final class SolsStreamConfirmConnectionRequest {
  /// Creates a prepared instruction request.
  SolsStreamConfirmConnectionRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'confirm_connection';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    219,
    162,
    27,
    145,
    211,
    2,
    134,
    122,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'signer',
            path: 'signer',
            isSigner: true,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'slot',
            path: 'slot',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamConfirmConnectionArgs args;

  /// Fully resolved accounts.
  final SolsStreamConfirmConnectionAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[219, 162, 27, 145, 211, 2, 134, 122]);
    SolsStreamConfirmConnectionArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.signer,
          isSigner: true,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.slot,
          isSigner: false,
          isWritable: true,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `create_room`.
final class SolsStreamCreateRoomArgs {
  /// Creates instruction arguments.
  SolsStreamCreateRoomArgs({
    required this.title,
    required this.category,
    required this.accessMode,
    required this.connectionMode,
    required this.pricePerMinute,
    required this.pricePerSession,
    required this.depositLamports,
    required this.nonce,
  });

  /// IDL argument `title`.
  final String title;

  /// IDL argument `category`.
  final SolsStreamRoomCategory category;

  /// IDL argument `access_mode`.
  final SolsStreamAccessMode accessMode;

  /// IDL argument `connection_mode`.
  final SolsStreamConnectionMode connectionMode;

  /// IDL argument `price_per_minute`.
  final BigInt pricePerMinute;

  /// IDL argument `price_per_session`.
  final BigInt pricePerSession;

  /// IDL argument `deposit_lamports`.
  final BigInt depositLamports;

  /// IDL argument `nonce`.
  final BigInt nonce;

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamCreateRoomArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamCreateRoomArgs>(
        (reader) => SolsStreamCreateRoomArgs(
          title: reader.field('title', () => reader.readString()),
          category: reader.field(
            'category',
            () =>
                reader.nested(() => SolsStreamRoomCategory.codec.read(reader)),
          ),
          accessMode: reader.field(
            'access_mode',
            () => reader.nested(() => SolsStreamAccessMode.codec.read(reader)),
          ),
          connectionMode: reader.field(
            'connection_mode',
            () => reader.nested(
              () => SolsStreamConnectionMode.codec.read(reader),
            ),
          ),
          pricePerMinute: reader.field(
            'price_per_minute',
            () => reader.readUnsigned(8),
          ),
          pricePerSession: reader.field(
            'price_per_session',
            () => reader.readUnsigned(8),
          ),
          depositLamports: reader.field(
            'deposit_lamports',
            () => reader.readUnsigned(8),
          ),
          nonce: reader.field('nonce', () => reader.readUnsigned(8)),
        ),
        (writer, value) {
          writer.writeString(value.title);
          SolsStreamRoomCategory.codec.write(writer, value.category);
          SolsStreamAccessMode.codec.write(writer, value.accessMode);
          SolsStreamConnectionMode.codec.write(writer, value.connectionMode);
          writer.writeUnsigned(value.pricePerMinute, 8);
          writer.writeUnsigned(value.pricePerSession, 8);
          writer.writeUnsigned(value.depositLamports, 8);
          writer.writeUnsigned(value.nonce, 8);
        },
      );
}

/// Fully resolved accounts for `create_room`.
final class SolsStreamCreateRoomAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamCreateRoomAccounts({
    required this.host,
    required this.hostUser,
    required this.room,
    required this.systemProgram,
  });

  /// Resolved account `host`.
  final SolsStreamAddress host;

  /// Resolved account `host_user`.
  final SolsStreamAddress hostUser;

  /// Resolved account `room`.
  final SolsStreamAddress room;

  /// Resolved account `system_program`.
  final SolsStreamAddress systemProgram;
}

/// Immutable request for `create_room`.
final class SolsStreamCreateRoomRequest {
  /// Creates a prepared instruction request.
  SolsStreamCreateRoomRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'create_room';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    130,
    166,
    32,
    2,
    247,
    120,
    178,
    53,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'host',
            path: 'host',
            isSigner: true,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'host_user',
            path: 'host_user',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'room',
            path: 'room',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'system_program',
            path: 'system_program',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamCreateRoomArgs args;

  /// Fully resolved accounts.
  final SolsStreamCreateRoomAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[130, 166, 32, 2, 247, 120, 178, 53]);
    SolsStreamCreateRoomArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.host,
          isSigner: true,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.hostUser,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.room,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.systemProgram,
          isSigner: false,
          isWritable: false,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `create_user`.
final class SolsStreamCreateUserArgs {
  /// Creates instruction arguments.
  SolsStreamCreateUserArgs({required this.nickname});

  /// IDL argument `nickname`.
  final String nickname;

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamCreateUserArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamCreateUserArgs>(
        (reader) => SolsStreamCreateUserArgs(
          nickname: reader.field('nickname', () => reader.readString()),
        ),
        (writer, value) {
          writer.writeString(value.nickname);
        },
      );
}

/// Fully resolved accounts for `create_user`.
final class SolsStreamCreateUserAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamCreateUserAccounts({
    required this.authority,
    required this.user,
    required this.systemProgram,
  });

  /// Resolved account `authority`.
  final SolsStreamAddress authority;

  /// Resolved account `user`.
  final SolsStreamAddress user;

  /// Resolved account `system_program`.
  final SolsStreamAddress systemProgram;
}

/// Immutable request for `create_user`.
final class SolsStreamCreateUserRequest {
  /// Creates a prepared instruction request.
  SolsStreamCreateUserRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'create_user';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    108,
    227,
    130,
    130,
    252,
    109,
    75,
    218,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'authority',
            path: 'authority',
            isSigner: true,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'user',
            path: 'user',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'system_program',
            path: 'system_program',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamCreateUserArgs args;

  /// Fully resolved accounts.
  final SolsStreamCreateUserAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[108, 227, 130, 130, 252, 109, 75, 218]);
    SolsStreamCreateUserArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.authority,
          isSigner: true,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.user,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.systemProgram,
          isSigner: false,
          isWritable: false,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `end_room`.
final class SolsStreamEndRoomArgs {
  /// Creates empty instruction arguments.
  const SolsStreamEndRoomArgs();

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamEndRoomArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamEndRoomArgs>(
        (reader) => SolsStreamEndRoomArgs(),
        (writer, value) {},
      );
}

/// Fully resolved accounts for `end_room`.
final class SolsStreamEndRoomAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamEndRoomAccounts({
    required this.host,
    required this.hostUser,
    required this.room,
  });

  /// Resolved account `host`.
  final SolsStreamAddress host;

  /// Resolved account `host_user`.
  final SolsStreamAddress hostUser;

  /// Resolved account `room`.
  final SolsStreamAddress room;
}

/// Immutable request for `end_room`.
final class SolsStreamEndRoomRequest {
  /// Creates a prepared instruction request.
  SolsStreamEndRoomRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'end_room';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    102,
    106,
    181,
    155,
    61,
    17,
    40,
    78,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'host',
            path: 'host',
            isSigner: true,
            isWritable: false,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'host_user',
            path: 'host_user',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'room',
            path: 'room',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamEndRoomArgs args;

  /// Fully resolved accounts.
  final SolsStreamEndRoomAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[102, 106, 181, 155, 61, 17, 40, 78]);
    SolsStreamEndRoomArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.host,
          isSigner: true,
          isWritable: false,
        ),
        SolsStreamAccountMeta(
          address: accounts.hostUser,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.room,
          isSigner: false,
          isWritable: true,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `expire_viewer`.
final class SolsStreamExpireViewerArgs {
  /// Creates empty instruction arguments.
  const SolsStreamExpireViewerArgs();

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamExpireViewerArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamExpireViewerArgs>(
        (reader) => SolsStreamExpireViewerArgs(),
        (writer, value) {},
      );
}

/// Fully resolved accounts for `expire_viewer`.
final class SolsStreamExpireViewerAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamExpireViewerAccounts({
    required this.caller,
    required this.targetUser,
    required this.room,
  });

  /// Resolved account `caller`.
  final SolsStreamAddress caller;

  /// Resolved account `target_user`.
  final SolsStreamAddress targetUser;

  /// Resolved account `room`.
  final SolsStreamAddress room;
}

/// Immutable request for `expire_viewer`.
final class SolsStreamExpireViewerRequest {
  /// Creates a prepared instruction request.
  SolsStreamExpireViewerRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'expire_viewer';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    188,
    15,
    41,
    159,
    21,
    130,
    243,
    211,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'caller',
            path: 'caller',
            isSigner: true,
            isWritable: false,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'target_user',
            path: 'target_user',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'room',
            path: 'room',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamExpireViewerArgs args;

  /// Fully resolved accounts.
  final SolsStreamExpireViewerAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[188, 15, 41, 159, 21, 130, 243, 211]);
    SolsStreamExpireViewerArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.caller,
          isSigner: true,
          isWritable: false,
        ),
        SolsStreamAccountMeta(
          address: accounts.targetUser,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.room,
          isSigner: false,
          isWritable: true,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `heartbeat`.
final class SolsStreamHeartbeatArgs {
  /// Creates empty instruction arguments.
  const SolsStreamHeartbeatArgs();

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamHeartbeatArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamHeartbeatArgs>(
        (reader) => SolsStreamHeartbeatArgs(),
        (writer, value) {},
      );
}

/// Fully resolved accounts for `heartbeat`.
final class SolsStreamHeartbeatAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamHeartbeatAccounts({
    required this.viewer,
    required this.viewerUser,
    required this.config,
  });

  /// Resolved account `viewer`.
  final SolsStreamAddress viewer;

  /// Resolved account `viewer_user`.
  final SolsStreamAddress viewerUser;

  /// Resolved account `config`.
  final SolsStreamAddress config;
}

/// Immutable request for `heartbeat`.
final class SolsStreamHeartbeatRequest {
  /// Creates a prepared instruction request.
  SolsStreamHeartbeatRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'heartbeat';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    202,
    104,
    56,
    6,
    240,
    170,
    63,
    134,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'viewer',
            path: 'viewer',
            isSigner: true,
            isWritable: false,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'viewer_user',
            path: 'viewer_user',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'config',
            path: 'config',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamHeartbeatArgs args;

  /// Fully resolved accounts.
  final SolsStreamHeartbeatAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[202, 104, 56, 6, 240, 170, 63, 134]);
    SolsStreamHeartbeatArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.viewer,
          isSigner: true,
          isWritable: false,
        ),
        SolsStreamAccountMeta(
          address: accounts.viewerUser,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.config,
          isSigner: false,
          isWritable: false,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `initialize`.
final class SolsStreamInitializeArgs {
  /// Creates instruction arguments.
  SolsStreamInitializeArgs({
    required this.serviceWallet,
    required this.turnPrice,
    required this.signalFee,
    required this.heartbeatTtl,
    required this.minHeartbeatInterval,
  });

  /// IDL argument `service_wallet`.
  final SolsStreamAddress serviceWallet;

  /// IDL argument `turn_price`.
  final BigInt turnPrice;

  /// IDL argument `signal_fee`.
  final BigInt signalFee;

  /// IDL argument `heartbeat_ttl`.
  final BigInt heartbeatTtl;

  /// IDL argument `min_heartbeat_interval`.
  final BigInt minHeartbeatInterval;

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamInitializeArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamInitializeArgs>(
        (reader) => SolsStreamInitializeArgs(
          serviceWallet: reader.field(
            'service_wallet',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          turnPrice: reader.field('turn_price', () => reader.readUnsigned(8)),
          signalFee: reader.field('signal_fee', () => reader.readUnsigned(8)),
          heartbeatTtl: reader.field(
            'heartbeat_ttl',
            () => reader.readUnsigned(8),
          ),
          minHeartbeatInterval: reader.field(
            'min_heartbeat_interval',
            () => reader.readUnsigned(8),
          ),
        ),
        (writer, value) {
          writer.writeBytes(value.serviceWallet.bytes);
          writer.writeUnsigned(value.turnPrice, 8);
          writer.writeUnsigned(value.signalFee, 8);
          writer.writeUnsigned(value.heartbeatTtl, 8);
          writer.writeUnsigned(value.minHeartbeatInterval, 8);
        },
      );
}

/// Fully resolved accounts for `initialize`.
final class SolsStreamInitializeAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamInitializeAccounts({
    required this.authority,
    required this.config,
    required this.systemProgram,
  });

  /// Resolved account `authority`.
  final SolsStreamAddress authority;

  /// Resolved account `config`.
  final SolsStreamAddress config;

  /// Resolved account `system_program`.
  final SolsStreamAddress systemProgram;
}

/// Immutable request for `initialize`.
final class SolsStreamInitializeRequest {
  /// Creates a prepared instruction request.
  SolsStreamInitializeRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'initialize';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    175,
    175,
    109,
    31,
    13,
    152,
    155,
    237,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'authority',
            path: 'authority',
            isSigner: true,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'config',
            path: 'config',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'system_program',
            path: 'system_program',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamInitializeArgs args;

  /// Fully resolved accounts.
  final SolsStreamInitializeAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[175, 175, 109, 31, 13, 152, 155, 237]);
    SolsStreamInitializeArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.authority,
          isSigner: true,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.config,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.systemProgram,
          isSigner: false,
          isWritable: false,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `join_room`.
final class SolsStreamJoinRoomArgs {
  /// Creates empty instruction arguments.
  const SolsStreamJoinRoomArgs();

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamJoinRoomArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamJoinRoomArgs>(
        (reader) => SolsStreamJoinRoomArgs(),
        (writer, value) {},
      );
}

/// Fully resolved accounts for `join_room`.
final class SolsStreamJoinRoomAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamJoinRoomAccounts({
    required this.viewer,
    required this.viewerUser,
    required this.room,
    required this.hostUser,
    required this.config,
  });

  /// Resolved account `viewer`.
  final SolsStreamAddress viewer;

  /// Resolved account `viewer_user`.
  final SolsStreamAddress viewerUser;

  /// Resolved account `room`.
  final SolsStreamAddress room;

  /// Resolved account `host_user`.
  final SolsStreamAddress hostUser;

  /// Resolved account `config`.
  final SolsStreamAddress config;
}

/// Immutable request for `join_room`.
final class SolsStreamJoinRoomRequest {
  /// Creates a prepared instruction request.
  SolsStreamJoinRoomRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'join_room';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    95,
    232,
    188,
    81,
    124,
    130,
    78,
    139,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'viewer',
            path: 'viewer',
            isSigner: true,
            isWritable: false,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'viewer_user',
            path: 'viewer_user',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'room',
            path: 'room',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'host_user',
            path: 'host_user',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'config',
            path: 'config',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamJoinRoomArgs args;

  /// Fully resolved accounts.
  final SolsStreamJoinRoomAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[95, 232, 188, 81, 124, 130, 78, 139]);
    SolsStreamJoinRoomArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.viewer,
          isSigner: true,
          isWritable: false,
        ),
        SolsStreamAccountMeta(
          address: accounts.viewerUser,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.room,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.hostUser,
          isSigner: false,
          isWritable: false,
        ),
        SolsStreamAccountMeta(
          address: accounts.config,
          isSigner: false,
          isWritable: false,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `leave_room`.
final class SolsStreamLeaveRoomArgs {
  /// Creates empty instruction arguments.
  const SolsStreamLeaveRoomArgs();

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamLeaveRoomArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamLeaveRoomArgs>(
        (reader) => SolsStreamLeaveRoomArgs(),
        (writer, value) {},
      );
}

/// Fully resolved accounts for `leave_room`.
final class SolsStreamLeaveRoomAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamLeaveRoomAccounts({
    required this.viewer,
    required this.viewerUser,
    required this.room,
  });

  /// Resolved account `viewer`.
  final SolsStreamAddress viewer;

  /// Resolved account `viewer_user`.
  final SolsStreamAddress viewerUser;

  /// Resolved account `room`.
  final SolsStreamAddress room;
}

/// Immutable request for `leave_room`.
final class SolsStreamLeaveRoomRequest {
  /// Creates a prepared instruction request.
  SolsStreamLeaveRoomRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'leave_room';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    249,
    42,
    239,
    128,
    192,
    20,
    114,
    156,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'viewer',
            path: 'viewer',
            isSigner: true,
            isWritable: false,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'viewer_user',
            path: 'viewer_user',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'room',
            path: 'room',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamLeaveRoomArgs args;

  /// Fully resolved accounts.
  final SolsStreamLeaveRoomAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[249, 42, 239, 128, 192, 20, 114, 156]);
    SolsStreamLeaveRoomArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.viewer,
          isSigner: true,
          isWritable: false,
        ),
        SolsStreamAccountMeta(
          address: accounts.viewerUser,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.room,
          isSigner: false,
          isWritable: true,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `open_connect_slot`.
final class SolsStreamOpenConnectSlotArgs {
  /// Creates instruction arguments.
  SolsStreamOpenConnectSlotArgs({
    required this.slotNonce,
    required this.depositLamports,
    required this.expiresInSeconds,
  });

  /// IDL argument `slot_nonce`.
  final BigInt slotNonce;

  /// IDL argument `deposit_lamports`.
  final BigInt depositLamports;

  /// IDL argument `expires_in_seconds`.
  final BigInt expiresInSeconds;

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamOpenConnectSlotArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamOpenConnectSlotArgs>(
        (reader) => SolsStreamOpenConnectSlotArgs(
          slotNonce: reader.field('slot_nonce', () => reader.readUnsigned(8)),
          depositLamports: reader.field(
            'deposit_lamports',
            () => reader.readUnsigned(8),
          ),
          expiresInSeconds: reader.field(
            'expires_in_seconds',
            () => reader.readUnsigned(8),
          ),
        ),
        (writer, value) {
          writer.writeUnsigned(value.slotNonce, 8);
          writer.writeUnsigned(value.depositLamports, 8);
          writer.writeUnsigned(value.expiresInSeconds, 8);
        },
      );
}

/// Fully resolved accounts for `open_connect_slot`.
final class SolsStreamOpenConnectSlotAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamOpenConnectSlotAccounts({
    required this.host,
    required this.room,
    required this.slot,
    required this.systemProgram,
  });

  /// Resolved account `host`.
  final SolsStreamAddress host;

  /// Resolved account `room`.
  final SolsStreamAddress room;

  /// Resolved account `slot`.
  final SolsStreamAddress slot;

  /// Resolved account `system_program`.
  final SolsStreamAddress systemProgram;
}

/// Immutable request for `open_connect_slot`.
final class SolsStreamOpenConnectSlotRequest {
  /// Creates a prepared instruction request.
  SolsStreamOpenConnectSlotRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'open_connect_slot';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    200,
    199,
    43,
    201,
    133,
    53,
    221,
    183,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'host',
            path: 'host',
            isSigner: true,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'room',
            path: 'room',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'slot',
            path: 'slot',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'system_program',
            path: 'system_program',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamOpenConnectSlotArgs args;

  /// Fully resolved accounts.
  final SolsStreamOpenConnectSlotAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[200, 199, 43, 201, 133, 53, 221, 183]);
    SolsStreamOpenConnectSlotArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.host,
          isSigner: true,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.room,
          isSigner: false,
          isWritable: false,
        ),
        SolsStreamAccountMeta(
          address: accounts.slot,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.systemProgram,
          isSigner: false,
          isWritable: false,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `open_relay_slot`.
final class SolsStreamOpenRelaySlotArgs {
  /// Creates instruction arguments.
  SolsStreamOpenRelaySlotArgs({
    required this.slotNonce,
    required this.depositLamports,
    required this.expiresInSeconds,
  });

  /// IDL argument `slot_nonce`.
  final BigInt slotNonce;

  /// IDL argument `deposit_lamports`.
  final BigInt depositLamports;

  /// IDL argument `expires_in_seconds`.
  final BigInt expiresInSeconds;

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamOpenRelaySlotArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamOpenRelaySlotArgs>(
        (reader) => SolsStreamOpenRelaySlotArgs(
          slotNonce: reader.field('slot_nonce', () => reader.readUnsigned(8)),
          depositLamports: reader.field(
            'deposit_lamports',
            () => reader.readUnsigned(8),
          ),
          expiresInSeconds: reader.field(
            'expires_in_seconds',
            () => reader.readUnsigned(8),
          ),
        ),
        (writer, value) {
          writer.writeUnsigned(value.slotNonce, 8);
          writer.writeUnsigned(value.depositLamports, 8);
          writer.writeUnsigned(value.expiresInSeconds, 8);
        },
      );
}

/// Fully resolved accounts for `open_relay_slot`.
final class SolsStreamOpenRelaySlotAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamOpenRelaySlotAccounts({
    required this.relay,
    required this.relayUser,
    required this.room,
    required this.slot,
    required this.systemProgram,
  });

  /// Resolved account `relay`.
  final SolsStreamAddress relay;

  /// Resolved account `relay_user`.
  final SolsStreamAddress relayUser;

  /// Resolved account `room`.
  final SolsStreamAddress room;

  /// Resolved account `slot`.
  final SolsStreamAddress slot;

  /// Resolved account `system_program`.
  final SolsStreamAddress systemProgram;
}

/// Immutable request for `open_relay_slot`.
final class SolsStreamOpenRelaySlotRequest {
  /// Creates a prepared instruction request.
  SolsStreamOpenRelaySlotRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'open_relay_slot';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    237,
    169,
    69,
    135,
    47,
    97,
    35,
    136,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'relay',
            path: 'relay',
            isSigner: true,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'relay_user',
            path: 'relay_user',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'room',
            path: 'room',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'slot',
            path: 'slot',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'system_program',
            path: 'system_program',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamOpenRelaySlotArgs args;

  /// Fully resolved accounts.
  final SolsStreamOpenRelaySlotAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[237, 169, 69, 135, 47, 97, 35, 136]);
    SolsStreamOpenRelaySlotArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.relay,
          isSigner: true,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.relayUser,
          isSigner: false,
          isWritable: false,
        ),
        SolsStreamAccountMeta(
          address: accounts.room,
          isSigner: false,
          isWritable: false,
        ),
        SolsStreamAccountMeta(
          address: accounts.slot,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.systemProgram,
          isSigner: false,
          isWritable: false,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `post_memo`.
final class SolsStreamPostMemoArgs {
  /// Creates instruction arguments.
  SolsStreamPostMemoArgs({required List<int> data})
    : data = Uint8List.fromList(data).asUnmodifiableView();

  /// IDL argument `data`.
  final Uint8List data;

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamPostMemoArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamPostMemoArgs>(
        (reader) => SolsStreamPostMemoArgs(
          data: reader.field(
            'data',
            () => reader.readBytes(reader.collectionLength()),
          ),
        ),
        (writer, value) {
          writer
            ..writeUnsigned(BigInt.from(value.data.length), 4)
            ..writeBytes(value.data);
        },
      );
}

/// Fully resolved accounts for `post_memo`.
final class SolsStreamPostMemoAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamPostMemoAccounts({
    required this.sender,
    required this.serviceWallet,
    required this.config,
    required this.systemProgram,
  });

  /// Resolved account `sender`.
  final SolsStreamAddress sender;

  /// Resolved account `service_wallet`.
  final SolsStreamAddress serviceWallet;

  /// Resolved account `config`.
  final SolsStreamAddress config;

  /// Resolved account `system_program`.
  final SolsStreamAddress systemProgram;
}

/// Immutable request for `post_memo`.
final class SolsStreamPostMemoRequest {
  /// Creates a prepared instruction request.
  SolsStreamPostMemoRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'post_memo';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    201,
    245,
    220,
    43,
    59,
    13,
    178,
    127,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'sender',
            path: 'sender',
            isSigner: true,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'service_wallet',
            path: 'service_wallet',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'config',
            path: 'config',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'system_program',
            path: 'system_program',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamPostMemoArgs args;

  /// Fully resolved accounts.
  final SolsStreamPostMemoAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[201, 245, 220, 43, 59, 13, 178, 127]);
    SolsStreamPostMemoArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.sender,
          isSigner: true,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.serviceWallet,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.config,
          isSigner: false,
          isWritable: false,
        ),
        SolsStreamAccountMeta(
          address: accounts.systemProgram,
          isSigner: false,
          isWritable: false,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `purchase_turn`.
final class SolsStreamPurchaseTurnArgs {
  /// Creates empty instruction arguments.
  const SolsStreamPurchaseTurnArgs();

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamPurchaseTurnArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamPurchaseTurnArgs>(
        (reader) => SolsStreamPurchaseTurnArgs(),
        (writer, value) {},
      );
}

/// Fully resolved accounts for `purchase_turn`.
final class SolsStreamPurchaseTurnAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamPurchaseTurnAccounts({
    required this.buyer,
    required this.buyerUser,
    required this.serviceWallet,
    required this.config,
    required this.systemProgram,
  });

  /// Resolved account `buyer`.
  final SolsStreamAddress buyer;

  /// Resolved account `buyer_user`.
  final SolsStreamAddress buyerUser;

  /// Resolved account `service_wallet`.
  final SolsStreamAddress serviceWallet;

  /// Resolved account `config`.
  final SolsStreamAddress config;

  /// Resolved account `system_program`.
  final SolsStreamAddress systemProgram;
}

/// Immutable request for `purchase_turn`.
final class SolsStreamPurchaseTurnRequest {
  /// Creates a prepared instruction request.
  SolsStreamPurchaseTurnRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'purchase_turn';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    188,
    235,
    133,
    237,
    250,
    109,
    124,
    52,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'buyer',
            path: 'buyer',
            isSigner: true,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'buyer_user',
            path: 'buyer_user',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'service_wallet',
            path: 'service_wallet',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'config',
            path: 'config',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'system_program',
            path: 'system_program',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamPurchaseTurnArgs args;

  /// Fully resolved accounts.
  final SolsStreamPurchaseTurnAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[188, 235, 133, 237, 250, 109, 124, 52]);
    SolsStreamPurchaseTurnArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.buyer,
          isSigner: true,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.buyerUser,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.serviceWallet,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.config,
          isSigner: false,
          isWritable: false,
        ),
        SolsStreamAccountMeta(
          address: accounts.systemProgram,
          isSigner: false,
          isWritable: false,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `update_config`.
final class SolsStreamUpdateConfigArgs {
  /// Creates instruction arguments.
  SolsStreamUpdateConfigArgs({
    required SolsStreamAddress? serviceWallet,
    required BigInt? turnPrice,
    required BigInt? signalFee,
    required BigInt? heartbeatTtl,
    required BigInt? minHeartbeatInterval,
  }) : serviceWallet = switch (serviceWallet) {
         null => null,
         final value0 => value0,
       },
       turnPrice = switch (turnPrice) {
         null => null,
         final value0 => value0,
       },
       signalFee = switch (signalFee) {
         null => null,
         final value0 => value0,
       },
       heartbeatTtl = switch (heartbeatTtl) {
         null => null,
         final value0 => value0,
       },
       minHeartbeatInterval = switch (minHeartbeatInterval) {
         null => null,
         final value0 => value0,
       };

  /// IDL argument `service_wallet`.
  final SolsStreamAddress? serviceWallet;

  /// IDL argument `turn_price`.
  final BigInt? turnPrice;

  /// IDL argument `signal_fee`.
  final BigInt? signalFee;

  /// IDL argument `heartbeat_ttl`.
  final BigInt? heartbeatTtl;

  /// IDL argument `min_heartbeat_interval`.
  final BigInt? minHeartbeatInterval;

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamUpdateConfigArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamUpdateConfigArgs>(
        (reader) => SolsStreamUpdateConfigArgs(
          serviceWallet: reader.field(
            'service_wallet',
            () => (reader.readOptionTag(1)
                ? reader.nested(
                    () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
                  )
                : null),
          ),
          turnPrice: reader.field(
            'turn_price',
            () => (reader.readOptionTag(1)
                ? reader.nested(() => reader.readUnsigned(8))
                : null),
          ),
          signalFee: reader.field(
            'signal_fee',
            () => (reader.readOptionTag(1)
                ? reader.nested(() => reader.readUnsigned(8))
                : null),
          ),
          heartbeatTtl: reader.field(
            'heartbeat_ttl',
            () => (reader.readOptionTag(1)
                ? reader.nested(() => reader.readUnsigned(8))
                : null),
          ),
          minHeartbeatInterval: reader.field(
            'min_heartbeat_interval',
            () => (reader.readOptionTag(1)
                ? reader.nested(() => reader.readUnsigned(8))
                : null),
          ),
        ),
        (writer, value) {
          switch (value.serviceWallet) {
            case null:
              writer.writeUnsigned(BigInt.zero, 1);
            case final optionValue0:
              writer.writeUnsigned(BigInt.one, 1);
              writer.writeBytes(optionValue0.bytes);
          }
          switch (value.turnPrice) {
            case null:
              writer.writeUnsigned(BigInt.zero, 1);
            case final optionValue0:
              writer.writeUnsigned(BigInt.one, 1);
              writer.writeUnsigned(optionValue0, 8);
          }
          switch (value.signalFee) {
            case null:
              writer.writeUnsigned(BigInt.zero, 1);
            case final optionValue0:
              writer.writeUnsigned(BigInt.one, 1);
              writer.writeUnsigned(optionValue0, 8);
          }
          switch (value.heartbeatTtl) {
            case null:
              writer.writeUnsigned(BigInt.zero, 1);
            case final optionValue0:
              writer.writeUnsigned(BigInt.one, 1);
              writer.writeUnsigned(optionValue0, 8);
          }
          switch (value.minHeartbeatInterval) {
            case null:
              writer.writeUnsigned(BigInt.zero, 1);
            case final optionValue0:
              writer.writeUnsigned(BigInt.one, 1);
              writer.writeUnsigned(optionValue0, 8);
          }
        },
      );
}

/// Fully resolved accounts for `update_config`.
final class SolsStreamUpdateConfigAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamUpdateConfigAccounts({
    required this.authority,
    required this.config,
  });

  /// Resolved account `authority`.
  final SolsStreamAddress authority;

  /// Resolved account `config`.
  final SolsStreamAddress config;
}

/// Immutable request for `update_config`.
final class SolsStreamUpdateConfigRequest {
  /// Creates a prepared instruction request.
  SolsStreamUpdateConfigRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'update_config';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    29,
    158,
    252,
    191,
    10,
    83,
    219,
    99,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'authority',
            path: 'authority',
            isSigner: true,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'config',
            path: 'config',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamUpdateConfigArgs args;

  /// Fully resolved accounts.
  final SolsStreamUpdateConfigAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[29, 158, 252, 191, 10, 83, 219, 99]);
    SolsStreamUpdateConfigArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.authority,
          isSigner: true,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.config,
          isSigner: false,
          isWritable: true,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `update_profile`.
final class SolsStreamUpdateProfileArgs {
  /// Creates instruction arguments.
  SolsStreamUpdateProfileArgs({required this.nickname});

  /// IDL argument `nickname`.
  final String nickname;

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamUpdateProfileArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamUpdateProfileArgs>(
        (reader) => SolsStreamUpdateProfileArgs(
          nickname: reader.field('nickname', () => reader.readString()),
        ),
        (writer, value) {
          writer.writeString(value.nickname);
        },
      );
}

/// Fully resolved accounts for `update_profile`.
final class SolsStreamUpdateProfileAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamUpdateProfileAccounts({
    required this.authority,
    required this.user,
  });

  /// Resolved account `authority`.
  final SolsStreamAddress authority;

  /// Resolved account `user`.
  final SolsStreamAddress user;
}

/// Immutable request for `update_profile`.
final class SolsStreamUpdateProfileRequest {
  /// Creates a prepared instruction request.
  SolsStreamUpdateProfileRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'update_profile';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    98,
    67,
    99,
    206,
    86,
    115,
    175,
    1,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'authority',
            path: 'authority',
            isSigner: true,
            isWritable: false,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'user',
            path: 'user',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamUpdateProfileArgs args;

  /// Fully resolved accounts.
  final SolsStreamUpdateProfileAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[98, 67, 99, 206, 86, 115, 175, 1]);
    SolsStreamUpdateProfileArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.authority,
          isSigner: true,
          isWritable: false,
        ),
        SolsStreamAccountMeta(
          address: accounts.user,
          isSigner: false,
          isWritable: true,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `write_answer`.
final class SolsStreamWriteAnswerArgs {
  /// Creates instruction arguments.
  SolsStreamWriteAnswerArgs({
    required List<int> viewerProtectedKey,
    required List<int> answerData,
    required this.finalize,
  }) : viewerProtectedKey = Uint8List.fromList(viewerProtectedKey)
           .asUnmodifiableView(),
       answerData = Uint8List.fromList(answerData).asUnmodifiableView();

  /// IDL argument `viewer_protected_key`.
  final Uint8List viewerProtectedKey;

  /// IDL argument `answer_data`.
  final Uint8List answerData;

  /// IDL argument `finalize`.
  final bool finalize;

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamWriteAnswerArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamWriteAnswerArgs>(
        (reader) => SolsStreamWriteAnswerArgs(
          viewerProtectedKey: reader.field(
            'viewer_protected_key',
            () => reader.readBytes(reader.collectionLength()),
          ),
          answerData: reader.field(
            'answer_data',
            () => reader.readBytes(reader.collectionLength()),
          ),
          finalize: reader.field('finalize', () => reader.readBool()),
        ),
        (writer, value) {
          writer
            ..writeUnsigned(BigInt.from(value.viewerProtectedKey.length), 4)
            ..writeBytes(value.viewerProtectedKey);
          writer
            ..writeUnsigned(BigInt.from(value.answerData.length), 4)
            ..writeBytes(value.answerData);
          writer.writeBool(value.finalize);
        },
      );
}

/// Fully resolved accounts for `write_answer`.
final class SolsStreamWriteAnswerAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamWriteAnswerAccounts({
    required this.viewer,
    required this.slot,
    required this.systemProgram,
  });

  /// Resolved account `viewer`.
  final SolsStreamAddress viewer;

  /// Resolved account `slot`.
  final SolsStreamAddress slot;

  /// Resolved account `system_program`.
  final SolsStreamAddress systemProgram;
}

/// Immutable request for `write_answer`.
final class SolsStreamWriteAnswerRequest {
  /// Creates a prepared instruction request.
  SolsStreamWriteAnswerRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'write_answer';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    229,
    79,
    107,
    103,
    29,
    50,
    93,
    119,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'viewer',
            path: 'viewer',
            isSigner: true,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'slot',
            path: 'slot',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'system_program',
            path: 'system_program',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamWriteAnswerArgs args;

  /// Fully resolved accounts.
  final SolsStreamWriteAnswerAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[229, 79, 107, 103, 29, 50, 93, 119]);
    SolsStreamWriteAnswerArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.viewer,
          isSigner: true,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.slot,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.systemProgram,
          isSigner: false,
          isWritable: false,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Immutable arguments for `write_offer`.
final class SolsStreamWriteOfferArgs {
  /// Creates instruction arguments.
  SolsStreamWriteOfferArgs({
    required List<int> hostProtectedKey,
    required List<int> offerData,
    required this.finalize,
  }) : hostProtectedKey = Uint8List.fromList(hostProtectedKey)
           .asUnmodifiableView(),
       offerData = Uint8List.fromList(offerData).asUnmodifiableView();

  /// IDL argument `host_protected_key`.
  final Uint8List hostProtectedKey;

  /// IDL argument `offer_data`.
  final Uint8List offerData;

  /// IDL argument `finalize`.
  final bool finalize;

  /// Borsh codec for these arguments.
  static final SolsStreamBorshCodec<SolsStreamWriteOfferArgs> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamWriteOfferArgs>(
        (reader) => SolsStreamWriteOfferArgs(
          hostProtectedKey: reader.field(
            'host_protected_key',
            () => reader.readBytes(reader.collectionLength()),
          ),
          offerData: reader.field(
            'offer_data',
            () => reader.readBytes(reader.collectionLength()),
          ),
          finalize: reader.field('finalize', () => reader.readBool()),
        ),
        (writer, value) {
          writer
            ..writeUnsigned(BigInt.from(value.hostProtectedKey.length), 4)
            ..writeBytes(value.hostProtectedKey);
          writer
            ..writeUnsigned(BigInt.from(value.offerData.length), 4)
            ..writeBytes(value.offerData);
          writer.writeBool(value.finalize);
        },
      );
}

/// Fully resolved accounts for `write_offer`.
final class SolsStreamWriteOfferAccounts {
  /// Creates resolved instruction accounts.
  const SolsStreamWriteOfferAccounts({
    required this.host,
    required this.slot,
    required this.systemProgram,
  });

  /// Resolved account `host`.
  final SolsStreamAddress host;

  /// Resolved account `slot`.
  final SolsStreamAddress slot;

  /// Resolved account `system_program`.
  final SolsStreamAddress systemProgram;
}

/// Immutable request for `write_offer`.
final class SolsStreamWriteOfferRequest {
  /// Creates a prepared instruction request.
  SolsStreamWriteOfferRequest({
    required this.args,
    required this.accounts,
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) : remainingAccounts = List.unmodifiable(remainingAccounts);

  /// IDL instruction name.
  static const String name = 'write_offer';

  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    50,
    36,
    220,
    142,
    101,
    119,
    205,
    194,
  ]);

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only instruction metadata.
  static final SolsStreamInstructionMetadata metadata =
      SolsStreamInstructionMetadata(
        name: name,
        discriminator: discriminator,
        accounts: [
          SolsStreamInstructionAccountMetadata(
            name: 'host',
            path: 'host',
            isSigner: true,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'slot',
            path: 'slot',
            isSigner: false,
            isWritable: true,
            isOptional: false,
          ),
          SolsStreamInstructionAccountMetadata(
            name: 'system_program',
            path: 'system_program',
            isSigner: false,
            isWritable: false,
            isOptional: false,
          ),
        ],
      );

  /// Typed instruction arguments.
  final SolsStreamWriteOfferArgs args;

  /// Fully resolved accounts.
  final SolsStreamWriteOfferAccounts accounts;

  /// Ordered remaining accounts. Duplicates are preserved.
  final List<SolsStreamAccountMeta> remainingAccounts;

  /// Builds the transport-neutral instruction.
  SolsStreamInstruction instruction() {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(<int>[50, 36, 220, 142, 101, 119, 205, 194]);
    SolsStreamWriteOfferArgs.codec.write(writer, args);
    return SolsStreamInstruction(
      programAddress: SolsStreamProgram.programAddress,
      accounts: [
        SolsStreamAccountMeta(
          address: accounts.host,
          isSigner: true,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.slot,
          isSigner: false,
          isWritable: true,
        ),
        SolsStreamAccountMeta(
          address: accounts.systemProgram,
          isSigner: false,
          isWritable: false,
        ),
        ...remainingAccounts,
      ],
      data: writer.takeBytes(),
    );
  }
}

/// Program-level registry of generated instruction metadata.
abstract final class SolsStreamInstructionRegistry {
  /// Instructions declared by the IDL in source order.
  static final List<SolsStreamInstructionMetadata> instructions =
      List.unmodifiable(<SolsStreamInstructionMetadata>[
        SolsStreamAdminForceCloseRoomRequest.metadata,
        SolsStreamBecomeRelayRequest.metadata,
        SolsStreamClaimConnectSlotRequest.metadata,
        SolsStreamCleanupExpiredSlotRequest.metadata,
        SolsStreamCleanupExpiredSlotThirdPartyRequest.metadata,
        SolsStreamCleanupStaleRoomRequest.metadata,
        SolsStreamCleanupStaleUserRequest.metadata,
        SolsStreamCloseConnectSlotRequest.metadata,
        SolsStreamCloseRoomRequest.metadata,
        SolsStreamCloseUserRequest.metadata,
        SolsStreamConfirmConnectionRequest.metadata,
        SolsStreamCreateRoomRequest.metadata,
        SolsStreamCreateUserRequest.metadata,
        SolsStreamEndRoomRequest.metadata,
        SolsStreamExpireViewerRequest.metadata,
        SolsStreamHeartbeatRequest.metadata,
        SolsStreamInitializeRequest.metadata,
        SolsStreamJoinRoomRequest.metadata,
        SolsStreamLeaveRoomRequest.metadata,
        SolsStreamOpenConnectSlotRequest.metadata,
        SolsStreamOpenRelaySlotRequest.metadata,
        SolsStreamPostMemoRequest.metadata,
        SolsStreamPurchaseTurnRequest.metadata,
        SolsStreamUpdateConfigRequest.metadata,
        SolsStreamUpdateProfileRequest.metadata,
        SolsStreamWriteAnswerRequest.metadata,
        SolsStreamWriteOfferRequest.metadata,
      ]);

  /// Instruction metadata indexed by IDL instruction name.
  static final Map<String, SolsStreamInstructionMetadata> byName =
      Map.unmodifiable({
        for (final instruction in instructions) instruction.name: instruction,
      });
}
