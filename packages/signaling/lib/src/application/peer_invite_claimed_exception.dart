/// Thrown when an active one-viewer invite is already owned by another wallet.
final class PeerInviteClaimedException implements Exception {
  const PeerInviteClaimedException();

  @override
  String toString() => 'PeerInviteClaimedException: invite already claimed by another viewer';
}
