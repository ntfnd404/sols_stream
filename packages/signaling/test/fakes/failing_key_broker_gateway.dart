import 'package:signaling/signaling.dart';

final class FailingKeyBrokerGateway implements KeyBrokerGateway {
  final Object protectError;

  const FailingKeyBrokerGateway(this.protectError);

  @override
  Future<String> protect({
    required String passphrase,
    required String hostAddress,
    required String offerId,
    Duration ttl = defaultKeyProtectionTtl,
  }) => Future<String>.error(protectError);

  @override
  Future<String> unprotect({
    required String protectedKey,
    required String hostAddress,
    required String offerId,
    String? signedProof,
    String? slotPda,
  }) => throw UnimplementedError();
}
