// GENERATED CODE - DO NOT MODIFY BY HAND.
// tool: solana_idl_codegen
// generator-version: 0.2.0
// source-sha256: e967590f776990a88746c52fff70bb1e412706ceefa537870b711bb1dfe2279d
// semantic-ir-sha256: 06de736cba994a28c486121c3344a50591093167febb525a8227d85946d809fe
// SPDX-License-Identifier: MIT
/// Generated account API for `sols_stream`.
library;

import 'sols_stream_solana_support.dart';
import 'sols_stream_solana_types.dart';

/// Decoder and discriminator metadata for `SolsStreamConnectSlot` accounts.
abstract final class SolsStreamConnectSlotAccount {
  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    97,
    222,
    119,
    195,
    143,
    47,
    180,
    127,
  ]);

  /// IDL account name.
  static const String name = 'ConnectSlot';

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only account metadata.
  static final SolsStreamAccountMetadata metadata = SolsStreamAccountMetadata(
    name: name,
    discriminator: discriminator,
  );

  /// Decodes account data or returns `null` on discriminator mismatch.
  static SolsStreamConnectSlot? tryDecodeAccount(
    List<int> data, {
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) {
    if (!_hasDiscriminator(data)) {
      return null;
    }
    return SolsStreamConnectSlot.codec
        .decodePrefix(data.sublist(discriminator.length), limits: limits)
        .value;
  }

  /// Decodes account data and permits trailing allocation padding.
  static SolsStreamConnectSlot decodeAccount(
    List<int> data, {
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) {
    _verifyDiscriminator(data);
    return SolsStreamConnectSlot.codec
        .decodePrefix(data.sublist(discriminator.length), limits: limits)
        .value;
  }

  /// Decodes account data and rejects trailing bytes.
  static SolsStreamConnectSlot decodeAccountExact(
    List<int> data, {
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) {
    _verifyDiscriminator(data);
    return SolsStreamConnectSlot.codec.decodeExact(
      data.sublist(discriminator.length),
      limits: limits,
    );
  }

  static void _verifyDiscriminator(List<int> data) {
    if (data.length < discriminator.length) {
      throw FormatException('Account data is shorter than its discriminator.');
    }
    if (!_hasDiscriminator(data)) {
      throw FormatException('Account discriminator mismatch.');
    }
  }

  static bool _hasDiscriminator(List<int> data) {
    if (data.length < discriminator.length) {
      return false;
    }
    for (var index = 0; index < discriminator.length; index++) {
      if (data[index] != discriminator[index]) {
        return false;
      }
    }
    return true;
  }
}

/// Decoder and discriminator metadata for `SolsStreamProgramConfig` accounts.
abstract final class SolsStreamProgramConfigAccount {
  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    196,
    210,
    90,
    231,
    144,
    149,
    140,
    63,
  ]);

  /// IDL account name.
  static const String name = 'ProgramConfig';

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only account metadata.
  static final SolsStreamAccountMetadata metadata = SolsStreamAccountMetadata(
    name: name,
    discriminator: discriminator,
  );

  /// Decodes account data or returns `null` on discriminator mismatch.
  static SolsStreamProgramConfig? tryDecodeAccount(
    List<int> data, {
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) {
    if (!_hasDiscriminator(data)) {
      return null;
    }
    return SolsStreamProgramConfig.codec
        .decodePrefix(data.sublist(discriminator.length), limits: limits)
        .value;
  }

  /// Decodes account data and permits trailing allocation padding.
  static SolsStreamProgramConfig decodeAccount(
    List<int> data, {
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) {
    _verifyDiscriminator(data);
    return SolsStreamProgramConfig.codec
        .decodePrefix(data.sublist(discriminator.length), limits: limits)
        .value;
  }

  /// Decodes account data and rejects trailing bytes.
  static SolsStreamProgramConfig decodeAccountExact(
    List<int> data, {
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) {
    _verifyDiscriminator(data);
    return SolsStreamProgramConfig.codec.decodeExact(
      data.sublist(discriminator.length),
      limits: limits,
    );
  }

  static void _verifyDiscriminator(List<int> data) {
    if (data.length < discriminator.length) {
      throw FormatException('Account data is shorter than its discriminator.');
    }
    if (!_hasDiscriminator(data)) {
      throw FormatException('Account discriminator mismatch.');
    }
  }

  static bool _hasDiscriminator(List<int> data) {
    if (data.length < discriminator.length) {
      return false;
    }
    for (var index = 0; index < discriminator.length; index++) {
      if (data[index] != discriminator[index]) {
        return false;
      }
    }
    return true;
  }
}

/// Decoder and discriminator metadata for `SolsStreamRoom` accounts.
abstract final class SolsStreamRoomAccount {
  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    156,
    199,
    67,
    27,
    222,
    23,
    185,
    94,
  ]);

  /// IDL account name.
  static const String name = 'Room';

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only account metadata.
  static final SolsStreamAccountMetadata metadata = SolsStreamAccountMetadata(
    name: name,
    discriminator: discriminator,
  );

  /// Decodes account data or returns `null` on discriminator mismatch.
  static SolsStreamRoom? tryDecodeAccount(
    List<int> data, {
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) {
    if (!_hasDiscriminator(data)) {
      return null;
    }
    return SolsStreamRoom.codec
        .decodePrefix(data.sublist(discriminator.length), limits: limits)
        .value;
  }

  /// Decodes account data and permits trailing allocation padding.
  static SolsStreamRoom decodeAccount(
    List<int> data, {
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) {
    _verifyDiscriminator(data);
    return SolsStreamRoom.codec
        .decodePrefix(data.sublist(discriminator.length), limits: limits)
        .value;
  }

  /// Decodes account data and rejects trailing bytes.
  static SolsStreamRoom decodeAccountExact(
    List<int> data, {
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) {
    _verifyDiscriminator(data);
    return SolsStreamRoom.codec.decodeExact(
      data.sublist(discriminator.length),
      limits: limits,
    );
  }

  static void _verifyDiscriminator(List<int> data) {
    if (data.length < discriminator.length) {
      throw FormatException('Account data is shorter than its discriminator.');
    }
    if (!_hasDiscriminator(data)) {
      throw FormatException('Account discriminator mismatch.');
    }
  }

  static bool _hasDiscriminator(List<int> data) {
    if (data.length < discriminator.length) {
      return false;
    }
    for (var index = 0; index < discriminator.length; index++) {
      if (data[index] != discriminator[index]) {
        return false;
      }
    }
    return true;
  }
}

/// Decoder and discriminator metadata for `SolsStreamUser` accounts.
abstract final class SolsStreamUserAccount {
  /// IDL discriminator bytes.
  static final List<int> discriminator = List.unmodifiable(<int>[
    159,
    117,
    95,
    227,
    239,
    151,
    58,
    236,
  ]);

  /// IDL account name.
  static const String name = 'User';

  /// Number of discriminator bytes.
  static const int discriminatorLength = 8;

  /// Data-only account metadata.
  static final SolsStreamAccountMetadata metadata = SolsStreamAccountMetadata(
    name: name,
    discriminator: discriminator,
  );

  /// Decodes account data or returns `null` on discriminator mismatch.
  static SolsStreamUser? tryDecodeAccount(
    List<int> data, {
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) {
    if (!_hasDiscriminator(data)) {
      return null;
    }
    return SolsStreamUser.codec
        .decodePrefix(data.sublist(discriminator.length), limits: limits)
        .value;
  }

  /// Decodes account data and permits trailing allocation padding.
  static SolsStreamUser decodeAccount(
    List<int> data, {
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) {
    _verifyDiscriminator(data);
    return SolsStreamUser.codec
        .decodePrefix(data.sublist(discriminator.length), limits: limits)
        .value;
  }

  /// Decodes account data and rejects trailing bytes.
  static SolsStreamUser decodeAccountExact(
    List<int> data, {
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) {
    _verifyDiscriminator(data);
    return SolsStreamUser.codec.decodeExact(
      data.sublist(discriminator.length),
      limits: limits,
    );
  }

  static void _verifyDiscriminator(List<int> data) {
    if (data.length < discriminator.length) {
      throw FormatException('Account data is shorter than its discriminator.');
    }
    if (!_hasDiscriminator(data)) {
      throw FormatException('Account discriminator mismatch.');
    }
  }

  static bool _hasDiscriminator(List<int> data) {
    if (data.length < discriminator.length) {
      return false;
    }
    for (var index = 0; index < discriminator.length; index++) {
      if (data[index] != discriminator[index]) {
        return false;
      }
    }
    return true;
  }
}

/// Program-level registry of generated account metadata.
abstract final class SolsStreamAccountRegistry {
  /// Accounts declared by the IDL in source order.
  static final List<SolsStreamAccountMetadata> accounts = List.unmodifiable(
    <SolsStreamAccountMetadata>[
      SolsStreamConnectSlotAccount.metadata,
      SolsStreamProgramConfigAccount.metadata,
      SolsStreamRoomAccount.metadata,
      SolsStreamUserAccount.metadata,
    ],
  );

  /// Account metadata indexed by IDL account name.
  static final Map<String, SolsStreamAccountMetadata> byName = Map.unmodifiable(
    {for (final account in accounts) account.name: account},
  );
}

/// Typed account reader and scanner client.
final class SolsStreamAccountsClient {
  /// Creates a client from narrow account capabilities.
  const SolsStreamAccountsClient({required this.reader, this.scanner});

  /// Account read capability.
  final SolsStreamAccountReader reader;

  /// Optional account scan capability.
  final SolsStreamAccountScanner? scanner;

  /// Fetches and validates one `SolsStreamConnectSlot` account.
  Future<SolsStreamConnectSlot> fetchConnectSlot(
    SolsStreamAddress address, {
    SolsStreamAccountReadOptions options = const SolsStreamAccountReadOptions(),
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) async {
    final snapshot = await reader.readAccount(address, options: options);
    if (snapshot == null) {
      throw const SolsStreamAccountException(
        code: 'ACCOUNT_NOT_FOUND',
        message: 'Account does not exist.',
      );
    }
    if (snapshot.owner != SolsStreamProgram.programAddress) {
      throw const SolsStreamAccountException(
        code: 'ACCOUNT_OWNER_MISMATCH',
        message: 'Account owner mismatch.',
      );
    }
    return SolsStreamConnectSlotAccount.decodeAccount(
      snapshot.data,
      limits: limits,
    );
  }

  /// Fetches one account or returns `null` only when absent.
  Future<SolsStreamConnectSlot?> fetchConnectSlotNullable(
    SolsStreamAddress address, {
    SolsStreamAccountReadOptions options = const SolsStreamAccountReadOptions(),
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) async {
    final snapshot = await reader.readAccount(address, options: options);
    if (snapshot == null) {
      return null;
    }
    if (snapshot.owner != SolsStreamProgram.programAddress) {
      throw const SolsStreamAccountException(
        code: 'ACCOUNT_OWNER_MISMATCH',
        message: 'Account owner mismatch.',
      );
    }
    return SolsStreamConnectSlotAccount.decodeAccount(
      snapshot.data,
      limits: limits,
    );
  }

  /// Fetches accounts while preserving order and missing positions.
  Future<List<SolsStreamConnectSlot?>> fetchMultipleConnectSlot(
    List<SolsStreamAddress> addresses, {
    SolsStreamAccountReadOptions options = const SolsStreamAccountReadOptions(),
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) async {
    final snapshots = await reader.readAccounts(
      List.unmodifiable(addresses),
      options: options,
    );
    if (snapshots.length != addresses.length) {
      throw const SolsStreamAccountException(
        code: 'ACCOUNT_RESULT_CARDINALITY',
        message: 'AccountReader changed result cardinality.',
      );
    }
    return List.unmodifiable(
      snapshots.map((snapshot) {
        if (snapshot == null) {
          return null;
        }
        if (snapshot.owner != SolsStreamProgram.programAddress) {
          throw const SolsStreamAccountException(
            code: 'ACCOUNT_OWNER_MISMATCH',
            message: 'Account owner mismatch.',
          );
        }
        return SolsStreamConnectSlotAccount.decodeAccount(
          snapshot.data,
          limits: limits,
        );
      }),
    );
  }

  /// Scans every matching program account.
  Future<List<SolsStreamConnectSlot>> allConnectSlot({
    List<SolsStreamAccountFilter> filters = const [],
    SolsStreamAccountReadOptions options = const SolsStreamAccountReadOptions(),
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) async {
    final capability = scanner;
    if (capability == null) {
      throw const SolsStreamAccountException(
        code: 'ACCOUNT_SCANNER_UNAVAILABLE',
        message: 'AccountScanner capability is unavailable.',
      );
    }
    final discriminatorFilter = SolsStreamMemcmpFilter(
      offset: 0,
      bytes: SolsStreamConnectSlotAccount.discriminator,
    );
    final snapshots = await capability.scanAccounts(
      SolsStreamProgram.programAddress,
      filters: [discriminatorFilter, ...filters],
      options: options,
    );
    return List.unmodifiable(
      snapshots.map((snapshot) {
        if (snapshot.owner != SolsStreamProgram.programAddress) {
          throw const SolsStreamAccountException(
            code: 'ACCOUNT_OWNER_MISMATCH',
            message: 'Account owner mismatch.',
          );
        }
        return SolsStreamConnectSlotAccount.decodeAccount(
          snapshot.data,
          limits: limits,
        );
      }),
    );
  }

  /// Fetches and validates one `SolsStreamProgramConfig` account.
  Future<SolsStreamProgramConfig> fetchProgramConfig(
    SolsStreamAddress address, {
    SolsStreamAccountReadOptions options = const SolsStreamAccountReadOptions(),
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) async {
    final snapshot = await reader.readAccount(address, options: options);
    if (snapshot == null) {
      throw const SolsStreamAccountException(
        code: 'ACCOUNT_NOT_FOUND',
        message: 'Account does not exist.',
      );
    }
    if (snapshot.owner != SolsStreamProgram.programAddress) {
      throw const SolsStreamAccountException(
        code: 'ACCOUNT_OWNER_MISMATCH',
        message: 'Account owner mismatch.',
      );
    }
    return SolsStreamProgramConfigAccount.decodeAccount(
      snapshot.data,
      limits: limits,
    );
  }

  /// Fetches one account or returns `null` only when absent.
  Future<SolsStreamProgramConfig?> fetchProgramConfigNullable(
    SolsStreamAddress address, {
    SolsStreamAccountReadOptions options = const SolsStreamAccountReadOptions(),
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) async {
    final snapshot = await reader.readAccount(address, options: options);
    if (snapshot == null) {
      return null;
    }
    if (snapshot.owner != SolsStreamProgram.programAddress) {
      throw const SolsStreamAccountException(
        code: 'ACCOUNT_OWNER_MISMATCH',
        message: 'Account owner mismatch.',
      );
    }
    return SolsStreamProgramConfigAccount.decodeAccount(
      snapshot.data,
      limits: limits,
    );
  }

  /// Fetches accounts while preserving order and missing positions.
  Future<List<SolsStreamProgramConfig?>> fetchMultipleProgramConfig(
    List<SolsStreamAddress> addresses, {
    SolsStreamAccountReadOptions options = const SolsStreamAccountReadOptions(),
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) async {
    final snapshots = await reader.readAccounts(
      List.unmodifiable(addresses),
      options: options,
    );
    if (snapshots.length != addresses.length) {
      throw const SolsStreamAccountException(
        code: 'ACCOUNT_RESULT_CARDINALITY',
        message: 'AccountReader changed result cardinality.',
      );
    }
    return List.unmodifiable(
      snapshots.map((snapshot) {
        if (snapshot == null) {
          return null;
        }
        if (snapshot.owner != SolsStreamProgram.programAddress) {
          throw const SolsStreamAccountException(
            code: 'ACCOUNT_OWNER_MISMATCH',
            message: 'Account owner mismatch.',
          );
        }
        return SolsStreamProgramConfigAccount.decodeAccount(
          snapshot.data,
          limits: limits,
        );
      }),
    );
  }

  /// Scans every matching program account.
  Future<List<SolsStreamProgramConfig>> allProgramConfig({
    List<SolsStreamAccountFilter> filters = const [],
    SolsStreamAccountReadOptions options = const SolsStreamAccountReadOptions(),
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) async {
    final capability = scanner;
    if (capability == null) {
      throw const SolsStreamAccountException(
        code: 'ACCOUNT_SCANNER_UNAVAILABLE',
        message: 'AccountScanner capability is unavailable.',
      );
    }
    final discriminatorFilter = SolsStreamMemcmpFilter(
      offset: 0,
      bytes: SolsStreamProgramConfigAccount.discriminator,
    );
    final snapshots = await capability.scanAccounts(
      SolsStreamProgram.programAddress,
      filters: [discriminatorFilter, ...filters],
      options: options,
    );
    return List.unmodifiable(
      snapshots.map((snapshot) {
        if (snapshot.owner != SolsStreamProgram.programAddress) {
          throw const SolsStreamAccountException(
            code: 'ACCOUNT_OWNER_MISMATCH',
            message: 'Account owner mismatch.',
          );
        }
        return SolsStreamProgramConfigAccount.decodeAccount(
          snapshot.data,
          limits: limits,
        );
      }),
    );
  }

  /// Fetches and validates one `SolsStreamRoom` account.
  Future<SolsStreamRoom> fetchRoom(
    SolsStreamAddress address, {
    SolsStreamAccountReadOptions options = const SolsStreamAccountReadOptions(),
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) async {
    final snapshot = await reader.readAccount(address, options: options);
    if (snapshot == null) {
      throw const SolsStreamAccountException(
        code: 'ACCOUNT_NOT_FOUND',
        message: 'Account does not exist.',
      );
    }
    if (snapshot.owner != SolsStreamProgram.programAddress) {
      throw const SolsStreamAccountException(
        code: 'ACCOUNT_OWNER_MISMATCH',
        message: 'Account owner mismatch.',
      );
    }
    return SolsStreamRoomAccount.decodeAccount(snapshot.data, limits: limits);
  }

  /// Fetches one account or returns `null` only when absent.
  Future<SolsStreamRoom?> fetchRoomNullable(
    SolsStreamAddress address, {
    SolsStreamAccountReadOptions options = const SolsStreamAccountReadOptions(),
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) async {
    final snapshot = await reader.readAccount(address, options: options);
    if (snapshot == null) {
      return null;
    }
    if (snapshot.owner != SolsStreamProgram.programAddress) {
      throw const SolsStreamAccountException(
        code: 'ACCOUNT_OWNER_MISMATCH',
        message: 'Account owner mismatch.',
      );
    }
    return SolsStreamRoomAccount.decodeAccount(snapshot.data, limits: limits);
  }

  /// Fetches accounts while preserving order and missing positions.
  Future<List<SolsStreamRoom?>> fetchMultipleRoom(
    List<SolsStreamAddress> addresses, {
    SolsStreamAccountReadOptions options = const SolsStreamAccountReadOptions(),
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) async {
    final snapshots = await reader.readAccounts(
      List.unmodifiable(addresses),
      options: options,
    );
    if (snapshots.length != addresses.length) {
      throw const SolsStreamAccountException(
        code: 'ACCOUNT_RESULT_CARDINALITY',
        message: 'AccountReader changed result cardinality.',
      );
    }
    return List.unmodifiable(
      snapshots.map((snapshot) {
        if (snapshot == null) {
          return null;
        }
        if (snapshot.owner != SolsStreamProgram.programAddress) {
          throw const SolsStreamAccountException(
            code: 'ACCOUNT_OWNER_MISMATCH',
            message: 'Account owner mismatch.',
          );
        }
        return SolsStreamRoomAccount.decodeAccount(
          snapshot.data,
          limits: limits,
        );
      }),
    );
  }

  /// Scans every matching program account.
  Future<List<SolsStreamRoom>> allRoom({
    List<SolsStreamAccountFilter> filters = const [],
    SolsStreamAccountReadOptions options = const SolsStreamAccountReadOptions(),
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) async {
    final capability = scanner;
    if (capability == null) {
      throw const SolsStreamAccountException(
        code: 'ACCOUNT_SCANNER_UNAVAILABLE',
        message: 'AccountScanner capability is unavailable.',
      );
    }
    final discriminatorFilter = SolsStreamMemcmpFilter(
      offset: 0,
      bytes: SolsStreamRoomAccount.discriminator,
    );
    final snapshots = await capability.scanAccounts(
      SolsStreamProgram.programAddress,
      filters: [discriminatorFilter, ...filters],
      options: options,
    );
    return List.unmodifiable(
      snapshots.map((snapshot) {
        if (snapshot.owner != SolsStreamProgram.programAddress) {
          throw const SolsStreamAccountException(
            code: 'ACCOUNT_OWNER_MISMATCH',
            message: 'Account owner mismatch.',
          );
        }
        return SolsStreamRoomAccount.decodeAccount(
          snapshot.data,
          limits: limits,
        );
      }),
    );
  }

  /// Fetches and validates one `SolsStreamUser` account.
  Future<SolsStreamUser> fetchUser(
    SolsStreamAddress address, {
    SolsStreamAccountReadOptions options = const SolsStreamAccountReadOptions(),
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) async {
    final snapshot = await reader.readAccount(address, options: options);
    if (snapshot == null) {
      throw const SolsStreamAccountException(
        code: 'ACCOUNT_NOT_FOUND',
        message: 'Account does not exist.',
      );
    }
    if (snapshot.owner != SolsStreamProgram.programAddress) {
      throw const SolsStreamAccountException(
        code: 'ACCOUNT_OWNER_MISMATCH',
        message: 'Account owner mismatch.',
      );
    }
    return SolsStreamUserAccount.decodeAccount(snapshot.data, limits: limits);
  }

  /// Fetches one account or returns `null` only when absent.
  Future<SolsStreamUser?> fetchUserNullable(
    SolsStreamAddress address, {
    SolsStreamAccountReadOptions options = const SolsStreamAccountReadOptions(),
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) async {
    final snapshot = await reader.readAccount(address, options: options);
    if (snapshot == null) {
      return null;
    }
    if (snapshot.owner != SolsStreamProgram.programAddress) {
      throw const SolsStreamAccountException(
        code: 'ACCOUNT_OWNER_MISMATCH',
        message: 'Account owner mismatch.',
      );
    }
    return SolsStreamUserAccount.decodeAccount(snapshot.data, limits: limits);
  }

  /// Fetches accounts while preserving order and missing positions.
  Future<List<SolsStreamUser?>> fetchMultipleUser(
    List<SolsStreamAddress> addresses, {
    SolsStreamAccountReadOptions options = const SolsStreamAccountReadOptions(),
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) async {
    final snapshots = await reader.readAccounts(
      List.unmodifiable(addresses),
      options: options,
    );
    if (snapshots.length != addresses.length) {
      throw const SolsStreamAccountException(
        code: 'ACCOUNT_RESULT_CARDINALITY',
        message: 'AccountReader changed result cardinality.',
      );
    }
    return List.unmodifiable(
      snapshots.map((snapshot) {
        if (snapshot == null) {
          return null;
        }
        if (snapshot.owner != SolsStreamProgram.programAddress) {
          throw const SolsStreamAccountException(
            code: 'ACCOUNT_OWNER_MISMATCH',
            message: 'Account owner mismatch.',
          );
        }
        return SolsStreamUserAccount.decodeAccount(
          snapshot.data,
          limits: limits,
        );
      }),
    );
  }

  /// Scans every matching program account.
  Future<List<SolsStreamUser>> allUser({
    List<SolsStreamAccountFilter> filters = const [],
    SolsStreamAccountReadOptions options = const SolsStreamAccountReadOptions(),
    SolsStreamDecodeLimits limits = SolsStreamDecodeLimits.defaults,
  }) async {
    final capability = scanner;
    if (capability == null) {
      throw const SolsStreamAccountException(
        code: 'ACCOUNT_SCANNER_UNAVAILABLE',
        message: 'AccountScanner capability is unavailable.',
      );
    }
    final discriminatorFilter = SolsStreamMemcmpFilter(
      offset: 0,
      bytes: SolsStreamUserAccount.discriminator,
    );
    final snapshots = await capability.scanAccounts(
      SolsStreamProgram.programAddress,
      filters: [discriminatorFilter, ...filters],
      options: options,
    );
    return List.unmodifiable(
      snapshots.map((snapshot) {
        if (snapshot.owner != SolsStreamProgram.programAddress) {
          throw const SolsStreamAccountException(
            code: 'ACCOUNT_OWNER_MISMATCH',
            message: 'Account owner mismatch.',
          );
        }
        return SolsStreamUserAccount.decodeAccount(
          snapshot.data,
          limits: limits,
        );
      }),
    );
  }
}
