import 'package:signaling/signaling.dart';
import 'package:signaling_solana/src/data/solana_program/connect_slot_mapper.dart';
import 'package:signaling_solana/src/data/solana_program/sols_stream_account_decoder.dart';
import 'package:signaling_solana/src/data/solana_program/sols_stream_account_integrity_exception.dart';
import 'package:signaling_solana/src/generated/sols_stream_solana.dart';
import 'package:test/test.dart';

SolsStreamAddress _address(int fill) => SolsStreamAddress.fromBytes(List<int>.filled(32, fill));

List<int> _accountData(List<int> discriminator, List<int> payload) => [
  ...discriminator,
  ...payload,
];

SolsStreamConnectSlot _slot() => SolsStreamConnectSlot(
  room: _address(1),
  host: _address(2),
  viewer: _address(3),
  hostDeposit: BigInt.from(11),
  viewerDeposit: BigInt.from(12),
  hostProtectedKey: [1],
  offerData: [2, 3],
  viewerProtectedKey: [4],
  answerData: [5],
  state: const SolsStreamSlotStateConnected(),
  createdAt: BigInt.from(100),
  expiresAt: BigInt.from(200),
  bump: 254,
  hostRentPaid: BigInt.from(21),
  viewerRentPaid: BigInt.from(22),
  accessPrice: BigInt.from(23),
  hostConfirmed: true,
  viewerConfirmed: false,
);

void main() {
  const decoder = SolsStreamAccountDecoder();

  test('decodes current ConnectSlot and maps generated enum to domain', () {
    final decoded = decoder.decodeConnectSlot(
      _accountData(
        SolsStreamConnectSlotAccount.discriminator,
        SolsStreamConnectSlot.codec.encode(_slot()),
      ),
    );
    final domain = ConnectSlotMapper.toDomain(decoded);

    expect(decoded.hostRentPaid, BigInt.from(21));
    expect(domain.state, ConnectSlotState.connected);
  });

  test('accepts only an exact legacy ConnectSlot prefix', () {
    final current = SolsStreamConnectSlot.codec.encode(_slot());
    final legacy = current.sublist(0, current.length - 26);
    final decoded = decoder.decodeConnectSlot(
      _accountData(SolsStreamConnectSlotAccount.discriminator, legacy),
    );

    expect(decoded.hostRentPaid, BigInt.zero);
    expect(decoded.viewerConfirmed, isFalse);
    expect(
      () => decoder.decodeConnectSlot(
        _accountData(
          SolsStreamConnectSlotAccount.discriminator,
          [...legacy, 0],
        ),
      ),
      throwsA(isA<SolsStreamBorshException>()),
    );
  });

  test('known ConnectSlot mismatch is integrity failure but scan is nullable', () {
    final wrong = List<int>.filled(16, 0);

    expect(
      () => decoder.decodeConnectSlot(wrong),
      throwsA(isA<SolsStreamAccountIntegrityException>()),
    );
    expect(decoder.decodeScannedConnectSlot(wrong), isNull);
  });

  test('known ProgramConfig mismatch is an integrity failure', () {
    expect(
      () => decoder.decodeProgramConfig(List<int>.filled(16, 0)),
      throwsA(isA<SolsStreamAccountIntegrityException>()),
    );
  });

  test('User projection accepts appended fields and validates discriminator', () {
    final writer = SolsStreamBorshWriter()
      ..writeBytes(_address(1).bytes)
      ..writeString('user');
    SolsStreamUserRole.codec.write(writer, const SolsStreamUserRoleHost());
    writer
      ..writeBytes(_address(2).bytes)
      ..writeBytes(_address(3).bytes)
      ..writeSigned(BigInt.from(10), 8)
      ..writeSigned(BigInt.from(20), 8)
      ..writeSigned(BigInt.from(30), 8)
      ..writeUnsigned(BigInt.from(7), 4)
      ..writeBytes([99, 98, 97]);
    final projection = decoder.decodeUserProjection(
      _accountData(SolsStreamUserAccount.discriminator, writer.takeBytes()),
    );

    expect(projection.isHost, isTrue);
    expect(projection.room, _address(2));
    expect(projection.turnExpiresAt, BigInt.from(30));
    expect(projection.streamCount, 7);
    expect(
      () => decoder.decodeUserProjection(List<int>.filled(32, 0)),
      throwsA(isA<SolsStreamAccountIntegrityException>()),
    );
  });

  test('truncated matching User prefix throws structured Borsh failure', () {
    expect(
      () => decoder.decodeUserProjection(SolsStreamUserAccount.discriminator),
      throwsA(isA<SolsStreamBorshException>()),
    );
  });
}
