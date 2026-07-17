import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:signaling/src/application/key_broker_gateway.dart';
import 'package:signaling/src/assembly/key_broker_config.dart';
import 'package:signaling/src/data/http_key_broker_gateway.dart';
import 'package:signaling/src/data/local_key_broker_gateway.dart';

typedef KeyBrokerHttpClientFactory = http.Client Function();

/// Composes and owns the infrastructure used by a key-broker gateway.
final class KeyBrokerAssembly {
  final KeyBrokerGateway gateway;
  final http.Client? _ownedHttpClient;
  Future<void>? _disposeFuture;

  KeyBrokerAssembly._({
    required this.gateway,
    required this._ownedHttpClient,
  });

  /// Creates the gateway selected by [config].
  static KeyBrokerAssembly create(
    KeyBrokerConfig config, {
    KeyBrokerHttpClientFactory httpClientFactory = http.Client.new,
  }) {
    switch (config) {
      case LocalKeyBrokerConfig():
        return KeyBrokerAssembly._(
          gateway: LocalKeyBrokerGateway(),
          ownedHttpClient: null,
        );
      case HttpKeyBrokerConfig(:final endpoint, :final requestTimeout):
        _validateEndpoint(endpoint);
        if (requestTimeout <= Duration.zero) {
          throw ArgumentError.value(
            requestTimeout,
            'requestTimeout',
            'must be positive',
          );
        }

        final client = httpClientFactory();
        try {
          return KeyBrokerAssembly._(
            gateway: HttpKeyBrokerGateway(
              endpoint: endpoint,
              client: client,
              requestTimeout: requestTimeout,
            ),
            ownedHttpClient: client,
          );
        } catch (_) {
          client.close();
          rethrow;
        }
    }
  }

  /// Releases resources created by this assembly.
  Future<void> dispose() => _disposeFuture ??= Future<void>.sync(
    () => _ownedHttpClient?.close(),
  );

  static void _validateEndpoint(Uri endpoint) {
    final hasRootPath = endpoint.path.isEmpty || endpoint.path == '/';
    if (endpoint.scheme != 'https' ||
        !endpoint.hasAuthority ||
        endpoint.userInfo.isNotEmpty ||
        endpoint.hasQuery ||
        endpoint.hasFragment ||
        !hasRootPath) {
      throw ArgumentError.value(
        endpoint,
        'endpoint',
        'must be an HTTPS origin without credentials, query, or fragment',
      );
    }
  }
}
