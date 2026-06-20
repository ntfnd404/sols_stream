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
Uint8List _account({
  required int stateIdx,
  List<int> offer = const [1, 2, 3],
  List<int> answer = const [4, 5],
  List<int> hostProtKey = const [],
  List<int> viewerProtKey = const [],
  int createdAt = 1700000000,
  int expiresAt = 1700000120,
  int bump = 254,
}) {
  final b = BytesBuilder()
    ..add(Uint8List(8)) // discriminator
    ..add(Uint8List.fromList(List.filled(32, 1))) // room
    ..add(Uint8List.fromList(List.filled(32, 2))) // host
    ..add(Uint8List.fromList(List.filled(32, 3))) // viewer
    ..add(_u64le(111)) // host_deposit
    ..add(_u64le(222)) // viewer_deposit
    ..add(_vec(hostProtKey))
    ..add(_vec(offer))
    ..add(_vec(viewerProtKey))
    ..add(_vec(answer))
    ..add(Uint8List.fromList([stateIdx]))
    ..add(_i64le(createdAt))
    ..add(_i64le(expiresAt))
    ..add(Uint8List.fromList([bump]));

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
      expect(account.hostDeposit, 111);
      expect(account.viewerDeposit, 222);
      expect(account.offerData, [1, 2, 3]);
      expect(account.answerData, [4, 5]);
      expect(account.stateIndex, ConnectSlotState.offerReady.index);
      expect(account.createdAt, 1700000000);
      expect(account.expiresAt, 1700000120);
      expect(account.bump, 254);
      expect(account.hostProtectedKey, isEmpty);
      expect(account.viewerProtectedKey, isEmpty);
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
  });
}
