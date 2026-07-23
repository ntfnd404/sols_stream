import 'package:solana/solana.dart' show TransactionError;
import 'package:solana_wallet/src/domain/solana_transaction_failure_kind.dart';

/// Structured transaction failure without exposing raw JSON-RPC payloads.
final class SolanaTransactionException implements Exception {
  final SolanaTransactionFailureKind kind;
  final String message;
  final String? signature;
  final int? failedInstructionIndex;
  final int? customProgramErrorCode;
  final TransactionError? transactionError;
  final List<String> logs;

  SolanaTransactionException._({
    required this.kind,
    required this.message,
    this.signature,
    this.failedInstructionIndex,
    this.customProgramErrorCode,
    this.transactionError,
    List<String> logs = const [],
  }) : logs = List.unmodifiable(logs);

  factory SolanaTransactionException.submissionRejected({
    required String signature,
    int? failedInstructionIndex,
    int? customProgramErrorCode,
    TransactionError? transactionError,
    List<String> logs = const [],
  }) => SolanaTransactionException._(
    kind: SolanaTransactionFailureKind.submissionRejected,
    message: 'transaction submission rejected',
    signature: signature,
    failedInstructionIndex: failedInstructionIndex,
    customProgramErrorCode: customProgramErrorCode,
    transactionError: transactionError,
    logs: logs,
  );

  factory SolanaTransactionException.failedOnChain({
    required String signature,
    int? failedInstructionIndex,
    int? customProgramErrorCode,
    TransactionError? transactionError,
    List<String> logs = const [],
  }) => SolanaTransactionException._(
    kind: SolanaTransactionFailureKind.failedOnChain,
    message: 'transaction failed on-chain',
    signature: signature,
    failedInstructionIndex: failedInstructionIndex,
    customProgramErrorCode: customProgramErrorCode,
    transactionError: transactionError,
    logs: logs,
  );

  factory SolanaTransactionException.expired({
    required String signature,
  }) => SolanaTransactionException._(
    kind: SolanaTransactionFailureKind.expired,
    message: 'transaction expired before confirmation',
    signature: signature,
  );

  factory SolanaTransactionException.transport({
    String? signature,
  }) => SolanaTransactionException._(
    kind: SolanaTransactionFailureKind.transport,
    message: 'transaction transport failed',
    signature: signature,
  );

  @override
  String toString() => 'SolanaTransactionException(${kind.name}): $message';
}
