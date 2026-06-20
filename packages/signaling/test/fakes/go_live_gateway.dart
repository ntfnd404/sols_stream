import 'dart:typed_data';

import 'package:signaling/signaling.dart';

/// Gateway stub for the `goLive` flow: opens a slot and optionally fails the
/// offer write to exercise the compensation path.
class GoLiveGateway implements SignalingChainGateway {
  final bool failWriteOffer;
  int openCalls = 0;

  GoLiveGateway({this.failWriteOffer = false});

  @override
  Future<SlotAddresses> openSignalingSlot({
    required int roomNonce,
    required int slotNonce,
    RoomCreationParams room = const RoomCreationParams.p2pFree(),
  }) async {
    openCalls++;

    return const SlotAddresses(roomPda: 'ROOM', slotPda: 'SLOT');
  }

  @override
  Future<void> writeOffer(String slotPda, Uint8List payload) async {
    if (failWriteOffer) throw StateError('write failed');
  }

  @override
  Future<ConnectSlotData?> fetchSlot(String slotPda) => throw UnimplementedError();

  @override
  Future<void> claimSlot({required String slotPda, required String roomPda}) =>
      throw UnimplementedError();

  @override
  Future<SlotAddresses> resolveSlotAddresses(ConnectionParams params) =>
      throw UnimplementedError();

  @override
  Future<void> writeAnswer(String slotPda, Uint8List payload) => throw UnimplementedError();

  @override
  Future<void> confirmConnection(String slotPda) => throw UnimplementedError();
}
