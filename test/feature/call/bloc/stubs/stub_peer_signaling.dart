import 'package:signaling/signaling.dart';

final class StubPeerSignaling implements PeerSignaling {
  final Object? publishError;
  final Object? fetchError;
  final PeerHostSession? hostSession;
  final PeerOffer? offer;

  const StubPeerSignaling({
    this.publishError,
    this.fetchError = const PeerSelfConnectionException(),
    this.hostSession,
    this.offer,
  });

  @override
  Future<PeerHostSession> publishOffer(String offer) async {
    if (publishError case final error?) throw error;

    return hostSession ?? (throw StateError('StubPeerSignaling.hostSession is not configured.'));
  }

  @override
  Future<PeerOffer> fetchOffer(Uri invite) async {
    if (fetchError case final error?) throw error;

    return offer ?? (throw StateError('StubPeerSignaling.offer is not configured.'));
  }

  @override
  Future<void> submitAnswer(PeerOffer offer, String answer) async {}

  @override
  Future<void> confirm(PeerOffer offer) async {}
}
