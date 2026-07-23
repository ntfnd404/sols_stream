import 'package:signaling_solana/src/generated/sols_stream_solana.dart';
import 'package:solana/solana.dart' show JsonRpcException;
import 'package:solana_wallet/solana_signer.dart';

final class SolsStreamProgramErrorAdapter {
  const SolsStreamProgramErrorAdapter();

  SolsStreamProgramException? decode(Object error) {
    final details = switch (error) {
      SolanaTransactionException() => (
        code: error.customProgramErrorCode,
        logs: error.logs,
        signature: error.signature,
      ),
      JsonRpcException() => (
        code: _customCode(error.data),
        logs: _logs(error.data),
        signature: null,
      ),
      _ => (code: null, logs: const <String>[], signature: null),
    };
    final parsed = SolsStreamProgramErrorParser.parseLogs(
      details.logs,
      signature: details.signature,
    );
    if (parsed != null) return parsed;
    final code = details.code;

    return code == null
        ? null
        : SolsStreamProgramErrorParser.fromCode(
            code,
            logs: details.logs,
            signature: details.signature,
          );
  }

  int? _customCode(Object? data) {
    if (data is! Map) return null;
    final err = data['err'];
    final instructionError = err is Map ? err['InstructionError'] : data['InstructionError'];
    if (instructionError is! List || instructionError.length < 2) return null;
    final detail = instructionError[1];
    if (detail is! Map) return null;
    final custom = detail['Custom'];

    return custom is int ? custom : null;
  }

  List<String> _logs(Object? data) {
    if (data is! Map) return const [];
    final logs = data['logs'];
    if (logs is! List) return const [];

    return List.unmodifiable(logs.whereType<String>());
  }
}
