import 'dart:io';

import 'package:solana/solana.dart';

import 'idl/anchor_idl_fetcher.dart';
import 'idl/idl_fetch_options.dart';
import 'idl/idl_file_synchronizer.dart';

/// BSD `EX_USAGE`, returned for an invalid command line.
const int _usageExitCode = 64;

/// Conventional non-zero failure for a valid command that could not complete.
const int _operationFailureExitCode = 1;

/// Refreshes or verifies the versioned IDL owned by `signaling_solana`.
Future<void> main(List<String> arguments) async {
  if (arguments.contains('--help') || arguments.contains('-h')) {
    stdout.writeln(IdlFetchOptions.usage);

    return;
  }

  try {
    final options = IdlFetchOptions.parse(
      arguments,
      environment: Platform.environment,
    );
    final rpc = RpcClient(options.rpcUrl.toString());
    final idl = await AnchorIdlFetcher(rpc).fetch(programId: options.programId);
    final result = await synchronizeIdlFile(
      output: File(options.outputPath),
      idl: idl,
      checkOnly: options.checkOnly,
    );
    final instructionCount = (idl['instructions'] as List<dynamic>?)?.length ?? 0;

    switch (result) {
      case IdlSyncResult.unchanged:
        stdout.writeln(
          'IDL is up to date: ${options.outputPath} '
          '($instructionCount instructions)',
        );
      case IdlSyncResult.written:
        stdout.writeln(
          'Updated ${options.outputPath} '
          '($instructionCount instructions)',
        );
      case IdlSyncResult.outOfDate:
        stderr.writeln(
          'IDL is out of date: ${options.outputPath}. '
          'Run make fetch-idl.',
        );
        exitCode = _operationFailureExitCode;
    }
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln(IdlFetchOptions.usage);
    exitCode = _usageExitCode;
  } on Object catch (error) {
    stderr.writeln('IDL operation failed (${error.runtimeType}).');
    exitCode = _operationFailureExitCode;
  }
}
