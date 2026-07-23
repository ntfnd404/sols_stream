import 'dart:async';

import 'package:http/http.dart' show ClientException;
import 'package:signaling/signaling.dart';
import 'package:solana/solana.dart' show JsonRpcErrorCode, JsonRpcException, RpcTimeoutException;

const _transientJsonRpcCodes = <int>{
  JsonRpcErrorCode.blockNotAvailable,
  JsonRpcErrorCode.nodeUnhealthy,
  JsonRpcErrorCode.noSnapshot,
  JsonRpcErrorCode.blockStatusNotAvailableYet,
  JsonRpcErrorCode.minContextSlotNotReached,
};

/// Maps only explicitly retryable Solana read failures to the signaling marker.
Future<T> classifySolanaRpcRead<T>(Future<T> Function() operation) async {
  try {
    return await operation();
  } on RpcTimeoutException catch (_, stackTrace) {
    Error.throwWithStackTrace(
      const TransientSignalingReadException(),
      stackTrace,
    );
  } on TimeoutException catch (_, stackTrace) {
    Error.throwWithStackTrace(
      const TransientSignalingReadException(),
      stackTrace,
    );
  } on ClientException catch (_, stackTrace) {
    Error.throwWithStackTrace(
      const TransientSignalingReadException(),
      stackTrace,
    );
  } on JsonRpcException catch (error, stackTrace) {
    if (_transientJsonRpcCodes.contains(error.code)) {
      Error.throwWithStackTrace(
        const TransientSignalingReadException(),
        stackTrace,
      );
    }
    Error.throwWithStackTrace(
      const SignalingReadFailureException(),
      stackTrace,
    );
  } on Exception catch (_, stackTrace) {
    Error.throwWithStackTrace(
      const SignalingReadFailureException(),
      stackTrace,
    );
  }
}
