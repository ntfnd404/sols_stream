import 'dart:convert';

import 'package:signaling/src/application/key_broker_exception.dart';
import 'package:signaling/src/application/key_broker_gateway.dart';

/// Local-development broker that carries the passphrase in a scoped,
/// expiring capability envelope.
///
/// This adapter provides interoperability between separate local app
/// processes without a broker server. It is intentionally not secure against a
/// user who can read local validator account data and must never be wired in a
/// shared or production environment.
final class LocalKeyBrokerGateway implements KeyBrokerGateway {
  final DateTime Function() _now;

  LocalKeyBrokerGateway({
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  @override
  Future<String> protect({
    required String passphrase,
    required String hostAddress,
    required String offerId,
    Duration ttl = defaultKeyProtectionTtl,
  }) async {
    if (ttl <= Duration.zero) {
      throw const KeyBrokerException(
        operation: 'local-protect-key',
        reason: 'received an invalid TTL',
      );
    }

    final payload = jsonEncode(<String, Object>{
      'v': 1,
      'expiresAt': _now().add(ttl).millisecondsSinceEpoch,
      'hostAddress': hostAddress,
      'offerId': offerId,
      'passphrase': passphrase,
    });

    return base64Url.encode(utf8.encode(payload)).replaceAll('=', '');
  }

  @override
  Future<String> unprotect({
    required String protectedKey,
    required String hostAddress,
    required String offerId,
    String? signedProof,
    String? slotPda,
  }) async {
    try {
      final normalized = protectedKey.padRight(
        protectedKey.length + ((4 - protectedKey.length % 4) % 4),
        '=',
      );
      final Object? decoded = jsonDecode(
        utf8.decode(base64Url.decode(normalized)),
      );
      if (decoded is! Map<String, Object?> ||
          decoded['v'] != 1 ||
          decoded['hostAddress'] != hostAddress ||
          decoded['offerId'] != offerId ||
          (slotPda != null && slotPda != offerId)) {
        throw const FormatException();
      }

      final expiresAt = decoded['expiresAt'];
      final passphrase = decoded['passphrase'];
      if (expiresAt is! int ||
          expiresAt <= _now().millisecondsSinceEpoch ||
          passphrase is! String ||
          passphrase.isEmpty) {
        throw const FormatException();
      }

      return passphrase;
    } on Exception catch (_, stack) {
      Error.throwWithStackTrace(
        const KeyBrokerException(
          operation: 'local-unprotect-key',
          reason: 'rejected the capability',
        ),
        stack,
      );
    }
  }
}
