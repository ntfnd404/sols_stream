import 'package:test/test.dart';

import '../../../tool/idl/idl_fetch_options.dart';

void main() {
  const rpc = 'https://api.devnet.solana.com';

  test('uses explicit RPC and adapter-owned output defaults', () {
    final options = IdlFetchOptions.parse(
      ['--rpc-url', rpc, '--check'],
      environment: const {},
    );

    expect(options.rpcUrl, Uri.parse(rpc));
    expect(options.outputPath, IdlFetchOptions.defaultOutputPath);
    expect(options.checkOnly, isTrue);
  });

  test('falls back to SOLANA_RPC_URL', () {
    final options = IdlFetchOptions.parse(
      const [],
      environment: const {'SOLANA_RPC_URL': rpc},
    );

    expect(options.rpcUrl, Uri.parse(rpc));
  });

  test('rejects missing RPC, duplicates, and unknown options', () {
    expect(
      () => IdlFetchOptions.parse(const [], environment: const {}),
      throwsFormatException,
    );
    expect(
      () => IdlFetchOptions.parse(
        const ['--rpc-url', rpc, '--rpc-url', rpc],
        environment: const {},
      ),
      throwsFormatException,
    );
    expect(
      () => IdlFetchOptions.parse(
        const ['--cluster', 'devnet'],
        environment: const {'SOLANA_RPC_URL': rpc},
      ),
      throwsFormatException,
    );
  });
}
