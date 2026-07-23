import 'dart:typed_data';

import 'package:signaling/signaling.dart';

/// Records [writeOfferWithProtectedKey] calls for assertion in tests.
/// [discoverOpenSlot] and [buildSignedProof] return stub values.
class FakeProtectedSlotGateway implements ProtectedSlotGateway {
  int writeOfferCalls = 0;
  final ProtectedSlotDiscoveryResult discoveryResult;

  FakeProtectedSlotGateway({
    this.discoveryResult = const ProtectedSlotUnavailable(
      ProtectedSlotUnavailableReason.noJoinableSlot,
    ),
  });

  @override
  Future<void> writeOfferWithProtectedKey({
    required String slotPda,
    required String protectedKey,
    required Uint8List payload,
  }) async => writeOfferCalls++;

  @override
  Future<void> writeAnswerWithProtectedKey({
    required String slotPda,
    required String protectedKey,
    required Uint8List payload,
  }) async {}

  @override
  Future<ProtectedSlotDiscoveryResult> discoverOpenSlot(
    String hostAddress,
  ) async => discoveryResult;

  @override
  Future<String> buildSignedProof(String slotPda) async => 'fake-proof';
}
