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
