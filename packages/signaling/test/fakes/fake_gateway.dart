import 'dart:typed_data';

import 'package:signaling/signaling.dart';

/// Returns scripted slot states, one per `fetchSlot` call (last value repeats).
class FakeGateway implements SignalingChainGateway {
  int claimCalls = 0;

  final List<ConnectSlotData?> _slots;
  int _call = 0;

  FakeGateway(this._slots);

  @override
  Future<ConnectSlotData?> fetchSlot(String slotPda) async {
    final slot = _call < _slots.length ? _slots[_call] : _slots.last;
    _call++;

    return slot;
  }

  @override
  Future<void> claimSlot({
    required String slotPda,
    required String roomPda,
  }) async => claimCalls++;

  @override
  Future<SlotAddresses> resolveSlotAddresses(ConnectionParams params) async => const SlotAddresses(
    roomPda: 'ROOM',
    slotPda: 'SLOT',
  );

  @override
  Future<SlotAddresses> openSignalingSlot({
    required int roomNonce,
    required int slotNonce,
    RoomCreationParams room = const RoomCreationParams.p2pFree(),
  }) => throw UnimplementedError();

  @override
  Future<void> writeOffer(String slotPda, Uint8List payload) => throw UnimplementedError();

  @override
  Future<void> writeAnswer(String slotPda, Uint8List payload) => throw UnimplementedError();

  @override
  Future<void> confirmConnection(String slotPda) => throw UnimplementedError();
}
