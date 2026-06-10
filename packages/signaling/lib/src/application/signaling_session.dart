class SignalingSession {
  final String url;
  final String slotPda;
  final String prot;
  final int slotNonce;
  final int roomNonce;

  const SignalingSession({
    required this.url,
    required this.slotPda,
    required this.prot,
    required this.slotNonce,
    required this.roomNonce,
  });
}
