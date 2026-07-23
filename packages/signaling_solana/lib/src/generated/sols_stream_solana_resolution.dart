// GENERATED CODE - DO NOT MODIFY BY HAND.
// tool: solana_idl_codegen
// generator-version: 0.2.0
// source-sha256: e967590f776990a88746c52fff70bb1e412706ceefa537870b711bb1dfe2279d
// semantic-ir-sha256: 06de736cba994a28c486121c3344a50591093167febb525a8227d85946d809fe
// SPDX-License-Identifier: MIT
/// Generated account resolution API for `sols_stream`.
library;

import 'dart:typed_data';

import 'sols_stream_solana_accounts.dart';
import 'sols_stream_solana_instructions.dart';
import 'sols_stream_solana_support.dart';
import 'sols_stream_solana_types.dart';

/// Tri-state override for one instruction account.
sealed class SolsStreamAccountOverride {
  /// Creates an override state.
  const SolsStreamAccountOverride();

  /// Uses IDL-driven resolution.
  const factory SolsStreamAccountOverride.inherit() =
      SolsStreamInheritAccountOverride;

  /// Uses an explicit address.
  const factory SolsStreamAccountOverride.use(SolsStreamAddress address) =
      SolsStreamUseAccountOverride;

  /// Omits an IDL-optional account using the program sentinel.
  const factory SolsStreamAccountOverride.absent() =
      SolsStreamAbsentAccountOverride;
}

/// IDL-driven resolution without an explicit override.
final class SolsStreamInheritAccountOverride extends SolsStreamAccountOverride {
  /// Creates the inherit state.
  const SolsStreamInheritAccountOverride();
}

/// Explicit account address override.
final class SolsStreamUseAccountOverride extends SolsStreamAccountOverride {
  /// Creates an explicit address state.
  const SolsStreamUseAccountOverride(this.address);

  /// Explicit address.
  final SolsStreamAddress address;
}

/// Explicit absence for an IDL-optional account.
final class SolsStreamAbsentAccountOverride extends SolsStreamAccountOverride {
  /// Creates the absent state.
  const SolsStreamAbsentAccountOverride();
}

/// Dependencies supplied to generated account resolvers.
/// Relation/PDA cycles are runtime-resolvable when these dependencies break the cycle.
final class SolsStreamResolutionContext {
  /// Creates a resolution context.
  SolsStreamResolutionContext({
    this.identity,
    Set<String> identityAccountPaths = const {},
    this.accountReader,
    this.externalAccountSeedResolver,
    this.relationResolver,
    this.pdaDeriver,
    this.readOptions = const SolsStreamAccountReadOptions(),
    this.decodeLimits = SolsStreamDecodeLimits.defaults,
  }) : identityAccountPaths = Set.unmodifiable(identityAccountPaths);

  /// Optional application identity.
  final SolsStreamAddress? identity;

  /// Account paths allowed to use [identity].
  final Set<String> identityAccountPaths;

  /// Optional account reader used by relation and account-data seeds.
  final SolsStreamAccountReader? accountReader;

  /// Optional decoder for application-owned external account seeds.
  final SolsStreamExternalAccountSeedResolver? externalAccountSeedResolver;

  /// Optional application relation resolver.
  final SolsStreamRelationResolver? relationResolver;

  /// Optional canonical PDA deriver.
  final SolsStreamPdaDeriver? pdaDeriver;

  /// Account read policy.
  final SolsStreamAccountReadOptions readOptions;

  /// Decode limits.
  final SolsStreamDecodeLimits decodeLimits;
}

/// One deterministic account-resolution failure.
final class SolsStreamAccountResolutionCause {
  /// Creates a cause.
  const SolsStreamAccountResolutionCause({
    required this.path,
    required this.code,
    required this.message,
  });

  /// Account path.
  final String path;

  /// Stable failure code.
  final String code;

  /// Human-readable explanation.
  final String message;
}

/// Aggregate account-resolution exception.
final class SolsStreamAccountResolutionException implements Exception {
  /// Creates an exception and copies ordered causes.
  SolsStreamAccountResolutionException(
    List<SolsStreamAccountResolutionCause> causes,
  ) : causes = List.unmodifiable(causes);

  /// Ordered unresolved accounts and reasons.
  final List<SolsStreamAccountResolutionCause> causes;

  @override
  String toString() =>
      'SolsStreamAccountResolutionException: ${causes.length} unresolved account(s)';
}

/// Typed account overrides for `admin_force_close_room`.
final class SolsStreamAdminForceCloseRoomAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamAdminForceCloseRoomAccountOverrides({
    this.authority = const SolsStreamAccountOverride.inherit(),
    this.config = const SolsStreamAccountOverride.inherit(),
    this.room = const SolsStreamAccountOverride.inherit(),
    this.hostUser = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `authority`.
  final SolsStreamAccountOverride authority;

  /// Override for `config`.
  final SolsStreamAccountOverride config;

  /// Override for `room`.
  final SolsStreamAccountOverride room;

  /// Override for `host_user`.
  final SolsStreamAccountOverride hostUser;
}

/// Asynchronous resolver for `admin_force_close_room` accounts.
final class SolsStreamAdminForceCloseRoomAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamAdminForceCloseRoomAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamAdminForceCloseRoomAccounts> resolve({
    required SolsStreamAdminForceCloseRoomArgs args,
    SolsStreamAdminForceCloseRoomAccountOverrides overrides =
        const SolsStreamAdminForceCloseRoomAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? authority;
    var authoritySuppressed = false;
    switch (overrides.authority) {
      case SolsStreamUseAccountOverride(:final address):
        authority = address;
        authoritySuppressed = false;
      case SolsStreamAbsentAccountOverride():
        authoritySuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'authority',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        authoritySuppressed = false;
        if (context.identityAccountPaths.contains('authority') &&
            context.identity != null) {
          authority = context.identity;
        }
    }
    SolsStreamAddress? config;
    var configSuppressed = false;
    switch (overrides.config) {
      case SolsStreamUseAccountOverride(:final address):
        config = address;
        configSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        configSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'config',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        configSuppressed = false;
        if (context.identityAccountPaths.contains('config') &&
            context.identity != null) {
          config = context.identity;
        }
    }
    SolsStreamAddress? room;
    var roomSuppressed = false;
    switch (overrides.room) {
      case SolsStreamUseAccountOverride(:final address):
        room = address;
        roomSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        roomSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'room',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        roomSuppressed = false;
        if (context.identityAccountPaths.contains('room') &&
            context.identity != null) {
          room = context.identity;
        }
    }
    SolsStreamAddress? hostUser;
    var hostUserSuppressed = false;
    switch (overrides.hostUser) {
      case SolsStreamUseAccountOverride(:final address):
        hostUser = address;
        hostUserSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        hostUserSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'host_user',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        hostUserSuppressed = false;
        if (context.identityAccountPaths.contains('host_user') &&
            context.identity != null) {
          hostUser = context.identity;
        }
    }
    for (var pass = 0; pass < 4; pass++) {
      var progressed = false;
      if (authority == null && !authoritySuppressed) {
        final relationResolver = context.relationResolver;
        if (relationResolver != null) {
          if (authority == null) {
            final authorityRelation0 = await relationResolver.resolveRelation(
              accountPath: 'authority',
              relationPath: 'config',
              resolvedAccounts: {
                if (authority != null) 'authority': authority,
                if (config != null) 'config': config,
                if (room != null) 'room': room,
                if (hostUser != null) 'host_user': hostUser,
              },
            );
            if (authorityRelation0 != null) {
              authority = authorityRelation0;
              progressed = true;
            }
          }
        }
      }
      if (config == null && !configSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          final seeds = <Uint8List>[];
          seeds.add(Uint8List.fromList(<int>[99, 111, 110, 102, 105, 103]));
          for (var index = 0; index < seeds.length; index++) {
            if (seeds[index].length > 32) {
              throw SolsStreamPdaException(
                code: 'PDA_SEED_LENGTH',
                message: 'A PDA seed cannot exceed 32 bytes.',
                seedIndex: index,
              );
            }
          }
          final derived = await deriver.derive(
            programAddress: SolsStreamProgram.programAddress,
            seeds: seeds,
          );
          config = derived.address;
          progressed = true;
        }
      }
      if (authority != null ||
          authoritySuppressed && config != null ||
          configSuppressed) {
        break;
      }
      if (!progressed) {
        break;
      }
    }
    if (authority == null && !authoritySuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'authority',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (config == null && !configSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'config',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (room == null && !roomSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'room',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (hostUser == null && !hostUserSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'host_user',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamAdminForceCloseRoomAccounts(
      authority: authority!,
      config: config!,
      room: room!,
      hostUser: hostUser!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamAdminForceCloseRoomRequest> prepare({
    required SolsStreamAdminForceCloseRoomArgs args,
    SolsStreamAdminForceCloseRoomAccountOverrides overrides =
        const SolsStreamAdminForceCloseRoomAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamAdminForceCloseRoomRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `become_relay`.
final class SolsStreamBecomeRelayAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamBecomeRelayAccountOverrides({
    this.viewer = const SolsStreamAccountOverride.inherit(),
    this.viewerUser = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `viewer`.
  final SolsStreamAccountOverride viewer;

  /// Override for `viewer_user`.
  final SolsStreamAccountOverride viewerUser;
}

/// Asynchronous resolver for `become_relay` accounts.
final class SolsStreamBecomeRelayAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamBecomeRelayAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamBecomeRelayAccounts> resolve({
    required SolsStreamBecomeRelayArgs args,
    SolsStreamBecomeRelayAccountOverrides overrides =
        const SolsStreamBecomeRelayAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? viewer;
    var viewerSuppressed = false;
    switch (overrides.viewer) {
      case SolsStreamUseAccountOverride(:final address):
        viewer = address;
        viewerSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        viewerSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'viewer',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        viewerSuppressed = false;
        if (context.identityAccountPaths.contains('viewer') &&
            context.identity != null) {
          viewer = context.identity;
        }
    }
    SolsStreamAddress? viewerUser;
    var viewerUserSuppressed = false;
    switch (overrides.viewerUser) {
      case SolsStreamUseAccountOverride(:final address):
        viewerUser = address;
        viewerUserSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        viewerUserSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'viewer_user',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        viewerUserSuppressed = false;
        if (context.identityAccountPaths.contains('viewer_user') &&
            context.identity != null) {
          viewerUser = context.identity;
        }
    }
    for (var pass = 0; pass < 2; pass++) {
      var progressed = false;
      if (viewerUser == null && !viewerUserSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          if (viewer != null) {
            final seeds = <Uint8List>[];
            seeds.add(Uint8List.fromList(<int>[117, 115, 101, 114]));
            seeds.add(viewer.bytes);
            for (var index = 0; index < seeds.length; index++) {
              if (seeds[index].length > 32) {
                throw SolsStreamPdaException(
                  code: 'PDA_SEED_LENGTH',
                  message: 'A PDA seed cannot exceed 32 bytes.',
                  seedIndex: index,
                );
              }
            }
            final derived = await deriver.derive(
              programAddress: SolsStreamProgram.programAddress,
              seeds: seeds,
            );
            viewerUser = derived.address;
            progressed = true;
          }
        }
      }
      if (viewerUser != null || viewerUserSuppressed) {
        break;
      }
      if (!progressed) {
        break;
      }
    }
    if (viewer == null && !viewerSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'viewer',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (viewerUser == null && !viewerUserSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'viewer_user',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamBecomeRelayAccounts(
      viewer: viewer!,
      viewerUser: viewerUser!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamBecomeRelayRequest> prepare({
    required SolsStreamBecomeRelayArgs args,
    SolsStreamBecomeRelayAccountOverrides overrides =
        const SolsStreamBecomeRelayAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamBecomeRelayRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `claim_connect_slot`.
final class SolsStreamClaimConnectSlotAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamClaimConnectSlotAccountOverrides({
    this.viewer = const SolsStreamAccountOverride.inherit(),
    this.slot = const SolsStreamAccountOverride.inherit(),
    this.room = const SolsStreamAccountOverride.inherit(),
    this.systemProgram = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `viewer`.
  final SolsStreamAccountOverride viewer;

  /// Override for `slot`.
  final SolsStreamAccountOverride slot;

  /// Override for `room`.
  final SolsStreamAccountOverride room;

  /// Override for `system_program`.
  final SolsStreamAccountOverride systemProgram;
}

/// Asynchronous resolver for `claim_connect_slot` accounts.
final class SolsStreamClaimConnectSlotAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamClaimConnectSlotAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamClaimConnectSlotAccounts> resolve({
    required SolsStreamClaimConnectSlotArgs args,
    SolsStreamClaimConnectSlotAccountOverrides overrides =
        const SolsStreamClaimConnectSlotAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? viewer;
    var viewerSuppressed = false;
    switch (overrides.viewer) {
      case SolsStreamUseAccountOverride(:final address):
        viewer = address;
        viewerSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        viewerSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'viewer',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        viewerSuppressed = false;
        if (context.identityAccountPaths.contains('viewer') &&
            context.identity != null) {
          viewer = context.identity;
        }
    }
    SolsStreamAddress? slot;
    var slotSuppressed = false;
    switch (overrides.slot) {
      case SolsStreamUseAccountOverride(:final address):
        slot = address;
        slotSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        slotSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'slot',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        slotSuppressed = false;
        if (context.identityAccountPaths.contains('slot') &&
            context.identity != null) {
          slot = context.identity;
        }
    }
    SolsStreamAddress? room;
    var roomSuppressed = false;
    switch (overrides.room) {
      case SolsStreamUseAccountOverride(:final address):
        room = address;
        roomSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        roomSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'room',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        roomSuppressed = false;
        if (context.identityAccountPaths.contains('room') &&
            context.identity != null) {
          room = context.identity;
        }
    }
    SolsStreamAddress? systemProgram;
    var systemProgramSuppressed = false;
    switch (overrides.systemProgram) {
      case SolsStreamUseAccountOverride(:final address):
        systemProgram = address;
        systemProgramSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        systemProgramSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'system_program',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        systemProgramSuppressed = false;
        systemProgram = SolsStreamAddress.fromBase58(
          '11111111111111111111111111111111',
        );
    }
    if (viewer == null && !viewerSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'viewer',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (slot == null && !slotSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'slot',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (room == null && !roomSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'room',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (systemProgram == null && !systemProgramSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'system_program',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamClaimConnectSlotAccounts(
      viewer: viewer!,
      slot: slot!,
      room: room!,
      systemProgram: systemProgram!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamClaimConnectSlotRequest> prepare({
    required SolsStreamClaimConnectSlotArgs args,
    SolsStreamClaimConnectSlotAccountOverrides overrides =
        const SolsStreamClaimConnectSlotAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamClaimConnectSlotRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `cleanup_expired_slot`.
final class SolsStreamCleanupExpiredSlotAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamCleanupExpiredSlotAccountOverrides({
    this.caller = const SolsStreamAccountOverride.inherit(),
    this.slot = const SolsStreamAccountOverride.inherit(),
    this.host = const SolsStreamAccountOverride.inherit(),
    this.viewer = const SolsStreamAccountOverride.inherit(),
    this.config = const SolsStreamAccountOverride.inherit(),
    this.serviceWallet = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `caller`.
  final SolsStreamAccountOverride caller;

  /// Override for `slot`.
  final SolsStreamAccountOverride slot;

  /// Override for `host`.
  final SolsStreamAccountOverride host;

  /// Override for `viewer`.
  final SolsStreamAccountOverride viewer;

  /// Override for `config`.
  final SolsStreamAccountOverride config;

  /// Override for `service_wallet`.
  final SolsStreamAccountOverride serviceWallet;
}

/// Asynchronous resolver for `cleanup_expired_slot` accounts.
final class SolsStreamCleanupExpiredSlotAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamCleanupExpiredSlotAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamCleanupExpiredSlotAccounts> resolve({
    required SolsStreamCleanupExpiredSlotArgs args,
    SolsStreamCleanupExpiredSlotAccountOverrides overrides =
        const SolsStreamCleanupExpiredSlotAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? caller;
    var callerSuppressed = false;
    switch (overrides.caller) {
      case SolsStreamUseAccountOverride(:final address):
        caller = address;
        callerSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        callerSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'caller',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        callerSuppressed = false;
        if (context.identityAccountPaths.contains('caller') &&
            context.identity != null) {
          caller = context.identity;
        }
    }
    SolsStreamAddress? slot;
    var slotSuppressed = false;
    switch (overrides.slot) {
      case SolsStreamUseAccountOverride(:final address):
        slot = address;
        slotSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        slotSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'slot',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        slotSuppressed = false;
        if (context.identityAccountPaths.contains('slot') &&
            context.identity != null) {
          slot = context.identity;
        }
    }
    SolsStreamAddress? host;
    var hostSuppressed = false;
    switch (overrides.host) {
      case SolsStreamUseAccountOverride(:final address):
        host = address;
        hostSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        hostSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'host',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        hostSuppressed = false;
        if (context.identityAccountPaths.contains('host') &&
            context.identity != null) {
          host = context.identity;
        }
    }
    SolsStreamAddress? viewer;
    var viewerSuppressed = false;
    switch (overrides.viewer) {
      case SolsStreamUseAccountOverride(:final address):
        viewer = address;
        viewerSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        viewerSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'viewer',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        viewerSuppressed = false;
        if (context.identityAccountPaths.contains('viewer') &&
            context.identity != null) {
          viewer = context.identity;
        }
    }
    SolsStreamAddress? config;
    var configSuppressed = false;
    switch (overrides.config) {
      case SolsStreamUseAccountOverride(:final address):
        config = address;
        configSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        configSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'config',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        configSuppressed = false;
        if (context.identityAccountPaths.contains('config') &&
            context.identity != null) {
          config = context.identity;
        }
    }
    SolsStreamAddress? serviceWallet;
    var serviceWalletSuppressed = false;
    switch (overrides.serviceWallet) {
      case SolsStreamUseAccountOverride(:final address):
        serviceWallet = address;
        serviceWalletSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        serviceWalletSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'service_wallet',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        serviceWalletSuppressed = false;
        if (context.identityAccountPaths.contains('service_wallet') &&
            context.identity != null) {
          serviceWallet = context.identity;
        }
    }
    for (var pass = 0; pass < 6; pass++) {
      var progressed = false;
      if (config == null && !configSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          final seeds = <Uint8List>[];
          seeds.add(Uint8List.fromList(<int>[99, 111, 110, 102, 105, 103]));
          for (var index = 0; index < seeds.length; index++) {
            if (seeds[index].length > 32) {
              throw SolsStreamPdaException(
                code: 'PDA_SEED_LENGTH',
                message: 'A PDA seed cannot exceed 32 bytes.',
                seedIndex: index,
              );
            }
          }
          final derived = await deriver.derive(
            programAddress: SolsStreamProgram.programAddress,
            seeds: seeds,
          );
          config = derived.address;
          progressed = true;
        }
      }
      if (config != null || configSuppressed) {
        break;
      }
      if (!progressed) {
        break;
      }
    }
    if (caller == null && !callerSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'caller',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (slot == null && !slotSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'slot',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (host == null && !hostSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'host',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (viewer == null && !viewerSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'viewer',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (config == null && !configSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'config',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (serviceWallet == null && !serviceWalletSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'service_wallet',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamCleanupExpiredSlotAccounts(
      caller: caller!,
      slot: slot!,
      host: host!,
      viewer: viewer!,
      config: config!,
      serviceWallet: serviceWallet!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamCleanupExpiredSlotRequest> prepare({
    required SolsStreamCleanupExpiredSlotArgs args,
    SolsStreamCleanupExpiredSlotAccountOverrides overrides =
        const SolsStreamCleanupExpiredSlotAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamCleanupExpiredSlotRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `cleanup_expired_slot_third_party`.
final class SolsStreamCleanupExpiredSlotThirdPartyAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamCleanupExpiredSlotThirdPartyAccountOverrides({
    this.caller = const SolsStreamAccountOverride.inherit(),
    this.slot = const SolsStreamAccountOverride.inherit(),
    this.host = const SolsStreamAccountOverride.inherit(),
    this.viewer = const SolsStreamAccountOverride.inherit(),
    this.config = const SolsStreamAccountOverride.inherit(),
    this.serviceWallet = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `caller`.
  final SolsStreamAccountOverride caller;

  /// Override for `slot`.
  final SolsStreamAccountOverride slot;

  /// Override for `host`.
  final SolsStreamAccountOverride host;

  /// Override for `viewer`.
  final SolsStreamAccountOverride viewer;

  /// Override for `config`.
  final SolsStreamAccountOverride config;

  /// Override for `service_wallet`.
  final SolsStreamAccountOverride serviceWallet;
}

/// Asynchronous resolver for `cleanup_expired_slot_third_party` accounts.
final class SolsStreamCleanupExpiredSlotThirdPartyAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamCleanupExpiredSlotThirdPartyAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamCleanupExpiredSlotThirdPartyAccounts> resolve({
    required SolsStreamCleanupExpiredSlotThirdPartyArgs args,
    SolsStreamCleanupExpiredSlotThirdPartyAccountOverrides overrides =
        const SolsStreamCleanupExpiredSlotThirdPartyAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? caller;
    var callerSuppressed = false;
    switch (overrides.caller) {
      case SolsStreamUseAccountOverride(:final address):
        caller = address;
        callerSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        callerSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'caller',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        callerSuppressed = false;
        if (context.identityAccountPaths.contains('caller') &&
            context.identity != null) {
          caller = context.identity;
        }
    }
    SolsStreamAddress? slot;
    var slotSuppressed = false;
    switch (overrides.slot) {
      case SolsStreamUseAccountOverride(:final address):
        slot = address;
        slotSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        slotSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'slot',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        slotSuppressed = false;
        if (context.identityAccountPaths.contains('slot') &&
            context.identity != null) {
          slot = context.identity;
        }
    }
    SolsStreamAddress? host;
    var hostSuppressed = false;
    switch (overrides.host) {
      case SolsStreamUseAccountOverride(:final address):
        host = address;
        hostSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        hostSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'host',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        hostSuppressed = false;
        if (context.identityAccountPaths.contains('host') &&
            context.identity != null) {
          host = context.identity;
        }
    }
    SolsStreamAddress? viewer;
    var viewerSuppressed = false;
    switch (overrides.viewer) {
      case SolsStreamUseAccountOverride(:final address):
        viewer = address;
        viewerSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        viewerSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'viewer',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        viewerSuppressed = false;
        if (context.identityAccountPaths.contains('viewer') &&
            context.identity != null) {
          viewer = context.identity;
        }
    }
    SolsStreamAddress? config;
    var configSuppressed = false;
    switch (overrides.config) {
      case SolsStreamUseAccountOverride(:final address):
        config = address;
        configSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        configSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'config',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        configSuppressed = false;
        if (context.identityAccountPaths.contains('config') &&
            context.identity != null) {
          config = context.identity;
        }
    }
    SolsStreamAddress? serviceWallet;
    var serviceWalletSuppressed = false;
    switch (overrides.serviceWallet) {
      case SolsStreamUseAccountOverride(:final address):
        serviceWallet = address;
        serviceWalletSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        serviceWalletSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'service_wallet',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        serviceWalletSuppressed = false;
        if (context.identityAccountPaths.contains('service_wallet') &&
            context.identity != null) {
          serviceWallet = context.identity;
        }
    }
    for (var pass = 0; pass < 6; pass++) {
      var progressed = false;
      if (config == null && !configSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          final seeds = <Uint8List>[];
          seeds.add(Uint8List.fromList(<int>[99, 111, 110, 102, 105, 103]));
          for (var index = 0; index < seeds.length; index++) {
            if (seeds[index].length > 32) {
              throw SolsStreamPdaException(
                code: 'PDA_SEED_LENGTH',
                message: 'A PDA seed cannot exceed 32 bytes.',
                seedIndex: index,
              );
            }
          }
          final derived = await deriver.derive(
            programAddress: SolsStreamProgram.programAddress,
            seeds: seeds,
          );
          config = derived.address;
          progressed = true;
        }
      }
      if (config != null || configSuppressed) {
        break;
      }
      if (!progressed) {
        break;
      }
    }
    if (caller == null && !callerSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'caller',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (slot == null && !slotSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'slot',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (host == null && !hostSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'host',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (viewer == null && !viewerSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'viewer',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (config == null && !configSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'config',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (serviceWallet == null && !serviceWalletSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'service_wallet',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamCleanupExpiredSlotThirdPartyAccounts(
      caller: caller!,
      slot: slot!,
      host: host!,
      viewer: viewer!,
      config: config!,
      serviceWallet: serviceWallet!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamCleanupExpiredSlotThirdPartyRequest> prepare({
    required SolsStreamCleanupExpiredSlotThirdPartyArgs args,
    SolsStreamCleanupExpiredSlotThirdPartyAccountOverrides overrides =
        const SolsStreamCleanupExpiredSlotThirdPartyAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamCleanupExpiredSlotThirdPartyRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `cleanup_stale_room`.
final class SolsStreamCleanupStaleRoomAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamCleanupStaleRoomAccountOverrides({
    this.caller = const SolsStreamAccountOverride.inherit(),
    this.room = const SolsStreamAccountOverride.inherit(),
    this.hostUser = const SolsStreamAccountOverride.inherit(),
    this.hostWallet = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `caller`.
  final SolsStreamAccountOverride caller;

  /// Override for `room`.
  final SolsStreamAccountOverride room;

  /// Override for `host_user`.
  final SolsStreamAccountOverride hostUser;

  /// Override for `host_wallet`.
  final SolsStreamAccountOverride hostWallet;
}

/// Asynchronous resolver for `cleanup_stale_room` accounts.
final class SolsStreamCleanupStaleRoomAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamCleanupStaleRoomAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamCleanupStaleRoomAccounts> resolve({
    required SolsStreamCleanupStaleRoomArgs args,
    SolsStreamCleanupStaleRoomAccountOverrides overrides =
        const SolsStreamCleanupStaleRoomAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    final seedAccountCache =
        <SolsStreamAddress, Future<SolsStreamAccountSnapshot?>>{};
    SolsStreamAddress? caller;
    var callerSuppressed = false;
    switch (overrides.caller) {
      case SolsStreamUseAccountOverride(:final address):
        caller = address;
        callerSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        callerSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'caller',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        callerSuppressed = false;
        if (context.identityAccountPaths.contains('caller') &&
            context.identity != null) {
          caller = context.identity;
        }
    }
    SolsStreamAddress? room;
    var roomSuppressed = false;
    switch (overrides.room) {
      case SolsStreamUseAccountOverride(:final address):
        room = address;
        roomSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        roomSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'room',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        roomSuppressed = false;
        if (context.identityAccountPaths.contains('room') &&
            context.identity != null) {
          room = context.identity;
        }
    }
    SolsStreamAddress? hostUser;
    var hostUserSuppressed = false;
    switch (overrides.hostUser) {
      case SolsStreamUseAccountOverride(:final address):
        hostUser = address;
        hostUserSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        hostUserSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'host_user',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        hostUserSuppressed = false;
        if (context.identityAccountPaths.contains('host_user') &&
            context.identity != null) {
          hostUser = context.identity;
        }
    }
    SolsStreamAddress? hostWallet;
    var hostWalletSuppressed = false;
    switch (overrides.hostWallet) {
      case SolsStreamUseAccountOverride(:final address):
        hostWallet = address;
        hostWalletSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        hostWalletSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'host_wallet',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        hostWalletSuppressed = false;
        if (context.identityAccountPaths.contains('host_wallet') &&
            context.identity != null) {
          hostWallet = context.identity;
        }
    }
    for (var pass = 0; pass < 4; pass++) {
      var progressed = false;
      if (hostUser == null && !hostUserSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          if (room != null) {
            final seeds = <Uint8List>[];
            seeds.add(Uint8List.fromList(<int>[117, 115, 101, 114]));
            final seedReader1 = context.accountReader;
            if (seedReader1 == null) {
              throw SolsStreamPdaException(
                code: 'PDA_ACCOUNT_READER_REQUIRED',
                message:
                    'AccountReader is required for account-data PDA seeds.',
                seedIndex: 1,
              );
            }
            final seedSnapshot1 = await (seedAccountCache[room] ??= seedReader1
                .readAccount(room, options: context.readOptions));
            if (seedSnapshot1 == null) {
              throw SolsStreamPdaException(
                code: 'PDA_SOURCE_MISSING',
                message: 'PDA seed source account does not exist.',
                seedIndex: 1,
              );
            }
            if (seedSnapshot1.owner != SolsStreamProgram.programAddress) {
              throw SolsStreamPdaException(
                code: 'PDA_SOURCE_OWNER',
                message: 'PDA seed source account owner mismatch.',
                seedIndex: 1,
              );
            }
            final seedAccount1 = SolsStreamRoomAccount.decodeAccount(
              seedSnapshot1.data,
              limits: context.decodeLimits,
            );
            seeds.add(seedAccount1.host.bytes);
            for (var index = 0; index < seeds.length; index++) {
              if (seeds[index].length > 32) {
                throw SolsStreamPdaException(
                  code: 'PDA_SEED_LENGTH',
                  message: 'A PDA seed cannot exceed 32 bytes.',
                  seedIndex: index,
                );
              }
            }
            final derived = await deriver.derive(
              programAddress: SolsStreamProgram.programAddress,
              seeds: seeds,
            );
            hostUser = derived.address;
            progressed = true;
          }
        }
      }
      if (hostUser != null || hostUserSuppressed) {
        break;
      }
      if (!progressed) {
        break;
      }
    }
    if (caller == null && !callerSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'caller',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (room == null && !roomSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'room',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (hostUser == null && !hostUserSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'host_user',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (hostWallet == null && !hostWalletSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'host_wallet',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamCleanupStaleRoomAccounts(
      caller: caller!,
      room: room!,
      hostUser: hostUser!,
      hostWallet: hostWallet!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamCleanupStaleRoomRequest> prepare({
    required SolsStreamCleanupStaleRoomArgs args,
    SolsStreamCleanupStaleRoomAccountOverrides overrides =
        const SolsStreamCleanupStaleRoomAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamCleanupStaleRoomRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `cleanup_stale_user`.
final class SolsStreamCleanupStaleUserAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamCleanupStaleUserAccountOverrides({
    this.caller = const SolsStreamAccountOverride.inherit(),
    this.targetUser = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `caller`.
  final SolsStreamAccountOverride caller;

  /// Override for `target_user`.
  final SolsStreamAccountOverride targetUser;
}

/// Asynchronous resolver for `cleanup_stale_user` accounts.
final class SolsStreamCleanupStaleUserAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamCleanupStaleUserAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamCleanupStaleUserAccounts> resolve({
    required SolsStreamCleanupStaleUserArgs args,
    SolsStreamCleanupStaleUserAccountOverrides overrides =
        const SolsStreamCleanupStaleUserAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? caller;
    var callerSuppressed = false;
    switch (overrides.caller) {
      case SolsStreamUseAccountOverride(:final address):
        caller = address;
        callerSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        callerSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'caller',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        callerSuppressed = false;
        if (context.identityAccountPaths.contains('caller') &&
            context.identity != null) {
          caller = context.identity;
        }
    }
    SolsStreamAddress? targetUser;
    var targetUserSuppressed = false;
    switch (overrides.targetUser) {
      case SolsStreamUseAccountOverride(:final address):
        targetUser = address;
        targetUserSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        targetUserSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'target_user',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        targetUserSuppressed = false;
        if (context.identityAccountPaths.contains('target_user') &&
            context.identity != null) {
          targetUser = context.identity;
        }
    }
    if (caller == null && !callerSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'caller',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (targetUser == null && !targetUserSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'target_user',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamCleanupStaleUserAccounts(
      caller: caller!,
      targetUser: targetUser!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamCleanupStaleUserRequest> prepare({
    required SolsStreamCleanupStaleUserArgs args,
    SolsStreamCleanupStaleUserAccountOverrides overrides =
        const SolsStreamCleanupStaleUserAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamCleanupStaleUserRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `close_connect_slot`.
final class SolsStreamCloseConnectSlotAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamCloseConnectSlotAccountOverrides({
    this.host = const SolsStreamAccountOverride.inherit(),
    this.slot = const SolsStreamAccountOverride.inherit(),
    this.viewer = const SolsStreamAccountOverride.inherit(),
    this.config = const SolsStreamAccountOverride.inherit(),
    this.serviceWallet = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `host`.
  final SolsStreamAccountOverride host;

  /// Override for `slot`.
  final SolsStreamAccountOverride slot;

  /// Override for `viewer`.
  final SolsStreamAccountOverride viewer;

  /// Override for `config`.
  final SolsStreamAccountOverride config;

  /// Override for `service_wallet`.
  final SolsStreamAccountOverride serviceWallet;
}

/// Asynchronous resolver for `close_connect_slot` accounts.
final class SolsStreamCloseConnectSlotAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamCloseConnectSlotAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamCloseConnectSlotAccounts> resolve({
    required SolsStreamCloseConnectSlotArgs args,
    SolsStreamCloseConnectSlotAccountOverrides overrides =
        const SolsStreamCloseConnectSlotAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? host;
    var hostSuppressed = false;
    switch (overrides.host) {
      case SolsStreamUseAccountOverride(:final address):
        host = address;
        hostSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        hostSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'host',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        hostSuppressed = false;
        if (context.identityAccountPaths.contains('host') &&
            context.identity != null) {
          host = context.identity;
        }
    }
    SolsStreamAddress? slot;
    var slotSuppressed = false;
    switch (overrides.slot) {
      case SolsStreamUseAccountOverride(:final address):
        slot = address;
        slotSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        slotSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'slot',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        slotSuppressed = false;
        if (context.identityAccountPaths.contains('slot') &&
            context.identity != null) {
          slot = context.identity;
        }
    }
    SolsStreamAddress? viewer;
    var viewerSuppressed = false;
    switch (overrides.viewer) {
      case SolsStreamUseAccountOverride(:final address):
        viewer = address;
        viewerSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        viewerSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'viewer',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        viewerSuppressed = false;
        if (context.identityAccountPaths.contains('viewer') &&
            context.identity != null) {
          viewer = context.identity;
        }
    }
    SolsStreamAddress? config;
    var configSuppressed = false;
    switch (overrides.config) {
      case SolsStreamUseAccountOverride(:final address):
        config = address;
        configSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        configSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'config',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        configSuppressed = false;
        if (context.identityAccountPaths.contains('config') &&
            context.identity != null) {
          config = context.identity;
        }
    }
    SolsStreamAddress? serviceWallet;
    var serviceWalletSuppressed = false;
    switch (overrides.serviceWallet) {
      case SolsStreamUseAccountOverride(:final address):
        serviceWallet = address;
        serviceWalletSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        serviceWalletSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'service_wallet',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        serviceWalletSuppressed = false;
        if (context.identityAccountPaths.contains('service_wallet') &&
            context.identity != null) {
          serviceWallet = context.identity;
        }
    }
    for (var pass = 0; pass < 5; pass++) {
      var progressed = false;
      if (config == null && !configSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          final seeds = <Uint8List>[];
          seeds.add(Uint8List.fromList(<int>[99, 111, 110, 102, 105, 103]));
          for (var index = 0; index < seeds.length; index++) {
            if (seeds[index].length > 32) {
              throw SolsStreamPdaException(
                code: 'PDA_SEED_LENGTH',
                message: 'A PDA seed cannot exceed 32 bytes.',
                seedIndex: index,
              );
            }
          }
          final derived = await deriver.derive(
            programAddress: SolsStreamProgram.programAddress,
            seeds: seeds,
          );
          config = derived.address;
          progressed = true;
        }
      }
      if (config != null || configSuppressed) {
        break;
      }
      if (!progressed) {
        break;
      }
    }
    if (host == null && !hostSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'host',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (slot == null && !slotSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'slot',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (viewer == null && !viewerSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'viewer',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (config == null && !configSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'config',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (serviceWallet == null && !serviceWalletSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'service_wallet',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamCloseConnectSlotAccounts(
      host: host!,
      slot: slot!,
      viewer: viewer!,
      config: config!,
      serviceWallet: serviceWallet!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamCloseConnectSlotRequest> prepare({
    required SolsStreamCloseConnectSlotArgs args,
    SolsStreamCloseConnectSlotAccountOverrides overrides =
        const SolsStreamCloseConnectSlotAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamCloseConnectSlotRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `close_room`.
final class SolsStreamCloseRoomAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamCloseRoomAccountOverrides({
    this.host = const SolsStreamAccountOverride.inherit(),
    this.hostUser = const SolsStreamAccountOverride.inherit(),
    this.room = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `host`.
  final SolsStreamAccountOverride host;

  /// Override for `host_user`.
  final SolsStreamAccountOverride hostUser;

  /// Override for `room`.
  final SolsStreamAccountOverride room;
}

/// Asynchronous resolver for `close_room` accounts.
final class SolsStreamCloseRoomAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamCloseRoomAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamCloseRoomAccounts> resolve({
    required SolsStreamCloseRoomArgs args,
    SolsStreamCloseRoomAccountOverrides overrides =
        const SolsStreamCloseRoomAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? host;
    var hostSuppressed = false;
    switch (overrides.host) {
      case SolsStreamUseAccountOverride(:final address):
        host = address;
        hostSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        hostSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'host',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        hostSuppressed = false;
        if (context.identityAccountPaths.contains('host') &&
            context.identity != null) {
          host = context.identity;
        }
    }
    SolsStreamAddress? hostUser;
    var hostUserSuppressed = false;
    switch (overrides.hostUser) {
      case SolsStreamUseAccountOverride(:final address):
        hostUser = address;
        hostUserSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        hostUserSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'host_user',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        hostUserSuppressed = false;
        if (context.identityAccountPaths.contains('host_user') &&
            context.identity != null) {
          hostUser = context.identity;
        }
    }
    SolsStreamAddress? room;
    var roomSuppressed = false;
    switch (overrides.room) {
      case SolsStreamUseAccountOverride(:final address):
        room = address;
        roomSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        roomSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'room',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        roomSuppressed = false;
        if (context.identityAccountPaths.contains('room') &&
            context.identity != null) {
          room = context.identity;
        }
    }
    for (var pass = 0; pass < 3; pass++) {
      var progressed = false;
      if (hostUser == null && !hostUserSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          if (host != null) {
            final seeds = <Uint8List>[];
            seeds.add(Uint8List.fromList(<int>[117, 115, 101, 114]));
            seeds.add(host.bytes);
            for (var index = 0; index < seeds.length; index++) {
              if (seeds[index].length > 32) {
                throw SolsStreamPdaException(
                  code: 'PDA_SEED_LENGTH',
                  message: 'A PDA seed cannot exceed 32 bytes.',
                  seedIndex: index,
                );
              }
            }
            final derived = await deriver.derive(
              programAddress: SolsStreamProgram.programAddress,
              seeds: seeds,
            );
            hostUser = derived.address;
            progressed = true;
          }
        }
      }
      if (hostUser != null || hostUserSuppressed) {
        break;
      }
      if (!progressed) {
        break;
      }
    }
    if (host == null && !hostSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'host',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (hostUser == null && !hostUserSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'host_user',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (room == null && !roomSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'room',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamCloseRoomAccounts(
      host: host!,
      hostUser: hostUser!,
      room: room!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamCloseRoomRequest> prepare({
    required SolsStreamCloseRoomArgs args,
    SolsStreamCloseRoomAccountOverrides overrides =
        const SolsStreamCloseRoomAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamCloseRoomRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `close_user`.
final class SolsStreamCloseUserAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamCloseUserAccountOverrides({
    this.authority = const SolsStreamAccountOverride.inherit(),
    this.user = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `authority`.
  final SolsStreamAccountOverride authority;

  /// Override for `user`.
  final SolsStreamAccountOverride user;
}

/// Asynchronous resolver for `close_user` accounts.
final class SolsStreamCloseUserAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamCloseUserAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamCloseUserAccounts> resolve({
    required SolsStreamCloseUserArgs args,
    SolsStreamCloseUserAccountOverrides overrides =
        const SolsStreamCloseUserAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? authority;
    var authoritySuppressed = false;
    switch (overrides.authority) {
      case SolsStreamUseAccountOverride(:final address):
        authority = address;
        authoritySuppressed = false;
      case SolsStreamAbsentAccountOverride():
        authoritySuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'authority',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        authoritySuppressed = false;
        if (context.identityAccountPaths.contains('authority') &&
            context.identity != null) {
          authority = context.identity;
        }
    }
    SolsStreamAddress? user;
    var userSuppressed = false;
    switch (overrides.user) {
      case SolsStreamUseAccountOverride(:final address):
        user = address;
        userSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        userSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'user',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        userSuppressed = false;
        if (context.identityAccountPaths.contains('user') &&
            context.identity != null) {
          user = context.identity;
        }
    }
    for (var pass = 0; pass < 2; pass++) {
      var progressed = false;
      if (authority == null && !authoritySuppressed) {
        final relationResolver = context.relationResolver;
        if (relationResolver != null) {
          if (authority == null) {
            final authorityRelation0 = await relationResolver.resolveRelation(
              accountPath: 'authority',
              relationPath: 'user',
              resolvedAccounts: {
                if (authority != null) 'authority': authority,
                if (user != null) 'user': user,
              },
            );
            if (authorityRelation0 != null) {
              authority = authorityRelation0;
              progressed = true;
            }
          }
        }
      }
      if (user == null && !userSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          if (authority != null) {
            final seeds = <Uint8List>[];
            seeds.add(Uint8List.fromList(<int>[117, 115, 101, 114]));
            seeds.add(authority.bytes);
            for (var index = 0; index < seeds.length; index++) {
              if (seeds[index].length > 32) {
                throw SolsStreamPdaException(
                  code: 'PDA_SEED_LENGTH',
                  message: 'A PDA seed cannot exceed 32 bytes.',
                  seedIndex: index,
                );
              }
            }
            final derived = await deriver.derive(
              programAddress: SolsStreamProgram.programAddress,
              seeds: seeds,
            );
            user = derived.address;
            progressed = true;
          }
        }
      }
      if (authority != null ||
          authoritySuppressed && user != null ||
          userSuppressed) {
        break;
      }
      if (!progressed) {
        break;
      }
    }
    if (authority == null && !authoritySuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'authority',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (user == null && !userSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'user',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamCloseUserAccounts(authority: authority!, user: user!);
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamCloseUserRequest> prepare({
    required SolsStreamCloseUserArgs args,
    SolsStreamCloseUserAccountOverrides overrides =
        const SolsStreamCloseUserAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamCloseUserRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `confirm_connection`.
final class SolsStreamConfirmConnectionAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamConfirmConnectionAccountOverrides({
    this.signer = const SolsStreamAccountOverride.inherit(),
    this.slot = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `signer`.
  final SolsStreamAccountOverride signer;

  /// Override for `slot`.
  final SolsStreamAccountOverride slot;
}

/// Asynchronous resolver for `confirm_connection` accounts.
final class SolsStreamConfirmConnectionAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamConfirmConnectionAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamConfirmConnectionAccounts> resolve({
    required SolsStreamConfirmConnectionArgs args,
    SolsStreamConfirmConnectionAccountOverrides overrides =
        const SolsStreamConfirmConnectionAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? signer;
    var signerSuppressed = false;
    switch (overrides.signer) {
      case SolsStreamUseAccountOverride(:final address):
        signer = address;
        signerSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        signerSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'signer',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        signerSuppressed = false;
        if (context.identityAccountPaths.contains('signer') &&
            context.identity != null) {
          signer = context.identity;
        }
    }
    SolsStreamAddress? slot;
    var slotSuppressed = false;
    switch (overrides.slot) {
      case SolsStreamUseAccountOverride(:final address):
        slot = address;
        slotSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        slotSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'slot',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        slotSuppressed = false;
        if (context.identityAccountPaths.contains('slot') &&
            context.identity != null) {
          slot = context.identity;
        }
    }
    if (signer == null && !signerSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'signer',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (slot == null && !slotSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'slot',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamConfirmConnectionAccounts(signer: signer!, slot: slot!);
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamConfirmConnectionRequest> prepare({
    required SolsStreamConfirmConnectionArgs args,
    SolsStreamConfirmConnectionAccountOverrides overrides =
        const SolsStreamConfirmConnectionAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamConfirmConnectionRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `create_room`.
final class SolsStreamCreateRoomAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamCreateRoomAccountOverrides({
    this.host = const SolsStreamAccountOverride.inherit(),
    this.hostUser = const SolsStreamAccountOverride.inherit(),
    this.room = const SolsStreamAccountOverride.inherit(),
    this.systemProgram = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `host`.
  final SolsStreamAccountOverride host;

  /// Override for `host_user`.
  final SolsStreamAccountOverride hostUser;

  /// Override for `room`.
  final SolsStreamAccountOverride room;

  /// Override for `system_program`.
  final SolsStreamAccountOverride systemProgram;
}

/// Asynchronous resolver for `create_room` accounts.
final class SolsStreamCreateRoomAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamCreateRoomAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamCreateRoomAccounts> resolve({
    required SolsStreamCreateRoomArgs args,
    SolsStreamCreateRoomAccountOverrides overrides =
        const SolsStreamCreateRoomAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? host;
    var hostSuppressed = false;
    switch (overrides.host) {
      case SolsStreamUseAccountOverride(:final address):
        host = address;
        hostSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        hostSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'host',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        hostSuppressed = false;
        if (context.identityAccountPaths.contains('host') &&
            context.identity != null) {
          host = context.identity;
        }
    }
    SolsStreamAddress? hostUser;
    var hostUserSuppressed = false;
    switch (overrides.hostUser) {
      case SolsStreamUseAccountOverride(:final address):
        hostUser = address;
        hostUserSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        hostUserSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'host_user',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        hostUserSuppressed = false;
        if (context.identityAccountPaths.contains('host_user') &&
            context.identity != null) {
          hostUser = context.identity;
        }
    }
    SolsStreamAddress? room;
    var roomSuppressed = false;
    switch (overrides.room) {
      case SolsStreamUseAccountOverride(:final address):
        room = address;
        roomSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        roomSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'room',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        roomSuppressed = false;
        if (context.identityAccountPaths.contains('room') &&
            context.identity != null) {
          room = context.identity;
        }
    }
    SolsStreamAddress? systemProgram;
    var systemProgramSuppressed = false;
    switch (overrides.systemProgram) {
      case SolsStreamUseAccountOverride(:final address):
        systemProgram = address;
        systemProgramSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        systemProgramSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'system_program',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        systemProgramSuppressed = false;
        systemProgram = SolsStreamAddress.fromBase58(
          '11111111111111111111111111111111',
        );
    }
    for (var pass = 0; pass < 4; pass++) {
      var progressed = false;
      if (hostUser == null && !hostUserSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          if (host != null) {
            final seeds = <Uint8List>[];
            seeds.add(Uint8List.fromList(<int>[117, 115, 101, 114]));
            seeds.add(host.bytes);
            for (var index = 0; index < seeds.length; index++) {
              if (seeds[index].length > 32) {
                throw SolsStreamPdaException(
                  code: 'PDA_SEED_LENGTH',
                  message: 'A PDA seed cannot exceed 32 bytes.',
                  seedIndex: index,
                );
              }
            }
            final derived = await deriver.derive(
              programAddress: SolsStreamProgram.programAddress,
              seeds: seeds,
            );
            hostUser = derived.address;
            progressed = true;
          }
        }
      }
      if (room == null && !roomSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          if (host != null) {
            final seeds = <Uint8List>[];
            seeds.add(Uint8List.fromList(<int>[114, 111, 111, 109]));
            seeds.add(host.bytes);
            final seedWriter4 = SolsStreamBorshWriter();
            seedWriter4.writeUnsigned(args.nonce, 8);
            seeds.add(seedWriter4.takeBytes());
            for (var index = 0; index < seeds.length; index++) {
              if (seeds[index].length > 32) {
                throw SolsStreamPdaException(
                  code: 'PDA_SEED_LENGTH',
                  message: 'A PDA seed cannot exceed 32 bytes.',
                  seedIndex: index,
                );
              }
            }
            final derived = await deriver.derive(
              programAddress: SolsStreamProgram.programAddress,
              seeds: seeds,
            );
            room = derived.address;
            progressed = true;
          }
        }
      }
      if (hostUser != null ||
          hostUserSuppressed && room != null ||
          roomSuppressed) {
        break;
      }
      if (!progressed) {
        break;
      }
    }
    if (host == null && !hostSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'host',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (hostUser == null && !hostUserSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'host_user',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (room == null && !roomSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'room',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (systemProgram == null && !systemProgramSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'system_program',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamCreateRoomAccounts(
      host: host!,
      hostUser: hostUser!,
      room: room!,
      systemProgram: systemProgram!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamCreateRoomRequest> prepare({
    required SolsStreamCreateRoomArgs args,
    SolsStreamCreateRoomAccountOverrides overrides =
        const SolsStreamCreateRoomAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamCreateRoomRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `create_user`.
final class SolsStreamCreateUserAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamCreateUserAccountOverrides({
    this.authority = const SolsStreamAccountOverride.inherit(),
    this.user = const SolsStreamAccountOverride.inherit(),
    this.systemProgram = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `authority`.
  final SolsStreamAccountOverride authority;

  /// Override for `user`.
  final SolsStreamAccountOverride user;

  /// Override for `system_program`.
  final SolsStreamAccountOverride systemProgram;
}

/// Asynchronous resolver for `create_user` accounts.
final class SolsStreamCreateUserAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamCreateUserAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamCreateUserAccounts> resolve({
    required SolsStreamCreateUserArgs args,
    SolsStreamCreateUserAccountOverrides overrides =
        const SolsStreamCreateUserAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? authority;
    var authoritySuppressed = false;
    switch (overrides.authority) {
      case SolsStreamUseAccountOverride(:final address):
        authority = address;
        authoritySuppressed = false;
      case SolsStreamAbsentAccountOverride():
        authoritySuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'authority',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        authoritySuppressed = false;
        if (context.identityAccountPaths.contains('authority') &&
            context.identity != null) {
          authority = context.identity;
        }
    }
    SolsStreamAddress? user;
    var userSuppressed = false;
    switch (overrides.user) {
      case SolsStreamUseAccountOverride(:final address):
        user = address;
        userSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        userSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'user',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        userSuppressed = false;
        if (context.identityAccountPaths.contains('user') &&
            context.identity != null) {
          user = context.identity;
        }
    }
    SolsStreamAddress? systemProgram;
    var systemProgramSuppressed = false;
    switch (overrides.systemProgram) {
      case SolsStreamUseAccountOverride(:final address):
        systemProgram = address;
        systemProgramSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        systemProgramSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'system_program',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        systemProgramSuppressed = false;
        systemProgram = SolsStreamAddress.fromBase58(
          '11111111111111111111111111111111',
        );
    }
    for (var pass = 0; pass < 3; pass++) {
      var progressed = false;
      if (user == null && !userSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          if (authority != null) {
            final seeds = <Uint8List>[];
            seeds.add(Uint8List.fromList(<int>[117, 115, 101, 114]));
            seeds.add(authority.bytes);
            for (var index = 0; index < seeds.length; index++) {
              if (seeds[index].length > 32) {
                throw SolsStreamPdaException(
                  code: 'PDA_SEED_LENGTH',
                  message: 'A PDA seed cannot exceed 32 bytes.',
                  seedIndex: index,
                );
              }
            }
            final derived = await deriver.derive(
              programAddress: SolsStreamProgram.programAddress,
              seeds: seeds,
            );
            user = derived.address;
            progressed = true;
          }
        }
      }
      if (user != null || userSuppressed) {
        break;
      }
      if (!progressed) {
        break;
      }
    }
    if (authority == null && !authoritySuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'authority',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (user == null && !userSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'user',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (systemProgram == null && !systemProgramSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'system_program',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamCreateUserAccounts(
      authority: authority!,
      user: user!,
      systemProgram: systemProgram!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamCreateUserRequest> prepare({
    required SolsStreamCreateUserArgs args,
    SolsStreamCreateUserAccountOverrides overrides =
        const SolsStreamCreateUserAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamCreateUserRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `end_room`.
final class SolsStreamEndRoomAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamEndRoomAccountOverrides({
    this.host = const SolsStreamAccountOverride.inherit(),
    this.hostUser = const SolsStreamAccountOverride.inherit(),
    this.room = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `host`.
  final SolsStreamAccountOverride host;

  /// Override for `host_user`.
  final SolsStreamAccountOverride hostUser;

  /// Override for `room`.
  final SolsStreamAccountOverride room;
}

/// Asynchronous resolver for `end_room` accounts.
final class SolsStreamEndRoomAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamEndRoomAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamEndRoomAccounts> resolve({
    required SolsStreamEndRoomArgs args,
    SolsStreamEndRoomAccountOverrides overrides =
        const SolsStreamEndRoomAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? host;
    var hostSuppressed = false;
    switch (overrides.host) {
      case SolsStreamUseAccountOverride(:final address):
        host = address;
        hostSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        hostSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'host',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        hostSuppressed = false;
        if (context.identityAccountPaths.contains('host') &&
            context.identity != null) {
          host = context.identity;
        }
    }
    SolsStreamAddress? hostUser;
    var hostUserSuppressed = false;
    switch (overrides.hostUser) {
      case SolsStreamUseAccountOverride(:final address):
        hostUser = address;
        hostUserSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        hostUserSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'host_user',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        hostUserSuppressed = false;
        if (context.identityAccountPaths.contains('host_user') &&
            context.identity != null) {
          hostUser = context.identity;
        }
    }
    SolsStreamAddress? room;
    var roomSuppressed = false;
    switch (overrides.room) {
      case SolsStreamUseAccountOverride(:final address):
        room = address;
        roomSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        roomSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'room',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        roomSuppressed = false;
        if (context.identityAccountPaths.contains('room') &&
            context.identity != null) {
          room = context.identity;
        }
    }
    for (var pass = 0; pass < 3; pass++) {
      var progressed = false;
      if (hostUser == null && !hostUserSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          if (host != null) {
            final seeds = <Uint8List>[];
            seeds.add(Uint8List.fromList(<int>[117, 115, 101, 114]));
            seeds.add(host.bytes);
            for (var index = 0; index < seeds.length; index++) {
              if (seeds[index].length > 32) {
                throw SolsStreamPdaException(
                  code: 'PDA_SEED_LENGTH',
                  message: 'A PDA seed cannot exceed 32 bytes.',
                  seedIndex: index,
                );
              }
            }
            final derived = await deriver.derive(
              programAddress: SolsStreamProgram.programAddress,
              seeds: seeds,
            );
            hostUser = derived.address;
            progressed = true;
          }
        }
      }
      if (hostUser != null || hostUserSuppressed) {
        break;
      }
      if (!progressed) {
        break;
      }
    }
    if (host == null && !hostSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'host',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (hostUser == null && !hostUserSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'host_user',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (room == null && !roomSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'room',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamEndRoomAccounts(
      host: host!,
      hostUser: hostUser!,
      room: room!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamEndRoomRequest> prepare({
    required SolsStreamEndRoomArgs args,
    SolsStreamEndRoomAccountOverrides overrides =
        const SolsStreamEndRoomAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamEndRoomRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `expire_viewer`.
final class SolsStreamExpireViewerAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamExpireViewerAccountOverrides({
    this.caller = const SolsStreamAccountOverride.inherit(),
    this.targetUser = const SolsStreamAccountOverride.inherit(),
    this.room = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `caller`.
  final SolsStreamAccountOverride caller;

  /// Override for `target_user`.
  final SolsStreamAccountOverride targetUser;

  /// Override for `room`.
  final SolsStreamAccountOverride room;
}

/// Asynchronous resolver for `expire_viewer` accounts.
final class SolsStreamExpireViewerAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamExpireViewerAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamExpireViewerAccounts> resolve({
    required SolsStreamExpireViewerArgs args,
    SolsStreamExpireViewerAccountOverrides overrides =
        const SolsStreamExpireViewerAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? caller;
    var callerSuppressed = false;
    switch (overrides.caller) {
      case SolsStreamUseAccountOverride(:final address):
        caller = address;
        callerSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        callerSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'caller',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        callerSuppressed = false;
        if (context.identityAccountPaths.contains('caller') &&
            context.identity != null) {
          caller = context.identity;
        }
    }
    SolsStreamAddress? targetUser;
    var targetUserSuppressed = false;
    switch (overrides.targetUser) {
      case SolsStreamUseAccountOverride(:final address):
        targetUser = address;
        targetUserSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        targetUserSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'target_user',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        targetUserSuppressed = false;
        if (context.identityAccountPaths.contains('target_user') &&
            context.identity != null) {
          targetUser = context.identity;
        }
    }
    SolsStreamAddress? room;
    var roomSuppressed = false;
    switch (overrides.room) {
      case SolsStreamUseAccountOverride(:final address):
        room = address;
        roomSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        roomSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'room',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        roomSuppressed = false;
        if (context.identityAccountPaths.contains('room') &&
            context.identity != null) {
          room = context.identity;
        }
    }
    if (caller == null && !callerSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'caller',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (targetUser == null && !targetUserSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'target_user',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (room == null && !roomSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'room',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamExpireViewerAccounts(
      caller: caller!,
      targetUser: targetUser!,
      room: room!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamExpireViewerRequest> prepare({
    required SolsStreamExpireViewerArgs args,
    SolsStreamExpireViewerAccountOverrides overrides =
        const SolsStreamExpireViewerAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamExpireViewerRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `heartbeat`.
final class SolsStreamHeartbeatAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamHeartbeatAccountOverrides({
    this.viewer = const SolsStreamAccountOverride.inherit(),
    this.viewerUser = const SolsStreamAccountOverride.inherit(),
    this.config = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `viewer`.
  final SolsStreamAccountOverride viewer;

  /// Override for `viewer_user`.
  final SolsStreamAccountOverride viewerUser;

  /// Override for `config`.
  final SolsStreamAccountOverride config;
}

/// Asynchronous resolver for `heartbeat` accounts.
final class SolsStreamHeartbeatAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamHeartbeatAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamHeartbeatAccounts> resolve({
    required SolsStreamHeartbeatArgs args,
    SolsStreamHeartbeatAccountOverrides overrides =
        const SolsStreamHeartbeatAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? viewer;
    var viewerSuppressed = false;
    switch (overrides.viewer) {
      case SolsStreamUseAccountOverride(:final address):
        viewer = address;
        viewerSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        viewerSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'viewer',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        viewerSuppressed = false;
        if (context.identityAccountPaths.contains('viewer') &&
            context.identity != null) {
          viewer = context.identity;
        }
    }
    SolsStreamAddress? viewerUser;
    var viewerUserSuppressed = false;
    switch (overrides.viewerUser) {
      case SolsStreamUseAccountOverride(:final address):
        viewerUser = address;
        viewerUserSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        viewerUserSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'viewer_user',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        viewerUserSuppressed = false;
        if (context.identityAccountPaths.contains('viewer_user') &&
            context.identity != null) {
          viewerUser = context.identity;
        }
    }
    SolsStreamAddress? config;
    var configSuppressed = false;
    switch (overrides.config) {
      case SolsStreamUseAccountOverride(:final address):
        config = address;
        configSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        configSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'config',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        configSuppressed = false;
        if (context.identityAccountPaths.contains('config') &&
            context.identity != null) {
          config = context.identity;
        }
    }
    for (var pass = 0; pass < 3; pass++) {
      var progressed = false;
      if (viewerUser == null && !viewerUserSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          if (viewer != null) {
            final seeds = <Uint8List>[];
            seeds.add(Uint8List.fromList(<int>[117, 115, 101, 114]));
            seeds.add(viewer.bytes);
            for (var index = 0; index < seeds.length; index++) {
              if (seeds[index].length > 32) {
                throw SolsStreamPdaException(
                  code: 'PDA_SEED_LENGTH',
                  message: 'A PDA seed cannot exceed 32 bytes.',
                  seedIndex: index,
                );
              }
            }
            final derived = await deriver.derive(
              programAddress: SolsStreamProgram.programAddress,
              seeds: seeds,
            );
            viewerUser = derived.address;
            progressed = true;
          }
        }
      }
      if (config == null && !configSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          final seeds = <Uint8List>[];
          seeds.add(Uint8List.fromList(<int>[99, 111, 110, 102, 105, 103]));
          for (var index = 0; index < seeds.length; index++) {
            if (seeds[index].length > 32) {
              throw SolsStreamPdaException(
                code: 'PDA_SEED_LENGTH',
                message: 'A PDA seed cannot exceed 32 bytes.',
                seedIndex: index,
              );
            }
          }
          final derived = await deriver.derive(
            programAddress: SolsStreamProgram.programAddress,
            seeds: seeds,
          );
          config = derived.address;
          progressed = true;
        }
      }
      if (viewerUser != null ||
          viewerUserSuppressed && config != null ||
          configSuppressed) {
        break;
      }
      if (!progressed) {
        break;
      }
    }
    if (viewer == null && !viewerSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'viewer',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (viewerUser == null && !viewerUserSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'viewer_user',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (config == null && !configSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'config',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamHeartbeatAccounts(
      viewer: viewer!,
      viewerUser: viewerUser!,
      config: config!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamHeartbeatRequest> prepare({
    required SolsStreamHeartbeatArgs args,
    SolsStreamHeartbeatAccountOverrides overrides =
        const SolsStreamHeartbeatAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamHeartbeatRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `initialize`.
final class SolsStreamInitializeAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamInitializeAccountOverrides({
    this.authority = const SolsStreamAccountOverride.inherit(),
    this.config = const SolsStreamAccountOverride.inherit(),
    this.systemProgram = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `authority`.
  final SolsStreamAccountOverride authority;

  /// Override for `config`.
  final SolsStreamAccountOverride config;

  /// Override for `system_program`.
  final SolsStreamAccountOverride systemProgram;
}

/// Asynchronous resolver for `initialize` accounts.
final class SolsStreamInitializeAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamInitializeAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamInitializeAccounts> resolve({
    required SolsStreamInitializeArgs args,
    SolsStreamInitializeAccountOverrides overrides =
        const SolsStreamInitializeAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? authority;
    var authoritySuppressed = false;
    switch (overrides.authority) {
      case SolsStreamUseAccountOverride(:final address):
        authority = address;
        authoritySuppressed = false;
      case SolsStreamAbsentAccountOverride():
        authoritySuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'authority',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        authoritySuppressed = false;
        if (context.identityAccountPaths.contains('authority') &&
            context.identity != null) {
          authority = context.identity;
        }
    }
    SolsStreamAddress? config;
    var configSuppressed = false;
    switch (overrides.config) {
      case SolsStreamUseAccountOverride(:final address):
        config = address;
        configSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        configSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'config',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        configSuppressed = false;
        if (context.identityAccountPaths.contains('config') &&
            context.identity != null) {
          config = context.identity;
        }
    }
    SolsStreamAddress? systemProgram;
    var systemProgramSuppressed = false;
    switch (overrides.systemProgram) {
      case SolsStreamUseAccountOverride(:final address):
        systemProgram = address;
        systemProgramSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        systemProgramSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'system_program',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        systemProgramSuppressed = false;
        systemProgram = SolsStreamAddress.fromBase58(
          '11111111111111111111111111111111',
        );
    }
    for (var pass = 0; pass < 3; pass++) {
      var progressed = false;
      if (config == null && !configSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          final seeds = <Uint8List>[];
          seeds.add(Uint8List.fromList(<int>[99, 111, 110, 102, 105, 103]));
          for (var index = 0; index < seeds.length; index++) {
            if (seeds[index].length > 32) {
              throw SolsStreamPdaException(
                code: 'PDA_SEED_LENGTH',
                message: 'A PDA seed cannot exceed 32 bytes.',
                seedIndex: index,
              );
            }
          }
          final derived = await deriver.derive(
            programAddress: SolsStreamProgram.programAddress,
            seeds: seeds,
          );
          config = derived.address;
          progressed = true;
        }
      }
      if (config != null || configSuppressed) {
        break;
      }
      if (!progressed) {
        break;
      }
    }
    if (authority == null && !authoritySuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'authority',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (config == null && !configSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'config',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (systemProgram == null && !systemProgramSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'system_program',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamInitializeAccounts(
      authority: authority!,
      config: config!,
      systemProgram: systemProgram!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamInitializeRequest> prepare({
    required SolsStreamInitializeArgs args,
    SolsStreamInitializeAccountOverrides overrides =
        const SolsStreamInitializeAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamInitializeRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `join_room`.
final class SolsStreamJoinRoomAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamJoinRoomAccountOverrides({
    this.viewer = const SolsStreamAccountOverride.inherit(),
    this.viewerUser = const SolsStreamAccountOverride.inherit(),
    this.room = const SolsStreamAccountOverride.inherit(),
    this.hostUser = const SolsStreamAccountOverride.inherit(),
    this.config = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `viewer`.
  final SolsStreamAccountOverride viewer;

  /// Override for `viewer_user`.
  final SolsStreamAccountOverride viewerUser;

  /// Override for `room`.
  final SolsStreamAccountOverride room;

  /// Override for `host_user`.
  final SolsStreamAccountOverride hostUser;

  /// Override for `config`.
  final SolsStreamAccountOverride config;
}

/// Asynchronous resolver for `join_room` accounts.
final class SolsStreamJoinRoomAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamJoinRoomAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamJoinRoomAccounts> resolve({
    required SolsStreamJoinRoomArgs args,
    SolsStreamJoinRoomAccountOverrides overrides =
        const SolsStreamJoinRoomAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? viewer;
    var viewerSuppressed = false;
    switch (overrides.viewer) {
      case SolsStreamUseAccountOverride(:final address):
        viewer = address;
        viewerSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        viewerSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'viewer',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        viewerSuppressed = false;
        if (context.identityAccountPaths.contains('viewer') &&
            context.identity != null) {
          viewer = context.identity;
        }
    }
    SolsStreamAddress? viewerUser;
    var viewerUserSuppressed = false;
    switch (overrides.viewerUser) {
      case SolsStreamUseAccountOverride(:final address):
        viewerUser = address;
        viewerUserSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        viewerUserSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'viewer_user',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        viewerUserSuppressed = false;
        if (context.identityAccountPaths.contains('viewer_user') &&
            context.identity != null) {
          viewerUser = context.identity;
        }
    }
    SolsStreamAddress? room;
    var roomSuppressed = false;
    switch (overrides.room) {
      case SolsStreamUseAccountOverride(:final address):
        room = address;
        roomSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        roomSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'room',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        roomSuppressed = false;
        if (context.identityAccountPaths.contains('room') &&
            context.identity != null) {
          room = context.identity;
        }
    }
    SolsStreamAddress? hostUser;
    var hostUserSuppressed = false;
    switch (overrides.hostUser) {
      case SolsStreamUseAccountOverride(:final address):
        hostUser = address;
        hostUserSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        hostUserSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'host_user',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        hostUserSuppressed = false;
        if (context.identityAccountPaths.contains('host_user') &&
            context.identity != null) {
          hostUser = context.identity;
        }
    }
    SolsStreamAddress? config;
    var configSuppressed = false;
    switch (overrides.config) {
      case SolsStreamUseAccountOverride(:final address):
        config = address;
        configSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        configSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'config',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        configSuppressed = false;
        if (context.identityAccountPaths.contains('config') &&
            context.identity != null) {
          config = context.identity;
        }
    }
    for (var pass = 0; pass < 5; pass++) {
      var progressed = false;
      if (viewerUser == null && !viewerUserSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          if (viewer != null) {
            final seeds = <Uint8List>[];
            seeds.add(Uint8List.fromList(<int>[117, 115, 101, 114]));
            seeds.add(viewer.bytes);
            for (var index = 0; index < seeds.length; index++) {
              if (seeds[index].length > 32) {
                throw SolsStreamPdaException(
                  code: 'PDA_SEED_LENGTH',
                  message: 'A PDA seed cannot exceed 32 bytes.',
                  seedIndex: index,
                );
              }
            }
            final derived = await deriver.derive(
              programAddress: SolsStreamProgram.programAddress,
              seeds: seeds,
            );
            viewerUser = derived.address;
            progressed = true;
          }
        }
      }
      if (config == null && !configSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          final seeds = <Uint8List>[];
          seeds.add(Uint8List.fromList(<int>[99, 111, 110, 102, 105, 103]));
          for (var index = 0; index < seeds.length; index++) {
            if (seeds[index].length > 32) {
              throw SolsStreamPdaException(
                code: 'PDA_SEED_LENGTH',
                message: 'A PDA seed cannot exceed 32 bytes.',
                seedIndex: index,
              );
            }
          }
          final derived = await deriver.derive(
            programAddress: SolsStreamProgram.programAddress,
            seeds: seeds,
          );
          config = derived.address;
          progressed = true;
        }
      }
      if (viewerUser != null ||
          viewerUserSuppressed && config != null ||
          configSuppressed) {
        break;
      }
      if (!progressed) {
        break;
      }
    }
    if (viewer == null && !viewerSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'viewer',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (viewerUser == null && !viewerUserSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'viewer_user',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (room == null && !roomSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'room',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (hostUser == null && !hostUserSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'host_user',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (config == null && !configSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'config',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamJoinRoomAccounts(
      viewer: viewer!,
      viewerUser: viewerUser!,
      room: room!,
      hostUser: hostUser!,
      config: config!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamJoinRoomRequest> prepare({
    required SolsStreamJoinRoomArgs args,
    SolsStreamJoinRoomAccountOverrides overrides =
        const SolsStreamJoinRoomAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamJoinRoomRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `leave_room`.
final class SolsStreamLeaveRoomAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamLeaveRoomAccountOverrides({
    this.viewer = const SolsStreamAccountOverride.inherit(),
    this.viewerUser = const SolsStreamAccountOverride.inherit(),
    this.room = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `viewer`.
  final SolsStreamAccountOverride viewer;

  /// Override for `viewer_user`.
  final SolsStreamAccountOverride viewerUser;

  /// Override for `room`.
  final SolsStreamAccountOverride room;
}

/// Asynchronous resolver for `leave_room` accounts.
final class SolsStreamLeaveRoomAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamLeaveRoomAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamLeaveRoomAccounts> resolve({
    required SolsStreamLeaveRoomArgs args,
    SolsStreamLeaveRoomAccountOverrides overrides =
        const SolsStreamLeaveRoomAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? viewer;
    var viewerSuppressed = false;
    switch (overrides.viewer) {
      case SolsStreamUseAccountOverride(:final address):
        viewer = address;
        viewerSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        viewerSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'viewer',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        viewerSuppressed = false;
        if (context.identityAccountPaths.contains('viewer') &&
            context.identity != null) {
          viewer = context.identity;
        }
    }
    SolsStreamAddress? viewerUser;
    var viewerUserSuppressed = false;
    switch (overrides.viewerUser) {
      case SolsStreamUseAccountOverride(:final address):
        viewerUser = address;
        viewerUserSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        viewerUserSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'viewer_user',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        viewerUserSuppressed = false;
        if (context.identityAccountPaths.contains('viewer_user') &&
            context.identity != null) {
          viewerUser = context.identity;
        }
    }
    SolsStreamAddress? room;
    var roomSuppressed = false;
    switch (overrides.room) {
      case SolsStreamUseAccountOverride(:final address):
        room = address;
        roomSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        roomSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'room',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        roomSuppressed = false;
        if (context.identityAccountPaths.contains('room') &&
            context.identity != null) {
          room = context.identity;
        }
    }
    for (var pass = 0; pass < 3; pass++) {
      var progressed = false;
      if (viewerUser == null && !viewerUserSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          if (viewer != null) {
            final seeds = <Uint8List>[];
            seeds.add(Uint8List.fromList(<int>[117, 115, 101, 114]));
            seeds.add(viewer.bytes);
            for (var index = 0; index < seeds.length; index++) {
              if (seeds[index].length > 32) {
                throw SolsStreamPdaException(
                  code: 'PDA_SEED_LENGTH',
                  message: 'A PDA seed cannot exceed 32 bytes.',
                  seedIndex: index,
                );
              }
            }
            final derived = await deriver.derive(
              programAddress: SolsStreamProgram.programAddress,
              seeds: seeds,
            );
            viewerUser = derived.address;
            progressed = true;
          }
        }
      }
      if (viewerUser != null || viewerUserSuppressed) {
        break;
      }
      if (!progressed) {
        break;
      }
    }
    if (viewer == null && !viewerSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'viewer',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (viewerUser == null && !viewerUserSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'viewer_user',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (room == null && !roomSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'room',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamLeaveRoomAccounts(
      viewer: viewer!,
      viewerUser: viewerUser!,
      room: room!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamLeaveRoomRequest> prepare({
    required SolsStreamLeaveRoomArgs args,
    SolsStreamLeaveRoomAccountOverrides overrides =
        const SolsStreamLeaveRoomAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamLeaveRoomRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `open_connect_slot`.
final class SolsStreamOpenConnectSlotAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamOpenConnectSlotAccountOverrides({
    this.host = const SolsStreamAccountOverride.inherit(),
    this.room = const SolsStreamAccountOverride.inherit(),
    this.slot = const SolsStreamAccountOverride.inherit(),
    this.systemProgram = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `host`.
  final SolsStreamAccountOverride host;

  /// Override for `room`.
  final SolsStreamAccountOverride room;

  /// Override for `slot`.
  final SolsStreamAccountOverride slot;

  /// Override for `system_program`.
  final SolsStreamAccountOverride systemProgram;
}

/// Asynchronous resolver for `open_connect_slot` accounts.
final class SolsStreamOpenConnectSlotAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamOpenConnectSlotAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamOpenConnectSlotAccounts> resolve({
    required SolsStreamOpenConnectSlotArgs args,
    SolsStreamOpenConnectSlotAccountOverrides overrides =
        const SolsStreamOpenConnectSlotAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? host;
    var hostSuppressed = false;
    switch (overrides.host) {
      case SolsStreamUseAccountOverride(:final address):
        host = address;
        hostSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        hostSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'host',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        hostSuppressed = false;
        if (context.identityAccountPaths.contains('host') &&
            context.identity != null) {
          host = context.identity;
        }
    }
    SolsStreamAddress? room;
    var roomSuppressed = false;
    switch (overrides.room) {
      case SolsStreamUseAccountOverride(:final address):
        room = address;
        roomSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        roomSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'room',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        roomSuppressed = false;
        if (context.identityAccountPaths.contains('room') &&
            context.identity != null) {
          room = context.identity;
        }
    }
    SolsStreamAddress? slot;
    var slotSuppressed = false;
    switch (overrides.slot) {
      case SolsStreamUseAccountOverride(:final address):
        slot = address;
        slotSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        slotSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'slot',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        slotSuppressed = false;
        if (context.identityAccountPaths.contains('slot') &&
            context.identity != null) {
          slot = context.identity;
        }
    }
    SolsStreamAddress? systemProgram;
    var systemProgramSuppressed = false;
    switch (overrides.systemProgram) {
      case SolsStreamUseAccountOverride(:final address):
        systemProgram = address;
        systemProgramSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        systemProgramSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'system_program',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        systemProgramSuppressed = false;
        systemProgram = SolsStreamAddress.fromBase58(
          '11111111111111111111111111111111',
        );
    }
    for (var pass = 0; pass < 4; pass++) {
      var progressed = false;
      if (slot == null && !slotSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          if (room != null) {
            final seeds = <Uint8List>[];
            seeds.add(Uint8List.fromList(<int>[115, 108, 111, 116]));
            seeds.add(room.bytes);
            final seedWriter2 = SolsStreamBorshWriter();
            seedWriter2.writeUnsigned(args.slotNonce, 8);
            seeds.add(seedWriter2.takeBytes());
            for (var index = 0; index < seeds.length; index++) {
              if (seeds[index].length > 32) {
                throw SolsStreamPdaException(
                  code: 'PDA_SEED_LENGTH',
                  message: 'A PDA seed cannot exceed 32 bytes.',
                  seedIndex: index,
                );
              }
            }
            final derived = await deriver.derive(
              programAddress: SolsStreamProgram.programAddress,
              seeds: seeds,
            );
            slot = derived.address;
            progressed = true;
          }
        }
      }
      if (slot != null || slotSuppressed) {
        break;
      }
      if (!progressed) {
        break;
      }
    }
    if (host == null && !hostSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'host',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (room == null && !roomSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'room',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (slot == null && !slotSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'slot',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (systemProgram == null && !systemProgramSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'system_program',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamOpenConnectSlotAccounts(
      host: host!,
      room: room!,
      slot: slot!,
      systemProgram: systemProgram!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamOpenConnectSlotRequest> prepare({
    required SolsStreamOpenConnectSlotArgs args,
    SolsStreamOpenConnectSlotAccountOverrides overrides =
        const SolsStreamOpenConnectSlotAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamOpenConnectSlotRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `open_relay_slot`.
final class SolsStreamOpenRelaySlotAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamOpenRelaySlotAccountOverrides({
    this.relay = const SolsStreamAccountOverride.inherit(),
    this.relayUser = const SolsStreamAccountOverride.inherit(),
    this.room = const SolsStreamAccountOverride.inherit(),
    this.slot = const SolsStreamAccountOverride.inherit(),
    this.systemProgram = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `relay`.
  final SolsStreamAccountOverride relay;

  /// Override for `relay_user`.
  final SolsStreamAccountOverride relayUser;

  /// Override for `room`.
  final SolsStreamAccountOverride room;

  /// Override for `slot`.
  final SolsStreamAccountOverride slot;

  /// Override for `system_program`.
  final SolsStreamAccountOverride systemProgram;
}

/// Asynchronous resolver for `open_relay_slot` accounts.
final class SolsStreamOpenRelaySlotAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamOpenRelaySlotAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamOpenRelaySlotAccounts> resolve({
    required SolsStreamOpenRelaySlotArgs args,
    SolsStreamOpenRelaySlotAccountOverrides overrides =
        const SolsStreamOpenRelaySlotAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? relay;
    var relaySuppressed = false;
    switch (overrides.relay) {
      case SolsStreamUseAccountOverride(:final address):
        relay = address;
        relaySuppressed = false;
      case SolsStreamAbsentAccountOverride():
        relaySuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'relay',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        relaySuppressed = false;
        if (context.identityAccountPaths.contains('relay') &&
            context.identity != null) {
          relay = context.identity;
        }
    }
    SolsStreamAddress? relayUser;
    var relayUserSuppressed = false;
    switch (overrides.relayUser) {
      case SolsStreamUseAccountOverride(:final address):
        relayUser = address;
        relayUserSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        relayUserSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'relay_user',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        relayUserSuppressed = false;
        if (context.identityAccountPaths.contains('relay_user') &&
            context.identity != null) {
          relayUser = context.identity;
        }
    }
    SolsStreamAddress? room;
    var roomSuppressed = false;
    switch (overrides.room) {
      case SolsStreamUseAccountOverride(:final address):
        room = address;
        roomSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        roomSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'room',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        roomSuppressed = false;
        if (context.identityAccountPaths.contains('room') &&
            context.identity != null) {
          room = context.identity;
        }
    }
    SolsStreamAddress? slot;
    var slotSuppressed = false;
    switch (overrides.slot) {
      case SolsStreamUseAccountOverride(:final address):
        slot = address;
        slotSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        slotSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'slot',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        slotSuppressed = false;
        if (context.identityAccountPaths.contains('slot') &&
            context.identity != null) {
          slot = context.identity;
        }
    }
    SolsStreamAddress? systemProgram;
    var systemProgramSuppressed = false;
    switch (overrides.systemProgram) {
      case SolsStreamUseAccountOverride(:final address):
        systemProgram = address;
        systemProgramSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        systemProgramSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'system_program',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        systemProgramSuppressed = false;
        systemProgram = SolsStreamAddress.fromBase58(
          '11111111111111111111111111111111',
        );
    }
    for (var pass = 0; pass < 5; pass++) {
      var progressed = false;
      if (relayUser == null && !relayUserSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          if (relay != null) {
            final seeds = <Uint8List>[];
            seeds.add(Uint8List.fromList(<int>[117, 115, 101, 114]));
            seeds.add(relay.bytes);
            for (var index = 0; index < seeds.length; index++) {
              if (seeds[index].length > 32) {
                throw SolsStreamPdaException(
                  code: 'PDA_SEED_LENGTH',
                  message: 'A PDA seed cannot exceed 32 bytes.',
                  seedIndex: index,
                );
              }
            }
            final derived = await deriver.derive(
              programAddress: SolsStreamProgram.programAddress,
              seeds: seeds,
            );
            relayUser = derived.address;
            progressed = true;
          }
        }
      }
      if (slot == null && !slotSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          if (room != null) {
            final seeds = <Uint8List>[];
            seeds.add(Uint8List.fromList(<int>[115, 108, 111, 116]));
            seeds.add(room.bytes);
            final seedWriter4 = SolsStreamBorshWriter();
            seedWriter4.writeUnsigned(args.slotNonce, 8);
            seeds.add(seedWriter4.takeBytes());
            for (var index = 0; index < seeds.length; index++) {
              if (seeds[index].length > 32) {
                throw SolsStreamPdaException(
                  code: 'PDA_SEED_LENGTH',
                  message: 'A PDA seed cannot exceed 32 bytes.',
                  seedIndex: index,
                );
              }
            }
            final derived = await deriver.derive(
              programAddress: SolsStreamProgram.programAddress,
              seeds: seeds,
            );
            slot = derived.address;
            progressed = true;
          }
        }
      }
      if (relayUser != null ||
          relayUserSuppressed && slot != null ||
          slotSuppressed) {
        break;
      }
      if (!progressed) {
        break;
      }
    }
    if (relay == null && !relaySuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'relay',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (relayUser == null && !relayUserSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'relay_user',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (room == null && !roomSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'room',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (slot == null && !slotSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'slot',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (systemProgram == null && !systemProgramSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'system_program',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamOpenRelaySlotAccounts(
      relay: relay!,
      relayUser: relayUser!,
      room: room!,
      slot: slot!,
      systemProgram: systemProgram!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamOpenRelaySlotRequest> prepare({
    required SolsStreamOpenRelaySlotArgs args,
    SolsStreamOpenRelaySlotAccountOverrides overrides =
        const SolsStreamOpenRelaySlotAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamOpenRelaySlotRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `post_memo`.
final class SolsStreamPostMemoAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamPostMemoAccountOverrides({
    this.sender = const SolsStreamAccountOverride.inherit(),
    this.serviceWallet = const SolsStreamAccountOverride.inherit(),
    this.config = const SolsStreamAccountOverride.inherit(),
    this.systemProgram = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `sender`.
  final SolsStreamAccountOverride sender;

  /// Override for `service_wallet`.
  final SolsStreamAccountOverride serviceWallet;

  /// Override for `config`.
  final SolsStreamAccountOverride config;

  /// Override for `system_program`.
  final SolsStreamAccountOverride systemProgram;
}

/// Asynchronous resolver for `post_memo` accounts.
final class SolsStreamPostMemoAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamPostMemoAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamPostMemoAccounts> resolve({
    required SolsStreamPostMemoArgs args,
    SolsStreamPostMemoAccountOverrides overrides =
        const SolsStreamPostMemoAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? sender;
    var senderSuppressed = false;
    switch (overrides.sender) {
      case SolsStreamUseAccountOverride(:final address):
        sender = address;
        senderSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        senderSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'sender',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        senderSuppressed = false;
        if (context.identityAccountPaths.contains('sender') &&
            context.identity != null) {
          sender = context.identity;
        }
    }
    SolsStreamAddress? serviceWallet;
    var serviceWalletSuppressed = false;
    switch (overrides.serviceWallet) {
      case SolsStreamUseAccountOverride(:final address):
        serviceWallet = address;
        serviceWalletSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        serviceWalletSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'service_wallet',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        serviceWalletSuppressed = false;
        if (context.identityAccountPaths.contains('service_wallet') &&
            context.identity != null) {
          serviceWallet = context.identity;
        }
    }
    SolsStreamAddress? config;
    var configSuppressed = false;
    switch (overrides.config) {
      case SolsStreamUseAccountOverride(:final address):
        config = address;
        configSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        configSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'config',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        configSuppressed = false;
        if (context.identityAccountPaths.contains('config') &&
            context.identity != null) {
          config = context.identity;
        }
    }
    SolsStreamAddress? systemProgram;
    var systemProgramSuppressed = false;
    switch (overrides.systemProgram) {
      case SolsStreamUseAccountOverride(:final address):
        systemProgram = address;
        systemProgramSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        systemProgramSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'system_program',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        systemProgramSuppressed = false;
        systemProgram = SolsStreamAddress.fromBase58(
          '11111111111111111111111111111111',
        );
    }
    for (var pass = 0; pass < 4; pass++) {
      var progressed = false;
      if (config == null && !configSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          final seeds = <Uint8List>[];
          seeds.add(Uint8List.fromList(<int>[99, 111, 110, 102, 105, 103]));
          for (var index = 0; index < seeds.length; index++) {
            if (seeds[index].length > 32) {
              throw SolsStreamPdaException(
                code: 'PDA_SEED_LENGTH',
                message: 'A PDA seed cannot exceed 32 bytes.',
                seedIndex: index,
              );
            }
          }
          final derived = await deriver.derive(
            programAddress: SolsStreamProgram.programAddress,
            seeds: seeds,
          );
          config = derived.address;
          progressed = true;
        }
      }
      if (config != null || configSuppressed) {
        break;
      }
      if (!progressed) {
        break;
      }
    }
    if (sender == null && !senderSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'sender',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (serviceWallet == null && !serviceWalletSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'service_wallet',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (config == null && !configSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'config',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (systemProgram == null && !systemProgramSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'system_program',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamPostMemoAccounts(
      sender: sender!,
      serviceWallet: serviceWallet!,
      config: config!,
      systemProgram: systemProgram!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamPostMemoRequest> prepare({
    required SolsStreamPostMemoArgs args,
    SolsStreamPostMemoAccountOverrides overrides =
        const SolsStreamPostMemoAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamPostMemoRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `purchase_turn`.
final class SolsStreamPurchaseTurnAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamPurchaseTurnAccountOverrides({
    this.buyer = const SolsStreamAccountOverride.inherit(),
    this.buyerUser = const SolsStreamAccountOverride.inherit(),
    this.serviceWallet = const SolsStreamAccountOverride.inherit(),
    this.config = const SolsStreamAccountOverride.inherit(),
    this.systemProgram = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `buyer`.
  final SolsStreamAccountOverride buyer;

  /// Override for `buyer_user`.
  final SolsStreamAccountOverride buyerUser;

  /// Override for `service_wallet`.
  final SolsStreamAccountOverride serviceWallet;

  /// Override for `config`.
  final SolsStreamAccountOverride config;

  /// Override for `system_program`.
  final SolsStreamAccountOverride systemProgram;
}

/// Asynchronous resolver for `purchase_turn` accounts.
final class SolsStreamPurchaseTurnAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamPurchaseTurnAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamPurchaseTurnAccounts> resolve({
    required SolsStreamPurchaseTurnArgs args,
    SolsStreamPurchaseTurnAccountOverrides overrides =
        const SolsStreamPurchaseTurnAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? buyer;
    var buyerSuppressed = false;
    switch (overrides.buyer) {
      case SolsStreamUseAccountOverride(:final address):
        buyer = address;
        buyerSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        buyerSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'buyer',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        buyerSuppressed = false;
        if (context.identityAccountPaths.contains('buyer') &&
            context.identity != null) {
          buyer = context.identity;
        }
    }
    SolsStreamAddress? buyerUser;
    var buyerUserSuppressed = false;
    switch (overrides.buyerUser) {
      case SolsStreamUseAccountOverride(:final address):
        buyerUser = address;
        buyerUserSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        buyerUserSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'buyer_user',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        buyerUserSuppressed = false;
        if (context.identityAccountPaths.contains('buyer_user') &&
            context.identity != null) {
          buyerUser = context.identity;
        }
    }
    SolsStreamAddress? serviceWallet;
    var serviceWalletSuppressed = false;
    switch (overrides.serviceWallet) {
      case SolsStreamUseAccountOverride(:final address):
        serviceWallet = address;
        serviceWalletSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        serviceWalletSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'service_wallet',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        serviceWalletSuppressed = false;
        if (context.identityAccountPaths.contains('service_wallet') &&
            context.identity != null) {
          serviceWallet = context.identity;
        }
    }
    SolsStreamAddress? config;
    var configSuppressed = false;
    switch (overrides.config) {
      case SolsStreamUseAccountOverride(:final address):
        config = address;
        configSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        configSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'config',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        configSuppressed = false;
        if (context.identityAccountPaths.contains('config') &&
            context.identity != null) {
          config = context.identity;
        }
    }
    SolsStreamAddress? systemProgram;
    var systemProgramSuppressed = false;
    switch (overrides.systemProgram) {
      case SolsStreamUseAccountOverride(:final address):
        systemProgram = address;
        systemProgramSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        systemProgramSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'system_program',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        systemProgramSuppressed = false;
        systemProgram = SolsStreamAddress.fromBase58(
          '11111111111111111111111111111111',
        );
    }
    for (var pass = 0; pass < 5; pass++) {
      var progressed = false;
      if (buyerUser == null && !buyerUserSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          if (buyer != null) {
            final seeds = <Uint8List>[];
            seeds.add(Uint8List.fromList(<int>[117, 115, 101, 114]));
            seeds.add(buyer.bytes);
            for (var index = 0; index < seeds.length; index++) {
              if (seeds[index].length > 32) {
                throw SolsStreamPdaException(
                  code: 'PDA_SEED_LENGTH',
                  message: 'A PDA seed cannot exceed 32 bytes.',
                  seedIndex: index,
                );
              }
            }
            final derived = await deriver.derive(
              programAddress: SolsStreamProgram.programAddress,
              seeds: seeds,
            );
            buyerUser = derived.address;
            progressed = true;
          }
        }
      }
      if (config == null && !configSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          final seeds = <Uint8List>[];
          seeds.add(Uint8List.fromList(<int>[99, 111, 110, 102, 105, 103]));
          for (var index = 0; index < seeds.length; index++) {
            if (seeds[index].length > 32) {
              throw SolsStreamPdaException(
                code: 'PDA_SEED_LENGTH',
                message: 'A PDA seed cannot exceed 32 bytes.',
                seedIndex: index,
              );
            }
          }
          final derived = await deriver.derive(
            programAddress: SolsStreamProgram.programAddress,
            seeds: seeds,
          );
          config = derived.address;
          progressed = true;
        }
      }
      if (buyerUser != null ||
          buyerUserSuppressed && config != null ||
          configSuppressed) {
        break;
      }
      if (!progressed) {
        break;
      }
    }
    if (buyer == null && !buyerSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'buyer',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (buyerUser == null && !buyerUserSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'buyer_user',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (serviceWallet == null && !serviceWalletSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'service_wallet',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (config == null && !configSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'config',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (systemProgram == null && !systemProgramSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'system_program',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamPurchaseTurnAccounts(
      buyer: buyer!,
      buyerUser: buyerUser!,
      serviceWallet: serviceWallet!,
      config: config!,
      systemProgram: systemProgram!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamPurchaseTurnRequest> prepare({
    required SolsStreamPurchaseTurnArgs args,
    SolsStreamPurchaseTurnAccountOverrides overrides =
        const SolsStreamPurchaseTurnAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamPurchaseTurnRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `update_config`.
final class SolsStreamUpdateConfigAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamUpdateConfigAccountOverrides({
    this.authority = const SolsStreamAccountOverride.inherit(),
    this.config = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `authority`.
  final SolsStreamAccountOverride authority;

  /// Override for `config`.
  final SolsStreamAccountOverride config;
}

/// Asynchronous resolver for `update_config` accounts.
final class SolsStreamUpdateConfigAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamUpdateConfigAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamUpdateConfigAccounts> resolve({
    required SolsStreamUpdateConfigArgs args,
    SolsStreamUpdateConfigAccountOverrides overrides =
        const SolsStreamUpdateConfigAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? authority;
    var authoritySuppressed = false;
    switch (overrides.authority) {
      case SolsStreamUseAccountOverride(:final address):
        authority = address;
        authoritySuppressed = false;
      case SolsStreamAbsentAccountOverride():
        authoritySuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'authority',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        authoritySuppressed = false;
        if (context.identityAccountPaths.contains('authority') &&
            context.identity != null) {
          authority = context.identity;
        }
    }
    SolsStreamAddress? config;
    var configSuppressed = false;
    switch (overrides.config) {
      case SolsStreamUseAccountOverride(:final address):
        config = address;
        configSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        configSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'config',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        configSuppressed = false;
        if (context.identityAccountPaths.contains('config') &&
            context.identity != null) {
          config = context.identity;
        }
    }
    for (var pass = 0; pass < 2; pass++) {
      var progressed = false;
      if (authority == null && !authoritySuppressed) {
        final relationResolver = context.relationResolver;
        if (relationResolver != null) {
          if (authority == null) {
            final authorityRelation0 = await relationResolver.resolveRelation(
              accountPath: 'authority',
              relationPath: 'config',
              resolvedAccounts: {
                if (authority != null) 'authority': authority,
                if (config != null) 'config': config,
              },
            );
            if (authorityRelation0 != null) {
              authority = authorityRelation0;
              progressed = true;
            }
          }
        }
      }
      if (config == null && !configSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          final seeds = <Uint8List>[];
          seeds.add(Uint8List.fromList(<int>[99, 111, 110, 102, 105, 103]));
          for (var index = 0; index < seeds.length; index++) {
            if (seeds[index].length > 32) {
              throw SolsStreamPdaException(
                code: 'PDA_SEED_LENGTH',
                message: 'A PDA seed cannot exceed 32 bytes.',
                seedIndex: index,
              );
            }
          }
          final derived = await deriver.derive(
            programAddress: SolsStreamProgram.programAddress,
            seeds: seeds,
          );
          config = derived.address;
          progressed = true;
        }
      }
      if (authority != null ||
          authoritySuppressed && config != null ||
          configSuppressed) {
        break;
      }
      if (!progressed) {
        break;
      }
    }
    if (authority == null && !authoritySuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'authority',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (config == null && !configSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'config',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamUpdateConfigAccounts(
      authority: authority!,
      config: config!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamUpdateConfigRequest> prepare({
    required SolsStreamUpdateConfigArgs args,
    SolsStreamUpdateConfigAccountOverrides overrides =
        const SolsStreamUpdateConfigAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamUpdateConfigRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `update_profile`.
final class SolsStreamUpdateProfileAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamUpdateProfileAccountOverrides({
    this.authority = const SolsStreamAccountOverride.inherit(),
    this.user = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `authority`.
  final SolsStreamAccountOverride authority;

  /// Override for `user`.
  final SolsStreamAccountOverride user;
}

/// Asynchronous resolver for `update_profile` accounts.
final class SolsStreamUpdateProfileAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamUpdateProfileAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamUpdateProfileAccounts> resolve({
    required SolsStreamUpdateProfileArgs args,
    SolsStreamUpdateProfileAccountOverrides overrides =
        const SolsStreamUpdateProfileAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? authority;
    var authoritySuppressed = false;
    switch (overrides.authority) {
      case SolsStreamUseAccountOverride(:final address):
        authority = address;
        authoritySuppressed = false;
      case SolsStreamAbsentAccountOverride():
        authoritySuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'authority',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        authoritySuppressed = false;
        if (context.identityAccountPaths.contains('authority') &&
            context.identity != null) {
          authority = context.identity;
        }
    }
    SolsStreamAddress? user;
    var userSuppressed = false;
    switch (overrides.user) {
      case SolsStreamUseAccountOverride(:final address):
        user = address;
        userSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        userSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'user',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        userSuppressed = false;
        if (context.identityAccountPaths.contains('user') &&
            context.identity != null) {
          user = context.identity;
        }
    }
    for (var pass = 0; pass < 2; pass++) {
      var progressed = false;
      if (authority == null && !authoritySuppressed) {
        final relationResolver = context.relationResolver;
        if (relationResolver != null) {
          if (authority == null) {
            final authorityRelation0 = await relationResolver.resolveRelation(
              accountPath: 'authority',
              relationPath: 'user',
              resolvedAccounts: {
                if (authority != null) 'authority': authority,
                if (user != null) 'user': user,
              },
            );
            if (authorityRelation0 != null) {
              authority = authorityRelation0;
              progressed = true;
            }
          }
        }
      }
      if (user == null && !userSuppressed) {
        final deriver = context.pdaDeriver;
        if (deriver != null) {
          if (authority != null) {
            final seeds = <Uint8List>[];
            seeds.add(Uint8List.fromList(<int>[117, 115, 101, 114]));
            seeds.add(authority.bytes);
            for (var index = 0; index < seeds.length; index++) {
              if (seeds[index].length > 32) {
                throw SolsStreamPdaException(
                  code: 'PDA_SEED_LENGTH',
                  message: 'A PDA seed cannot exceed 32 bytes.',
                  seedIndex: index,
                );
              }
            }
            final derived = await deriver.derive(
              programAddress: SolsStreamProgram.programAddress,
              seeds: seeds,
            );
            user = derived.address;
            progressed = true;
          }
        }
      }
      if (authority != null ||
          authoritySuppressed && user != null ||
          userSuppressed) {
        break;
      }
      if (!progressed) {
        break;
      }
    }
    if (authority == null && !authoritySuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'authority',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (user == null && !userSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'user',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamUpdateProfileAccounts(authority: authority!, user: user!);
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamUpdateProfileRequest> prepare({
    required SolsStreamUpdateProfileArgs args,
    SolsStreamUpdateProfileAccountOverrides overrides =
        const SolsStreamUpdateProfileAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamUpdateProfileRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `write_answer`.
final class SolsStreamWriteAnswerAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamWriteAnswerAccountOverrides({
    this.viewer = const SolsStreamAccountOverride.inherit(),
    this.slot = const SolsStreamAccountOverride.inherit(),
    this.systemProgram = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `viewer`.
  final SolsStreamAccountOverride viewer;

  /// Override for `slot`.
  final SolsStreamAccountOverride slot;

  /// Override for `system_program`.
  final SolsStreamAccountOverride systemProgram;
}

/// Asynchronous resolver for `write_answer` accounts.
final class SolsStreamWriteAnswerAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamWriteAnswerAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamWriteAnswerAccounts> resolve({
    required SolsStreamWriteAnswerArgs args,
    SolsStreamWriteAnswerAccountOverrides overrides =
        const SolsStreamWriteAnswerAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? viewer;
    var viewerSuppressed = false;
    switch (overrides.viewer) {
      case SolsStreamUseAccountOverride(:final address):
        viewer = address;
        viewerSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        viewerSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'viewer',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        viewerSuppressed = false;
        if (context.identityAccountPaths.contains('viewer') &&
            context.identity != null) {
          viewer = context.identity;
        }
    }
    SolsStreamAddress? slot;
    var slotSuppressed = false;
    switch (overrides.slot) {
      case SolsStreamUseAccountOverride(:final address):
        slot = address;
        slotSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        slotSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'slot',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        slotSuppressed = false;
        if (context.identityAccountPaths.contains('slot') &&
            context.identity != null) {
          slot = context.identity;
        }
    }
    SolsStreamAddress? systemProgram;
    var systemProgramSuppressed = false;
    switch (overrides.systemProgram) {
      case SolsStreamUseAccountOverride(:final address):
        systemProgram = address;
        systemProgramSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        systemProgramSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'system_program',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        systemProgramSuppressed = false;
        systemProgram = SolsStreamAddress.fromBase58(
          '11111111111111111111111111111111',
        );
    }
    if (viewer == null && !viewerSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'viewer',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (slot == null && !slotSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'slot',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (systemProgram == null && !systemProgramSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'system_program',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamWriteAnswerAccounts(
      viewer: viewer!,
      slot: slot!,
      systemProgram: systemProgram!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamWriteAnswerRequest> prepare({
    required SolsStreamWriteAnswerArgs args,
    SolsStreamWriteAnswerAccountOverrides overrides =
        const SolsStreamWriteAnswerAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamWriteAnswerRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}

/// Typed account overrides for `write_offer`.
final class SolsStreamWriteOfferAccountOverrides {
  /// Creates override states; every field inherits by default.
  const SolsStreamWriteOfferAccountOverrides({
    this.host = const SolsStreamAccountOverride.inherit(),
    this.slot = const SolsStreamAccountOverride.inherit(),
    this.systemProgram = const SolsStreamAccountOverride.inherit(),
  });

  /// Override for `host`.
  final SolsStreamAccountOverride host;

  /// Override for `slot`.
  final SolsStreamAccountOverride slot;

  /// Override for `system_program`.
  final SolsStreamAccountOverride systemProgram;
}

/// Asynchronous resolver for `write_offer` accounts.
final class SolsStreamWriteOfferAccountResolver {
  /// Creates a resolver from injected capabilities.
  const SolsStreamWriteOfferAccountResolver(this.context);

  /// Resolution dependencies.
  final SolsStreamResolutionContext context;

  /// Resolves overrides, fixed addresses, identity, PDA, and relations.
  /// Precedence is use override, absent override, fixed address, identity, PDA, then relation.
  /// Relation/PDA cycles must be broken by use overrides, identity, or a relation resolver.
  Future<SolsStreamWriteOfferAccounts> resolve({
    required SolsStreamWriteOfferArgs args,
    SolsStreamWriteOfferAccountOverrides overrides =
        const SolsStreamWriteOfferAccountOverrides(),
  }) async {
    final causes = <SolsStreamAccountResolutionCause>[];
    SolsStreamAddress? host;
    var hostSuppressed = false;
    switch (overrides.host) {
      case SolsStreamUseAccountOverride(:final address):
        host = address;
        hostSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        hostSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'host',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        hostSuppressed = false;
        if (context.identityAccountPaths.contains('host') &&
            context.identity != null) {
          host = context.identity;
        }
    }
    SolsStreamAddress? slot;
    var slotSuppressed = false;
    switch (overrides.slot) {
      case SolsStreamUseAccountOverride(:final address):
        slot = address;
        slotSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        slotSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'slot',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        slotSuppressed = false;
        if (context.identityAccountPaths.contains('slot') &&
            context.identity != null) {
          slot = context.identity;
        }
    }
    SolsStreamAddress? systemProgram;
    var systemProgramSuppressed = false;
    switch (overrides.systemProgram) {
      case SolsStreamUseAccountOverride(:final address):
        systemProgram = address;
        systemProgramSuppressed = false;
      case SolsStreamAbsentAccountOverride():
        systemProgramSuppressed = true;
        causes.add(
          const SolsStreamAccountResolutionCause(
            path: 'system_program',
            code: 'RESOLUTION_REQUIRED_ABSENT',
            message: 'Required account cannot be absent.',
          ),
        );
      case SolsStreamInheritAccountOverride():
        systemProgramSuppressed = false;
        systemProgram = SolsStreamAddress.fromBase58(
          '11111111111111111111111111111111',
        );
    }
    if (host == null && !hostSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'host',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (slot == null && !slotSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'slot',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (systemProgram == null && !systemProgramSuppressed) {
      causes.add(
        const SolsStreamAccountResolutionCause(
          path: 'system_program',
          code: 'RESOLUTION_UNRESOLVED',
          message: 'No override, fixed address, allowed identity, PDA, or relation resolved this account.',
        ),
      );
    }
    if (causes.isNotEmpty) {
      throw SolsStreamAccountResolutionException(causes);
    }
    return SolsStreamWriteOfferAccounts(
      host: host!,
      slot: slot!,
      systemProgram: systemProgram!,
    );
  }

  /// Resolves accounts and constructs an immutable instruction request.
  Future<SolsStreamWriteOfferRequest> prepare({
    required SolsStreamWriteOfferArgs args,
    SolsStreamWriteOfferAccountOverrides overrides =
        const SolsStreamWriteOfferAccountOverrides(),
    List<SolsStreamAccountMeta> remainingAccounts = const [],
  }) async => SolsStreamWriteOfferRequest(
    args: args,
    accounts: await resolve(args: args, overrides: overrides),
    remainingAccounts: remainingAccounts,
  );
}
