import 'package:signaling/signaling.dart';

/// Records reclaim calls so tests can assert the compensation/teardown path ran
/// in the right order with the right arguments.
class RecordingReclaimGateway implements SignalingReclaimGateway {
  /// Optional faults: when set, the matching method records its call (so tests
  /// can assert it was attempted) and then throws, simulating a gateway whose
  /// best-effort guarantee leaked so the orchestrator's own guard is exercised.
  final Object? throwOnCloseConnectSlot;
  final Object? throwOnEndRoom;
  final Object? throwOnCloseRoom;

  /// `(slotPda, viewer)` for each [closeConnectSlot] call, in order.
  final List<({String slotPda, String? viewer})> closedSlots = [];
  final List<String> endedRooms = [];
  final List<String> closedRooms = [];

  /// Calls across all methods, in order, for cross-method ordering assertions.
  final List<String> calls = [];

  RecordingReclaimGateway({
    this.throwOnCloseConnectSlot,
    this.throwOnEndRoom,
    this.throwOnCloseRoom,
  });

  @override
  Future<ReclaimOutcome> closeConnectSlot({
    required String slotPda,
    String? viewer,
  }) async {
    closedSlots.add((slotPda: slotPda, viewer: viewer));
    calls.add('closeConnectSlot:$slotPda');
    if (throwOnCloseConnectSlot != null) throw throwOnCloseConnectSlot!;

    return ReclaimOutcome.succeeded;
  }

  @override
  Future<ReclaimOutcome> endRoom({required String roomPda}) async {
    endedRooms.add(roomPda);
    calls.add('endRoom:$roomPda');
    if (throwOnEndRoom != null) throw throwOnEndRoom!;

    return ReclaimOutcome.succeeded;
  }

  @override
  Future<ReclaimOutcome> closeRoom({required String roomPda}) async {
    closedRooms.add(roomPda);
    calls.add('closeRoom:$roomPda');
    if (throwOnCloseRoom != null) throw throwOnCloseRoom!;

    return ReclaimOutcome.succeeded;
  }
}
