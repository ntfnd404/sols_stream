import 'dart:typed_data';

import 'package:signaling_solana/src/data/solana_program/sols_stream_account_integrity_exception.dart';
import 'package:signaling_solana/src/data/solana_program/user_account.dart';
import 'package:signaling_solana/src/generated/sols_stream_solana.dart';

final class SolsStreamAccountDecoder {
  const SolsStreamAccountDecoder();

  // Generated decoder/reader defaults are the authoritative account boundary.

  SolsStreamProgramConfig decodeProgramConfig(List<int> data) {
    _requireDiscriminator(data, SolsStreamProgramConfigAccount.metadata);

    return SolsStreamProgramConfigAccount.decodeAccount(data);
  }

  SolsStreamConnectSlot decodeConnectSlot(List<int> data) {
    _requireDiscriminator(
      data,
      SolsStreamConnectSlotAccount.metadata,
    );
    try {
      return SolsStreamConnectSlotAccount.decodeAccount(data);
    } on SolsStreamBorshException catch (currentFailure, currentStack) {
      try {
        return _decodeLegacyConnectSlot(data);
      } on Object {
        Error.throwWithStackTrace(currentFailure, currentStack);
      }
    }
  }

  SolsStreamConnectSlot? decodeScannedConnectSlot(List<int> data) {
    if (!_hasDiscriminator(data, SolsStreamConnectSlotAccount.metadata)) {
      return null;
    }

    return decodeConnectSlot(data);
  }

  UserAccount decodeUserProjection(List<int> data) {
    _requireDiscriminator(data, SolsStreamUserAccount.metadata);
    final reader = SolsStreamBorshReader(
      data.sublist(SolsStreamUserAccount.discriminatorLength),
    );
    reader.field('authority', () => reader.readBytes(32));
    reader.field('nickname', reader.readString);
    final role = reader.field(
      'role',
      () => reader.nested(() => SolsStreamUserRole.codec.read(reader)),
    );
    final room = reader.field(
      'room',
      () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
    );
    reader.field('connected_to', () => reader.readBytes(32));
    reader.field('last_heartbeat', () => reader.readSigned(8));
    reader.field('expires_at', () => reader.readSigned(8));
    final turnExpiresAt = reader.field(
      'turn_expires_at',
      () => reader.readSigned(8),
    );
    final streamCount = reader.field(
      'stream_count',
      () => reader.readInt(4),
    );

    return UserAccount(
      role: role,
      room: room,
      turnExpiresAt: turnExpiresAt,
      streamCount: streamCount,
    );
  }

  SolsStreamConnectSlot _decodeLegacyConnectSlot(List<int> data) {
    final reader = SolsStreamBorshReader(
      data.sublist(SolsStreamConnectSlotAccount.discriminatorLength),
    );
    final room = _address(reader, 'room');
    final host = _address(reader, 'host');
    final viewer = _address(reader, 'viewer');
    final hostDeposit = reader.field(
      'host_deposit',
      () => reader.readUnsigned(8),
    );
    final viewerDeposit = reader.field(
      'viewer_deposit',
      () => reader.readUnsigned(8),
    );
    final hostProtectedKey = _bytes(reader, 'host_protected_key');
    final offerData = _bytes(reader, 'offer_data');
    final viewerProtectedKey = _bytes(reader, 'viewer_protected_key');
    final answerData = _bytes(reader, 'answer_data');
    final state = reader.field(
      'state',
      () => reader.nested(() => SolsStreamSlotState.codec.read(reader)),
    );
    final createdAt = reader.field(
      'created_at',
      () => reader.readSigned(8),
    );
    final expiresAt = reader.field(
      'expires_at',
      () => reader.readSigned(8),
    );
    final bump = reader.field('bump', () => reader.readInt(1));
    if (reader.remaining != 0) {
      throw SolsStreamBorshException(
        code: 'BORSH_TRAILING_BYTES',
        message: 'Legacy ConnectSlot must end immediately after bump.',
        offset: reader.offset,
        path: r'$.bump',
        expected: '0 trailing bytes',
        actual: '${reader.remaining} trailing bytes',
      );
    }

    return SolsStreamConnectSlot(
      room: room,
      host: host,
      viewer: viewer,
      hostDeposit: hostDeposit,
      viewerDeposit: viewerDeposit,
      hostProtectedKey: hostProtectedKey,
      offerData: offerData,
      viewerProtectedKey: viewerProtectedKey,
      answerData: answerData,
      state: state,
      createdAt: createdAt,
      expiresAt: expiresAt,
      bump: bump,
      hostRentPaid: BigInt.zero,
      viewerRentPaid: BigInt.zero,
      accessPrice: BigInt.zero,
      hostConfirmed: false,
      viewerConfirmed: false,
    );
  }

  SolsStreamAddress _address(SolsStreamBorshReader reader, String field) => reader.field(
    field,
    () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
  );

  Uint8List _bytes(SolsStreamBorshReader reader, String field) => reader.field(
    field,
    () => reader.readBytes(reader.collectionLength()),
  );

  void _requireDiscriminator(
    List<int> data,
    SolsStreamAccountMetadata metadata,
  ) {
    if (!_hasDiscriminator(data, metadata)) {
      throw SolsStreamAccountIntegrityException(
        accountName: metadata.name,
        message: data.length < metadata.discriminatorLength
            ? 'data is shorter than its discriminator'
            : 'discriminator mismatch',
      );
    }
  }

  bool _hasDiscriminator(
    List<int> data,
    SolsStreamAccountMetadata metadata,
  ) {
    if (data.length < metadata.discriminatorLength) return false;
    for (var index = 0; index < metadata.discriminatorLength; index++) {
      if (data[index] != metadata.discriminator[index]) return false;
    }

    return true;
  }
}
