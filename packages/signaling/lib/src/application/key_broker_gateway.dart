/// Default lifetime requested for a protected signaling key.
const Duration defaultKeyProtectionTtl = Duration(seconds: 90);

/// Gateway to the stateless passphrase key broker.
///
/// The web host protects the slot passphrase behind the broker; a viewer
/// releases it by proving (via [signedProof]) that it is the slot's claimer.
/// The released passphrase then decrypts the on-chain `offer_data` (scheme #2,
/// see `PassphrasePayloadCrypto`).
///
/// Implementations live in data/. The application layer depends on this
/// abstraction, not on the HTTP transport.
abstract interface class KeyBrokerGateway {
  /// Releases the plaintext passphrase for [protectedKey].
  ///
  /// - [protectedKey]: the slot's `host_protected_key`, as a UTF-8 string.
  /// - [hostAddress]: the slot host's base58 address.
  /// - [offerId]: the offer identifier (the slot PDA, for ConnectSlot offers).
  /// - [signedProof]: base64 of a viewer-signed (but unsent) proof transaction;
  ///   the broker verifies the signer equals the slot's viewer.
  /// - [slotPda]: the slot PDA base58 (sent alongside the proof).
  ///
  /// Throws on a non-2xx broker response (e.g. expired key, proof mismatch).
  Future<String> unprotect({
    required String protectedKey,
    required String hostAddress,
    required String offerId,
    String? signedProof,
    String? slotPda,
  });

  /// Protects [passphrase] behind the broker, returning the opaque
  /// `protectedKey` to store on-chain (e.g. as a slot's `viewer_protected_key`).
  /// The counterparty later releases it via [unprotect] with a matching proof.
  ///
  /// - [hostAddress]: the protector's base58 address (the viewer, answer side).
  /// - [offerId]: the offer identifier the key is bound to (the slot PDA).
  /// - [ttl]: requested time-to-live.
  Future<String> protect({
    required String passphrase,
    required String hostAddress,
    required String offerId,
    Duration ttl = defaultKeyProtectionTtl,
  });
}
