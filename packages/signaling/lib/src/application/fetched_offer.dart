class FetchedOffer {
  final String sdpOffer;
  final String slotPda;
  final String roomPda;
  final String prot;
  final int slotNonce;

  const FetchedOffer({
    required this.sdpOffer,
    required this.slotPda,
    required this.roomPda,
    required this.prot,
    required this.slotNonce,
  });
}
