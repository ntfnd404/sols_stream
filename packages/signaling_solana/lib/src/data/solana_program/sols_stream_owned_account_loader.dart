import 'package:signaling_solana/src/data/solana_program/solana_rpc_read_error_classifier.dart';
import 'package:signaling_solana/src/data/solana_program/sols_stream_account_integrity_exception.dart';
import 'package:signaling_solana/src/generated/sols_stream_solana.dart';
import 'package:solana/dto.dart' show Account, BinaryAccountData, Encoding;
import 'package:solana/solana.dart' show Commitment, RpcClient;

/// Loads and validates the transport envelope of sols_stream accounts.
final class SolsStreamOwnedAccountLoader {
  final RpcClient _reader;

  const SolsStreamOwnedAccountLoader(this._reader);

  Future<List<int>?> load(String address, {required String accountName}) async {
    final result = await classifySolanaRpcRead(
      () => _reader.getAccountInfo(
        address,
        commitment: Commitment.confirmed,
        encoding: Encoding.base64,
      ),
    );
    final account = result.value;
    if (account == null) return null;

    return dataFor(account, accountName: accountName);
  }

  List<int> dataFor(Account account, {required String accountName}) {
    if (account.owner != SolsStreamProgram.programAddress.toBase58()) {
      throw SolsStreamAccountIntegrityException(
        accountName: accountName,
        message: 'owner does not match the configured program',
      );
    }
    final data = account.data;
    if (data is! BinaryAccountData) {
      throw SolsStreamAccountIntegrityException(
        accountName: accountName,
        message: 'RPC returned a non-binary account representation',
      );
    }

    return data.data;
  }
}
