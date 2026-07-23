// ignore_for_file: prefer_initializing_formals

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:signaling/src/application/key_broker_exception.dart';
import 'package:signaling/src/application/key_broker_gateway.dart';

const int _successfulStatusStart = 200;
const int _successfulStatusEndExclusive = 300;
const int _maximumResponseBodyBytes = 64 * 1024;

/// [KeyBrokerGateway] backed by a remote HTTPS broker.
final class HttpKeyBrokerGateway implements KeyBrokerGateway {
  final Uri _endpoint;
  final http.Client _client;
  final Duration _requestTimeout;

  HttpKeyBrokerGateway({
    required Uri endpoint,
    required http.Client client,
    required Duration requestTimeout,
  }) : _endpoint = endpoint,
       _client = client,
       _requestTimeout = requestTimeout;

  @override
  Future<String> unprotect({
    required String protectedKey,
    required String hostAddress,
    required String offerId,
    String? signedProof,
    String? slotPda,
  }) async {
    final decoded = await _post('unprotect-key', {
      'protectedKey': protectedKey,
      'hostAddress': hostAddress,
      'offerId': offerId,
      'signedProof': ?signedProof,
      'slotPDA': ?slotPda,
    });
    final passphrase = decoded['passphrase'];
    if (passphrase is! String || passphrase.isEmpty) {
      throw const KeyBrokerException(
        operation: 'unprotect-key',
        reason: 'returned an invalid response',
      );
    }

    return passphrase;
  }

  @override
  Future<String> protect({
    required String passphrase,
    required String hostAddress,
    required String offerId,
    Duration ttl = defaultKeyProtectionTtl,
  }) async {
    if (ttl <= Duration.zero) {
      throw const KeyBrokerException(
        operation: 'protect-key',
        reason: 'received an invalid TTL',
      );
    }
    final decoded = await _post('protect-key', {
      'passphrase': passphrase,
      'hostAddress': hostAddress,
      'offerId': offerId,
      'ttlMs': ttl.inMilliseconds,
    });
    final protectedKey = decoded['protectedKey'];
    if (protectedKey is! String || protectedKey.isEmpty) {
      throw const KeyBrokerException(
        operation: 'protect-key',
        reason: 'returned an invalid response',
      );
    }

    return protectedKey;
  }

  Future<Map<String, Object?>> _post(
    String operation,
    Map<String, Object?> body,
  ) async {
    try {
      return await _send(operation, body).timeout(
        _requestTimeout,
        onTimeout: () => throw KeyBrokerException(
          operation: operation,
          reason: 'request timed out',
        ),
      );
    } on KeyBrokerException {
      rethrow;
    } on Exception catch (_, stack) {
      Error.throwWithStackTrace(
        KeyBrokerException(operation: operation),
        stack,
      );
    }
  }

  Future<Map<String, Object?>> _send(
    String operation,
    Map<String, Object?> body,
  ) async {
    final request =
        http.Request(
            'POST',
            _endpoint.resolve(operation),
          )
          ..followRedirects = false
          ..headers['Content-Type'] = 'application/json'
          ..bodyBytes = Uint8List.fromList(utf8.encode(jsonEncode(body)));

    final streamedResponse = await _client.send(request);
    final responseBytes = <int>[];
    await for (final chunk in streamedResponse.stream) {
      if (responseBytes.length + chunk.length > _maximumResponseBodyBytes) {
        throw KeyBrokerException(
          operation: operation,
          statusCode: streamedResponse.statusCode,
          reason: 'returned an invalid response',
        );
      }
      responseBytes.addAll(chunk);
    }

    if (streamedResponse.statusCode < _successfulStatusStart ||
        streamedResponse.statusCode >= _successfulStatusEndExclusive) {
      throw KeyBrokerException(
        operation: operation,
        statusCode: streamedResponse.statusCode,
        reason: 'rejected the request',
      );
    }

    try {
      final Object? decoded = jsonDecode(utf8.decode(responseBytes));
      if (decoded case final Map<Object?, Object?> values) {
        final result = <String, Object?>{};
        for (final MapEntry(:key, :value) in values.entries) {
          if (key is! String) throw const FormatException();
          result[key] = value;
        }

        return result;
      }
    } on FormatException {
      // Broker and proxy response bodies may contain secrets or internals.
    }

    throw KeyBrokerException(
      operation: operation,
      statusCode: streamedResponse.statusCode,
      reason: 'returned an invalid response',
    );
  }
}
