import 'package:solana/dto.dart' show LatestBlockhash;
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';
import 'package:solana_wallet/src/data/funding/solana_funding_gateway.dart';
import 'package:solana_wallet/src/data/solana_rpc_failure_decoder.dart';
import 'package:solana_wallet/src/data/solana_transaction_confirmer.dart';
import 'package:solana_wallet/src/domain/solana_funding_service.dart';
import 'package:solana_wallet/src/domain/solana_signer.dart';
import 'package:solana_wallet/src/domain/solana_transaction_exception.dart';
import 'package:solana_wallet/src/domain/solana_wallet_read_exception.dart';
import 'package:solana_wallet/src/domain/solana_wallet_reader.dart';

/// Data-layer adapter implementing the wallet's published ports over a Solana
/// [RpcClient] and a locally-held keypair.
///
/// The private key lives inside [_keypair] and is never exposed — callers get
/// [SolanaSigner], [SolanaWalletReader], or [SolanaFundingService], never the
/// key or the [RpcClient].
final class SolanaWallet implements SolanaSigner, SolanaWalletReader, SolanaFundingService {
  final Ed25519HDKeyPair _keypair;
  final RpcClient _rpc;
  final SolanaFundingGateway _fundingGateway;
  final SolanaTransactionConfirmer _transactionConfirmer;
  final SolanaRpcFailureDecoder _failureDecoder;

  @override
  Ed25519HDPublicKey get publicKey => _keypair.publicKey;

  @override
  String get address => _keypair.publicKey.toBase58();

  SolanaWallet(
    this._keypair,
    this._rpc,
    this._fundingGateway,
  ) : _transactionConfirmer = SolanaTransactionConfirmer(_rpc),
      _failureDecoder = const SolanaRpcFailureDecoder();

  @override
  Future<int> getBalanceLamports() async {
    try {
      final balance = await _rpc.getBalance(
        address,
        commitment: Commitment.confirmed,
      );

      return balance.value;
    } on Exception catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const SolanaWalletReadException(),
        stackTrace,
      );
    }
  }

  @override
  Future<bool> ensureFunded() => _fundingGateway.ensureFunded(address);

  @override
  Future<String> signAndSend(List<Instruction> instructions) async {
    final latestBlockhash = await _latestBlockhash();
    final signed = await signTransaction(
      latestBlockhash,
      Message(instructions: instructions),
      [_keypair],
    );
    final signature = signed.id;

    try {
      await _rpc.sendTransaction(
        signed.encode(),
        preflightCommitment: SolanaTransactionConfirmer.commitment,
      );
    } on JsonRpcException catch (error) {
      if (error.code == JsonRpcErrorCode.sendTransactionPreflightFailure) {
        final details = _failureDecoder.fromJsonRpc(error);
        if (details.transactionError == TransactionError.alreadyProcessed) {
          // The cluster already knows this transaction ID. Observe the exact
          // signature instead of treating the response as rejection.
        } else if (details.transactionError == TransactionError.blockhashNotFound) {
          throw SolanaTransactionException.expired(signature: signature);
        } else {
          throw SolanaTransactionException.submissionRejected(
            signature: signature,
            failedInstructionIndex: details.failedInstructionIndex,
            customProgramErrorCode: details.customProgramErrorCode,
            transactionError: details.transactionError,
            logs: details.logs,
          );
        }
      } else {
        final details = _failureDecoder.fromJsonRpc(error);
        throw SolanaTransactionException.submissionRejected(
          signature: signature,
          failedInstructionIndex: details.failedInstructionIndex,
          customProgramErrorCode: details.customProgramErrorCode,
          transactionError: details.transactionError,
          logs: details.logs,
        );
      }
    } on Exception {
      // Transport and protocol failures after signing are indeterminate. The
      // same signature remains the only safe transaction to observe.
    }

    await _transactionConfirmer.confirm(
      signature: signature,
      lastValidBlockHeight: latestBlockhash.lastValidBlockHeight,
    );

    return signature;
  }

  Future<LatestBlockhash> _latestBlockhash() async {
    try {
      final result = await _rpc.getLatestBlockhash(
        commitment: SolanaTransactionConfirmer.commitment,
      );

      return result.value;
    } on Exception {
      throw SolanaTransactionException.transport();
    }
  }

  @override
  Future<String> signForProof(List<Instruction> instructions) async {
    final blockhash = await _rpc.getLatestBlockhash(
      commitment: Commitment.processed,
    );
    final signed = await _keypair.signMessage(
      message: Message(instructions: instructions),
      recentBlockhash: blockhash.value.blockhash,
    );

    return signed.encode();
  }
}
