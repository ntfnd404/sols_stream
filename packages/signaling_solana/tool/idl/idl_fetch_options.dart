import 'package:signaling_solana/src/generated/sols_stream_solana.dart';

/// Validated configuration for the on-chain IDL command.
final class IdlFetchOptions {
  /// Human-readable command contract emitted for help and usage failures.
  static const String usage = '''
Usage: dart run packages/signaling_solana/tool/fetch_idl.dart [options]

Options:
  --rpc-url <url>         Solana RPC URL. Defaults to SOLANA_RPC_URL.
  --program-id <address>  Program address. Defaults to the signaling program.
  --out <path>            Output JSON path. Defaults to the adapter-owned IDL.
  --check                 Compare without writing; exits 1 when out of date.
  --help, -h              Show this help.
''';

  /// Versioned adapter-owned output used when `--out` is absent.
  static const String defaultOutputPath = 'packages/signaling_solana/idl/sols_stream.json';

  /// RPC endpoint from which the deployed Anchor IDL is read.
  final Uri rpcUrl;

  /// Solana program whose Anchor IDL account is derived.
  final String programId;

  /// Versioned JSON artifact path.
  final String outputPath;

  /// Whether drift is reported without updating [outputPath].
  final bool checkOnly;

  /// Creates validated fetch options.
  const IdlFetchOptions({
    required this.rpcUrl,
    required this.programId,
    required this.outputPath,
    required this.checkOnly,
  });

  /// Parses CLI options and uses `SOLANA_RPC_URL` only when `--rpc-url` is absent.
  static IdlFetchOptions parse(
    List<String> arguments, {
    required Map<String, String> environment,
  }) {
    String? rpcUrl;
    var programId = SolsStreamProgram.programAddress.toBase58();
    var outputPath = defaultOutputPath;
    var checkOnly = false;
    final seen = <String>{};

    for (var index = 0; index < arguments.length; index += 1) {
      final argument = arguments[index];
      if (!seen.add(argument)) {
        throw FormatException('Duplicate option: $argument');
      }
      switch (argument) {
        case '--rpc-url':
          rpcUrl = _readValue(arguments, ++index, argument);
        case '--program-id':
          programId = _readValue(arguments, ++index, argument);
        case '--out':
          outputPath = _readValue(arguments, ++index, argument);
        case '--check':
          checkOnly = true;
        default:
          throw FormatException('Unknown option: $argument');
      }
    }

    final resolvedRpc = rpcUrl ?? environment['SOLANA_RPC_URL']?.trim();
    final uri = Uri.tryParse(resolvedRpc ?? '');
    if (uri == null || !uri.hasScheme || !uri.hasAuthority || (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw const FormatException(
        'Missing or invalid RPC URL. Use --rpc-url or SOLANA_RPC_URL.',
      );
    }
    if (outputPath.trim().isEmpty) {
      throw const FormatException('IDL output path must not be empty.');
    }

    return IdlFetchOptions(
      rpcUrl: uri,
      programId: programId,
      outputPath: outputPath,
      checkOnly: checkOnly,
    );
  }

  static String _readValue(
    List<String> arguments,
    int index,
    String option,
  ) {
    if (index >= arguments.length || arguments[index].startsWith('--')) {
      throw FormatException('Missing value for $option');
    }
    final value = arguments[index].trim();
    if (value.isEmpty) {
      throw FormatException('Empty value for $option');
    }

    return value;
  }
}
