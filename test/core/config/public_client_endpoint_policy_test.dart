import 'package:flutter_test/flutter_test.dart';
import 'package:sols_stream/core/config/configuration_error.dart';
import 'package:sols_stream/core/config/public_client_endpoint_policy.dart';

void main() {
  test('RPC endpoints are public HTTP origins', () {
    for (final value in [
      'relative',
      'ftp://rpc.example.com',
      'https://user@rpc.example.com',
      'https://rpc.example.com/private-token',
      'https://rpc.example.com?token=secret',
      'https://rpc.example.com#fragment',
    ]) {
      expect(
        () => PublicClientEndpointPolicy.parse(
          key: 'SOLANA_RPC_URL',
          value: value,
          kind: PublicClientEndpointKind.rpc,
        ),
        throwsA(isA<ConfigurationError>()),
      );
    }

    expect(
      PublicClientEndpointPolicy.parse(
        key: 'SOLANA_RPC_URL',
        value: 'https://rpc.example.com/',
        kind: PublicClientEndpointKind.rpc,
      ),
      Uri.parse('https://rpc.example.com/'),
    );
  });

  test('faucet endpoints may have a public path but no credentials', () {
    expect(
      PublicClientEndpointPolicy.parse(
        key: 'SOLANA_FAUCET_URL',
        value: 'https://faucet.example.com/fund',
        kind: PublicClientEndpointKind.faucet,
      ),
      Uri.parse('https://faucet.example.com/fund'),
    );
    expect(
      () => PublicClientEndpointPolicy.parse(
        key: 'SOLANA_FAUCET_URL',
        value: 'https://faucet.example.com/fund?token=secret',
        kind: PublicClientEndpointKind.faucet,
      ),
      throwsA(isA<ConfigurationError>()),
    );
  });
}
