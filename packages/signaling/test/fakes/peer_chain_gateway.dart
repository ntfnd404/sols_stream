import 'package:signaling/signaling.dart';

/// Chain gateway stub for the peer host publish flow: opens a slot successfully
/// and returns a scripted sequence of slot states to simulate viewer activity.
class PeerChainGateway implements SignalingChainGateway {
  int endRoomCalls = 0;
  int closeRoomCalls = 0;
  int fetchSlotCalls = 0;
  String? lastEndRoomPda;
  String? lastCloseRoomPda;
  final List<Object?> _slots;
  int _call = 0;

  PeerChainGateway(this._slots);

  @override
  Future<SlotAddresses> openSignalingSlot({
    required int slotNonce,
    RoomCreationParams room = const RoomCreationParams.p2pFree(),
    int expiresInSeconds = 120,
  }) async => const SlotAddresses(
    roomPda: '11111111111111111111111111111111',
    slotPda: 'SLOT',
  );

  @override
  Future<int> readStreamCount() async => 0;

  @override
  Future<ConnectSlotData?> fetchSlot(String slotPda) async {
    fetchSlotCalls++;
    final result = _call < _slots.length ? _slots[_call] : _slots.last;
    _call++;
    if (result is Error) throw result;
    if (result is Exception) throw result;

    return result as ConnectSlotData?;
  }

  @override
  Future<void> sendHeartbeat() async {}

  @override
  Future<void> endRoom(String roomPda) async {
    endRoomCalls++;
    lastEndRoomPda = roomPda;
  }

  @override
  Future<void> closeRoom(String roomPda) async {
    closeRoomCalls++;
    lastCloseRoomPda = roomPda;
  }

  @override
  Future<void> claimSlot({required String slotPda, required String roomPda}) => throw UnimplementedError();

  @override
  Future<void> confirmConnection(String slotPda) => throw UnimplementedError();

  @override
  Future<ProgramConfig?> fetchConfig() => throw UnimplementedError();
}
