import 'package:signaling/signaling.dart';

final class RecordingKeyBrokerGateway implements KeyBrokerGateway {
  Duration? lastTtl;

  @override
  Future<String> protect({
    required String passphrase,
    required String hostAddress,
    required String offerId,
    Duration ttl = defaultKeyProtectionTtl,
  }) async {
    lastTtl = ttl;

    return 'protected-key';
  }

  @override
  Future<String> unprotect({
    required String protectedKey,
    required String hostAddress,
    required String offerId,
    String? signedProof,
    String? slotPda,
  }) async => 'test-viewer-passphrase';
}
