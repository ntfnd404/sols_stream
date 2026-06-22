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
  int hostRentPaid = 0,
  int viewerRentPaid = 0,
  int accessPrice = 0,
  bool hostConfirmed = false,
  bool viewerConfirmed = false,
}) => ConnectSlotAccount(
  room: Uint8List.fromList(List.filled(32, 1)),
  host: Uint8List.fromList(List.filled(32, 2)),
  viewer: Uint8List.fromList(List.filled(32, 3)),
  hostDeposit: BigInt.from(hostDeposit),
  viewerDeposit: BigInt.from(viewerDeposit),
  hostProtectedKey: Uint8List.fromList(hostProtKey),
  offerData: Uint8List.fromList([1, 2, 3]),
  viewerProtectedKey: Uint8List.fromList(viewerProtKey),
  answerData: Uint8List.fromList([4, 5]),
  stateIndex: stateIndex,
  createdAt: BigInt.from(1700000000),
  expiresAt: BigInt.from(1700000120),
  bump: 254,
  hostRentPaid: BigInt.from(hostRentPaid),
  viewerRentPaid: BigInt.from(viewerRentPaid),
  accessPrice: BigInt.from(accessPrice),
  hostConfirmed: hostConfirmed,
  viewerConfirmed: viewerConfirmed,
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

      expect(slot.hostDeposit, BigInt.from(2000000));
      expect(slot.viewerDeposit, BigInt.from(1500000));
    });

    test('surfaces the Upgrade-07 rent, access price and confirmation flags', () {
      final slot = ConnectSlotMapper.toDomain(
        _account(
          stateIndex: ConnectSlotState.connected.index,
          hostRentPaid: 890880,
          viewerRentPaid: 7000,
          accessPrice: 500000,
          hostConfirmed: true,
          viewerConfirmed: true,
        ),
      );

      expect(slot.hostRentPaid, BigInt.from(890880));
      expect(slot.viewerRentPaid, BigInt.from(7000));
      expect(slot.accessPrice, BigInt.from(500000));
      expect(slot.hostConfirmed, isTrue);
      expect(slot.viewerConfirmed, isTrue);
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
      expect(slot.createdAt, BigInt.from(1700000000));
      expect(slot.expiresAt, BigInt.from(1700000120));
    });
  });
}
