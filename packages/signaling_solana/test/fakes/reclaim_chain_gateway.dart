import 'package:signaling/signaling.dart';

/// Scriptable [SignalingChainGateway] for reclaim tests: serves a fixed
/// `ProgramConfig` and a sequence of slot reads, and counts calls so tests can
/// assert the service-wallet cache (one `fetchConfig`) and idempotency.
class ReclaimChainGateway implements SignalingChainGateway {
  final ProgramConfig? config;
  final Object? fetchConfigError;
  final List<ConnectSlotData?> slots;
  final Object? fetchSlotError;

  int fetchConfigCalls = 0;
  int fetchSlotCalls = 0;
  int _slotCall = 0;

  ReclaimChainGateway({
    this.config,
    this.fetchConfigError,
    this.slots = const [],
    this.fetchSlotError,
  });

  @override
  Future<ProgramConfig?> fetchConfig() async {
    fetchConfigCalls++;
    if (fetchConfigError != null) throw fetchConfigError!;

    return config;
  }

  @override
  Future<ConnectSlotData?> fetchSlot(String slotPda) async {
    fetchSlotCalls++;
    if (fetchSlotError != null) throw fetchSlotError!;
    if (slots.isEmpty) return null;
    final slot = _slotCall < slots.length ? slots[_slotCall] : slots.last;
    _slotCall++;

    return slot;
  }

  @override
  Future<SlotAddresses> openSignalingSlot({
    required int slotNonce,
    RoomCreationParams room = const RoomCreationParams.p2pFree(),
    int expiresInSeconds = 120,
  }) => throw UnimplementedError();

  @override
  Future<void> claimSlot({required String slotPda, required String roomPda}) => throw UnimplementedError();

  @override
  Future<void> confirmConnection(String slotPda) => throw UnimplementedError();

  @override
  Future<void> sendHeartbeat() async {}

  @override
  Future<int> readStreamCount() async => 0;

  @override
  Future<void> endRoom(String roomPda) => throw UnimplementedError();

  @override
  Future<void> closeRoom(String roomPda) => throw UnimplementedError();
}
