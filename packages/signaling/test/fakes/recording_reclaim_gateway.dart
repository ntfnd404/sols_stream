import 'package:signaling/signaling.dart';

/// Records reclaim calls so tests can assert the `goLive` compensation path ran.
class RecordingReclaimGateway implements SignalingReclaimGateway {
  final List<String> closedSlots = [];
  final List<String> closedRooms = [];

  @override
  Future<void> closeSlot(String slotPda) async => closedSlots.add(slotPda);

  @override
  Future<void> closeRoom(String roomPda) async => closedRooms.add(roomPda);
}
