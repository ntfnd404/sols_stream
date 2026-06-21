/// Output DTO for a started broadcast: the shareable `sols://` [url] plus the
/// on-chain handles (`roomPda`/`slotPda`) and key material the publisher needs
/// to watch for an answer and, later, reclaim the slot.
class SignalingSession {
  final String url;
  final String roomPda;
  final String slotPda;
  final String prot;
  final int slotNonce;
  final int roomNonce;

  const SignalingSession({
    required this.url,
    required this.roomPda,
    required this.slotPda,
    required this.prot,
    required this.slotNonce,
    required this.roomNonce,
  });
}
