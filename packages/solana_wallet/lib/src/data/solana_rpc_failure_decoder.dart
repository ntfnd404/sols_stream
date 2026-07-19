import 'package:solana/solana.dart' show JsonRpcException, TransactionError;

final class SolanaRpcFailureDecoder {
  const SolanaRpcFailureDecoder();

  SolanaRpcFailureDetails fromStatus(Map<String, Object?>? error) => _decode(
    error,
    transactionError: _transactionError(error),
  );

  SolanaRpcFailureDetails fromJsonRpc(JsonRpcException error) {
    final data = error.data;
    if (data is! Map) {
      return SolanaRpcFailureDetails(
        transactionError: error.transactionError,
      );
    }

    return _decode(
      data['err'],
      transactionError: _transactionError(data['err']) ?? error.transactionError,
      logs: _logs(data['logs']),
    );
  }

  SolanaRpcFailureDetails _decode(
    Object? error, {
    required TransactionError? transactionError,
    List<String> logs = const [],
  }) {
    final instructionError = error is Map ? error['InstructionError'] : null;
    if (instructionError is! List || instructionError.length < 2) {
      return SolanaRpcFailureDetails(
        transactionError: transactionError,
        logs: logs,
      );
    }
    final index = instructionError[0];
    final detail = instructionError[1];
    final custom = detail is Map ? detail['Custom'] : null;

    return SolanaRpcFailureDetails(
      failedInstructionIndex: index is int ? index : null,
      customProgramErrorCode: custom is int ? custom : null,
      transactionError: transactionError,
      logs: logs,
    );
  }

  TransactionError? _transactionError(Object? error) {
    final name = switch (error) {
      String() => error,
      Map() when error.length == 1 && error.keys.single is String => error.keys.single as String,
      _ => null,
    };
    if (name == null) return null;
    for (final value in TransactionError.values) {
      if (_pascalCase(value.name) == name) return value;
    }

    return null;
  }

  List<String> _logs(Object? value) => value is List ? List.unmodifiable(value.whereType<String>()) : const [];

  String _pascalCase(String value) => '${value[0].toUpperCase()}${value.substring(1)}';
}

final class SolanaRpcFailureDetails {
  final int? failedInstructionIndex;
  final int? customProgramErrorCode;
  final TransactionError? transactionError;
  final List<String> logs;

  SolanaRpcFailureDetails({
    this.failedInstructionIndex,
    this.customProgramErrorCode,
    this.transactionError,
    List<String> logs = const [],
  }) : logs = List.unmodifiable(logs);
}
