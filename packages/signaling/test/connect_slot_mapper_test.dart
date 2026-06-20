import 'dart:typed_data';

import 'package:signaling/src/data/solana_program/connect_slot_account.dart';
import 'package:signaling/src/data/solana_program/connect_slot_mapper.dart';
import 'package:signaling/src/domain/connect_slot_state.dart';
import 'package:test/test.dart';

ConnectSlotAccount _account({
  required int stateIndex,
  int hostDeposit = 1000000,
  int viewerDeposit = 1000000,
  List<int> hostProtKey = const [9, 9],
  List<int> viewerProtKey = const [7],
}) => ConnectSlotAccount(
  room: Uint8List.fromList(List.filled(32, 1)),
  host: Uint8List.fromList(List.filled(32, 2)),
  viewer: Uint8List.fromList(List.filled(32, 3)),
  hostDeposit: hostDeposit,
  viewerDeposit: viewerDeposit,
  hostProtectedKey: Uint8List.fromList(hostProtKey),
  offerData: Uint8List.fromList([1, 2, 3]),
  viewerProtectedKey: Uint8List.fromList(viewerProtKey),
  answerData: Uint8List.fromList([4, 5]),
  stateIndex: stateIndex,
  createdAt: 1700000000,
  expiresAt: 1700000120,
  bump: 254,
);

void main() {
  group('ConnectSlotMapper.toDomain', () {
    test('resolves the state index for every ConnectSlotState', () {
      for (final state in ConnectSlotState.values) {
        final slot = ConnectSlotMapper.toDomain(_account(stateIndex: state.index));
        expect(slot.state, state);
      }
    });

    test('throws FormatException on an out-of-range state index', () {
      expect(
        () => ConnectSlotMapper.toDomain(_account(stateIndex: 99)),
        throwsFormatException,
      );
    });

    test('surfaces deposits to the domain', () {
      final slot = ConnectSlotMapper.toDomain(
        _account(
          stateIndex: ConnectSlotState.open.index,
          hostDeposit: 2000000,
          viewerDeposit: 1500000,
        ),
      );

      expect(slot.hostDeposit, 2000000);
      expect(slot.viewerDeposit, 1500000);
    });

    test('carries identity and signaling payloads through', () {
      final slot = ConnectSlotMapper.toDomain(
        _account(stateIndex: ConnectSlotState.answerReady.index),
      );

      expect(slot.room, List.filled(32, 1));
      expect(slot.host, List.filled(32, 2));
      expect(slot.viewer, List.filled(32, 3));
      expect(slot.offerData, [1, 2, 3]);
      expect(slot.answerData, [4, 5]);
      expect(slot.createdAt, 1700000000);
      expect(slot.expiresAt, 1700000120);
    });
  });
}
