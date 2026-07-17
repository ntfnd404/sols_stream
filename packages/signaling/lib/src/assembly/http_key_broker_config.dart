part of 'key_broker_config.dart';

const Duration defaultKeyBrokerRequestTimeout = Duration(seconds: 15);

/// Selects a remote HTTPS key broker.
final class HttpKeyBrokerConfig extends KeyBrokerConfig {
  final Uri endpoint;
  final Duration requestTimeout;

  const HttpKeyBrokerConfig({
    required this.endpoint,
    this.requestTimeout = defaultKeyBrokerRequestTimeout,
  });
}
