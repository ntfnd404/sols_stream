/// A decrypted offer obtained by joining an on-chain P2P call.
///
/// [sdpOffer] is a `{"type":"offer","sdp":...}` JSON string, ready for the
/// WebRTC layer (matching the shape the viewer UI already consumes). [slotPda]
/// and [hostAddress] carry the on-chain context needed to write the answer and
/// confirm the connection.
final class PeerOffer {
  final String sdpOffer;
  final String slotPda;
  final String hostAddress;

  const PeerOffer({
    required this.sdpOffer,
    required this.slotPda,
    required this.hostAddress,
  });

  @override
  String toString() => 'PeerOffer(sdpOffer: [redacted], slotPda: $slotPda, hostAddress: $hostAddress)';
}
