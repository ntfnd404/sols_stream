import 'package:signaling/signaling.dart';

/// Returns [passphraseToUnprotect] for all [unprotect] calls.
/// [protect] returns a constant stub key.
class FakeKeyBrokerGateway implements KeyBrokerGateway {
  final String passphraseToUnprotect;

  const FakeKeyBrokerGateway({required this.passphraseToUnprotect});

  @override
  Future<String> protect({
    required String passphrase,
    required String hostAddress,
    required String offerId,
    Duration ttl = defaultKeyProtectionTtl,
  }) async => 'fake-protected-key';

  @override
  Future<String> unprotect({
    required String protectedKey,
    required String hostAddress,
    required String offerId,
    String? signedProof,
    String? slotPda,
  }) async => passphraseToUnprotect;
}
