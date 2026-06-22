import 'package:signaling/signaling.dart';

/// Records reclaim calls so tests can assert the compensation/teardown path ran
/// in the right order with the right arguments.
class RecordingReclaimGateway implements SignalingReclaimGateway {
  /// `(slotPda, viewer)` for each [closeConnectSlot] call, in order.
  final List<({String slotPda, String? viewer})> closedSlots = [];
  final List<String> endedRooms = [];
  final List<String> closedRooms = [];

  /// Calls across all methods, in order, for cross-method ordering assertions.
  final List<String> calls = [];

  @override
  Future<void> closeConnectSlot({required String slotPda, String? viewer}) async {
    closedSlots.add((slotPda: slotPda, viewer: viewer));
    calls.add('closeConnectSlot:$slotPda');
  }

  @override
  Future<void> endRoom({required String roomPda}) async {
    endedRooms.add(roomPda);
    calls.add('endRoom:$roomPda');
  }

  @override
  Future<void> closeRoom({required String roomPda}) async {
    closedRooms.add(roomPda);
    calls.add('closeRoom:$roomPda');
  }
}
