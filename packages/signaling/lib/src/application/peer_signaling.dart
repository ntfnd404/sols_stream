import 'package:signaling/src/application/peer_host_session.dart';
import 'package:signaling/src/application/peer_offer.dart';

/// Platform-neutral application port for one on-chain P2P signaling session.
///
/// Implementations exchange encrypted SDP through infrastructure ports. Media
/// capture, rendering, and platform WebRTC APIs remain outside this contract.
abstract interface class PeerSignaling {
  /// Publishes [offer] and returns the host lifecycle handle and invite URL.
  Future<PeerHostSession> publishOffer(String offer);

  /// Claims [invite] and returns its decrypted remote offer.
  Future<PeerOffer> fetchOffer(Uri invite);

  /// Encrypts and submits the local SDP [answer] for [offer].
  Future<void> submitAnswer(PeerOffer offer, String answer);

  /// Marks the claimed slot as connected.
  Future<void> confirm(PeerOffer offer);
}
