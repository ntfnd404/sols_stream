import 'dart:typed_data';

import 'package:signaling/src/data/solana_program/connect_slot_account_parser.dart';
import 'package:signaling/src/domain/connect_slot_state.dart';
import 'package:test/test.dart';

Uint8List _u32le(int v) =>
    (ByteData(4)..setUint32(0, v, Endian.little)).buffer.asUint8List();
Uint8List _u64le(int v) =>
    (ByteData(8)..setUint64(0, v, Endian.little)).buffer.asUint8List();
Uint8List _i64le(int v) =>
    (ByteData(8)..setInt64(0, v, Endian.little)).buffer.asUint8List();
Uint8List _vec(List<int> bytes) =>
    Uint8List.fromList([..._u32le(bytes.length), ...bytes]);

/// Builds a Borsh ConnectSlot account buffer matching the parser's layout.
///
/// With [upgrade07] `true` the Upgrade-07 tail (rent / access price /
/// confirmation flags) is appended; with `false` the buffer ends at `bump`,
/// reproducing a slot written before the upgrade.
Uint8List _account({
  required int stateIdx,
  List<int> offer = const [1, 2, 3],
  List<int> answer = const [4, 5],
  List<int> hostProtKey = const [],
  List<int> viewerProtKey = const [],
  int createdAt = 1700000000,
  int expiresAt = 1700000120,
  int bump = 254,
  int hostDeposit = 111,
  bool upgrade07 = false,
  int hostRentPaid = 0,
  int viewerRentPaid = 0,
  int accessPrice = 0,
  bool hostConfirmed = false,
  bool viewerConfirmed = false,
}) {
  final b = BytesBuilder()
    ..add(Uint8List(8)) // discriminator
    ..add(Uint8List.fromList(List.filled(32, 1))) // room
    ..add(Uint8List.fromList(List.filled(32, 2))) // host
    ..add(Uint8List.fromList(List.filled(32, 3))) // viewer
    ..add(_u64le(hostDeposit)) // host_deposit
    ..add(_u64le(222)) // viewer_deposit
    ..add(_vec(hostProtKey))
    ..add(_vec(offer))
    ..add(_vec(viewerProtKey))
    ..add(_vec(answer))
    ..add(Uint8List.fromList([stateIdx]))
    ..add(_i64le(createdAt))
    ..add(_i64le(expiresAt))
    ..add(Uint8List.fromList([bump]));

  if (upgrade07) {
    b
      ..add(_u64le(hostRentPaid))
      ..add(_u64le(viewerRentPaid))
      ..add(_u64le(accessPrice))
      ..add(Uint8List.fromList([hostConfirmed ? 1 : 0]))
      ..add(Uint8List.fromList([viewerConfirmed ? 1 : 0]));
  }

  return b.toBytes();
}

void main() {
  group('ConnectSlotAccountParser', () {
    test('parses every wire field from a valid account buffer', () {
      final account = ConnectSlotAccountParser.parse(
        _account(stateIdx: ConnectSlotState.offerReady.index),
      );

      expect(account.room, List.filled(32, 1));
      expect(account.host, List.filled(32, 2));
      expect(account.viewer, List.filled(32, 3));
      expect(account.hostDeposit, BigInt.from(111));
      expect(account.viewerDeposit, BigInt.from(222));
      expect(account.offerData, [1, 2, 3]);
      expect(account.answerData, [4, 5]);
      expect(account.stateIndex, ConnectSlotState.offerReady.index);
      expect(account.createdAt, BigInt.from(1700000000));
      expect(account.expiresAt, BigInt.from(1700000120));
      expect(account.bump, 254);
      expect(account.hostProtectedKey, isEmpty);
      expect(account.viewerProtectedKey, isEmpty);
    });

    test('reads the Upgrade-07 tail when present', () {
      final account = ConnectSlotAccountParser.parse(
        _account(
          stateIdx: ConnectSlotState.connected.index,
          upgrade07: true,
          hostRentPaid: 890880,
          viewerRentPaid: 7000,
          accessPrice: 500000,
          hostConfirmed: true,
          viewerConfirmed: true,
        ),
      );

      expect(account.hostRentPaid, BigInt.from(890880));
      expect(account.viewerRentPaid, BigInt.from(7000));
      expect(account.accessPrice, BigInt.from(500000));
      expect(account.hostConfirmed, isTrue);
      expect(account.viewerConfirmed, isTrue);
    });

    test('defaults the Upgrade-07 tail to 0/false for a pre-upgrade slot', () {
      final account = ConnectSlotAccountParser.parse(
        _account(stateIdx: ConnectSlotState.open.index),
      );

      expect(account.hostRentPaid, BigInt.zero);
      expect(account.viewerRentPaid, BigInt.zero);
      expect(account.accessPrice, BigInt.zero);
      expect(account.hostConfirmed, isFalse);
      expect(account.viewerConfirmed, isFalse);
    });

    test('reads a u64 deposit beyond 2^53 without precision loss', () {
      // 2^53 + 1 is the first integer a double cannot represent exactly; BigInt
      // must round-trip it verbatim.
      final account = ConnectSlotAccountParser.parse(
        _account(stateIdx: ConnectSlotState.open.index, hostDeposit: 9007199254740993),
      );

      expect(account.hostDeposit, BigInt.parse('9007199254740993'));
    });

    test('round-trips a partially-confirmed Upgrade-07 slot', () {
      final account = ConnectSlotAccountParser.parse(
        _account(
          stateIdx: ConnectSlotState.answerReady.index,
          upgrade07: true,
          hostConfirmed: true,
        ),
      );

      expect(account.hostConfirmed, isTrue);
      expect(account.viewerConfirmed, isFalse);
    });

    test('reads non-empty protected keys', () {
      final account = ConnectSlotAccountParser.parse(
        _account(
          stateIdx: ConnectSlotState.open.index,
          hostProtKey: [9, 9],
          viewerProtKey: [7],
        ),
      );

      expect(account.hostProtectedKey, [9, 9]);
      expect(account.viewerProtectedKey, [7]);
    });

    test('preserves the raw state index without validating it', () {
      // The parser stays at the wire boundary; out-of-range validation is the
      // mapper's job, so a bogus index parses without throwing.
      final account = ConnectSlotAccountParser.parse(_account(stateIdx: 99));

      expect(account.stateIndex, 99);
    });

    test('throws FormatException (not RangeError) on a truncated buffer', () {
      final full = _account(stateIdx: ConnectSlotState.offerReady.index);
      final truncated = full.sublist(0, full.length - 10);

      expect(
        () => ConnectSlotAccountParser.parse(truncated),
        throwsFormatException,
      );
    });
  });
}
