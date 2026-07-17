import 'package:signaling_solana/src/data/solana_program/sols_stream_account_integrity_exception.dart';
import 'package:signaling_solana/src/data/solana_program/sols_stream_owned_account_loader.dart';
import 'package:signaling_solana/src/generated/sols_stream_solana.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';
import 'package:test/test.dart';

final class _UnusedRpcClient implements RpcClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Account _account({required String owner, required AccountData data}) => Account(
  lamports: 1,
  owner: owner,
  data: data,
  executable: false,
  rentEpoch: BigInt.zero,
);

void main() {
  final loader = SolsStreamOwnedAccountLoader(_UnusedRpcClient());
  final program = SolsStreamProgram.programAddress.toBase58();

  test('returns bytes only for a binary program-owned account', () {
    expect(
      loader.dataFor(
        _account(owner: program, data: const BinaryAccountData([1, 2, 3])),
        accountName: 'ConnectSlot',
      ),
      [1, 2, 3],
    );
  });

  test('rejects wrong owner and non-binary representations', () {
    final accounts = [
      _account(
        owner: Ed25519HDPublicKey(List<int>.filled(32, 9)).toBase58(),
        data: const BinaryAccountData([1]),
      ),
      _account(owner: program, data: const EmptyAccountData()),
    ];

    for (final account in accounts) {
      expect(
        () => loader.dataFor(account, accountName: 'ConnectSlot'),
        throwsA(isA<SolsStreamAccountIntegrityException>()),
      );
    }
  });
}
