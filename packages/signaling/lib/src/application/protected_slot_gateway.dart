import 'dart:typed_data';

import 'package:signaling/src/domain/connect_slot_data.dart';

/// On-chain operations for broker-protected signaling slots.
///
/// The shared host/viewer operations (claim, fetch, confirm) stay on
/// [SignalingChainGateway]; this port owns scan-by-host discovery, identity
/// proof construction, and protected offer/answer writes.
abstract interface class ProtectedSlotGateway {
  /// Scans [hostAddress]'s currently-live room for a joinable ConnectSlot.
  ///
  /// A new viewer may enter an Open slot. The viewer that already claimed a
  /// slot may resume it in Claimed/OfferReady state after a transient failure.
  /// A different viewer must never receive another viewer's claimed slot.
  Future<ProtectedSlotDiscoveryResult> discoverOpenSlot(
    String hostAddress,
  );

  /// Builds a base64 signed-but-unsent proof-of-identity transaction for
  /// [slotPda], which the key broker verifies before releasing a passphrase.
  Future<String> buildSignedProof(String slotPda);

  /// Writes the host's [protectedKey] (broker-protected offer passphrase) and the
  /// encrypted [payload] to the slot, chunked. The viewer releases the passphrase
  /// via `/unprotect-key` using a signed proof, then decrypts the offer.
  Future<void> writeOfferWithProtectedKey({
    required String slotPda,
    required String protectedKey,
    required Uint8List payload,
  });

  /// Writes the viewer's [protectedKey] (broker-protected answer passphrase) and
  /// the encrypted [payload] to the slot, chunked. The host reads the protected
  /// key back to release the passphrase and decrypt the answer.
  Future<void> writeAnswerWithProtectedKey({
    required String slotPda,
    required String protectedKey,
    required Uint8List payload,
  });
}

sealed class ProtectedSlotDiscoveryResult {
  const ProtectedSlotDiscoveryResult();
}

/// A joinable ConnectSlot located by scan-by-host discovery.
final class DiscoveredSlot extends ProtectedSlotDiscoveryResult {
  final String slotPda;
  final String roomPda;
  final ConnectSlotData slot;

  const DiscoveredSlot({
    required this.slotPda,
    required this.roomPda,
    required this.slot,
  }) : super();
}

enum ProtectedSlotUnavailableReason {
  noJoinableSlot,
  claimedByAnotherViewer,
}

/// Explains why scan-by-host discovery did not return a joinable slot.
final class ProtectedSlotUnavailable extends ProtectedSlotDiscoveryResult {
  final ProtectedSlotUnavailableReason reason;

  const ProtectedSlotUnavailable(this.reason) : super();
}
