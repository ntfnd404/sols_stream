import 'dart:typed_data';

import 'package:signaling/signaling.dart';
import 'package:signaling_solana/src/data/solana_program/solana_protected_slot_gateway.dart';
import 'package:signaling_solana/src/data/solana_transaction_coordinator.dart';
import 'package:signaling_solana/src/generated/sols_stream_solana.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';
import 'package:solana_wallet/solana_wallet.dart';
import 'package:test/test.dart';

import 'fakes/recording_signer.dart';

Ed25519HDPublicKey _key(int fill) => Ed25519HDPublicKey(List<int>.filled(32, fill));

Account _account(List<int> data) => Account(
  lamports: 1,
  owner: SolsStreamProgram.programAddress.toBase58(),
  data: BinaryAccountData(data),
  executable: false,
  rentEpoch: BigInt.zero,
);

List<int> _userData(SolsStreamAddress room) {
  final writer = SolsStreamBorshWriter()
    ..writeBytes(SolsStreamUserAccount.discriminator)
    ..writeBytes(_key(1).bytes)
    ..writeString('host');
  SolsStreamUserRole.codec.write(writer, const SolsStreamUserRoleHost());
  writer
    ..writeBytes(room.bytes)
    ..writeBytes(List<int>.filled(32, 0))
    ..writeSigned(BigInt.zero, 8)
    ..writeSigned(BigInt.zero, 8)
    ..writeSigned(BigInt.zero, 8)
    ..writeUnsigned(BigInt.one, 4);

  return writer.takeBytes();
}

List<int> _slotData(SolsStreamAddress room) => [
  ...SolsStreamConnectSlotAccount.discriminator,
  ...SolsStreamConnectSlot.codec.encode(
    SolsStreamConnectSlot(
      room: room,
      host: SolsStreamAddress.fromBytes(_key(1).bytes),
      viewer: SolsStreamAddress.fromBytes(List<int>.filled(32, 0)),
      hostDeposit: BigInt.one,
      viewerDeposit: BigInt.zero,
      hostProtectedKey: const [],
      offerData: const [],
      viewerProtectedKey: const [],
      answerData: const [],
      state: const SolsStreamSlotStateOpen(),
      createdAt: BigInt.zero,
      expiresAt: BigInt.from(
        DateTime.now().millisecondsSinceEpoch ~/ 1000 + 120,
      ),
      bump: 1,
      hostRentPaid: BigInt.zero,
      viewerRentPaid: BigInt.zero,
      accessPrice: BigInt.zero,
      hostConfirmed: false,
      viewerConfirmed: false,
    ),
  ),
];

// Test-local RPC seam for account discovery behavior.
// ignore: prefer-match-file-name
final class _DiscoveryRpcClient implements RpcClient {
  final List<int> userData;
  final List<ProgramAccount> programAccounts;

  _DiscoveryRpcClient({required this.userData, required this.programAccounts});

  @override
  Future<AccountResult> getAccountInfo(
    String pubKey, {
    Commitment commitment = Commitment.finalized,
    Encoding? encoding,
    DataSlice? dataSlice,
    num? minContextSlot,
  }) async => AccountResult(
    context: Context(slot: BigInt.zero),
    value: _account(userData),
  );

  @override
  Future<List<ProgramAccount>> getProgramAccounts(
    String pubKey, {
    Commitment? commitment = Commitment.finalized,
    required Encoding encoding,
    DataSlice? dataSlice,
    List<ProgramDataFilter>? filters,
    bool? withContext,
    num? minContextSlot,
  }) async => programAccounts;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Test-local counter for transaction-boundary funding checks.
// ignore: prefer-match-file-name
final class _RecordingFundingService implements SolanaFundingService {
  final bool result;
  int calls = 0;

  _RecordingFundingService(this.result);

  @override
  Future<bool> ensureFunded() async {
    calls += 1;

    return result;
  }
}

void main() {
  test('skips malformed scanned accounts and returns the next valid slot', () async {
    final room = SolsStreamAddress.fromBytes(_key(2).bytes);
    final slotPda = _key(3).toBase58();
    final rpc = _DiscoveryRpcClient(
      userData: _userData(room),
      programAccounts: [
        ProgramAccount(
          pubkey: _key(4).toBase58(),
          account: _account([
            ...SolsStreamConnectSlotAccount.discriminator,
            1,
          ]),
        ),
        ProgramAccount(
          pubkey: slotPda,
          account: _account(_slotData(room)),
        ),
      ],
    );
    final funding = _RecordingFundingService(false);
    final transactions = SolanaTransactionCoordinator(
      signer: RecordingSigner(_key(9)),
      funding: funding,
    );
    final gateway = SolanaProtectedSlotGateway(
      transactions.fundedSigner,
      rpc,
    );

    final result = await gateway.discoverOpenSlot(_key(1).toBase58());

    expect(result, isA<DiscoveredSlot>());
    expect((result as DiscoveredSlot).slotPda, slotPda);
    expect(funding.calls, 0, reason: 'read-only discovery must not fund');
  });

  test('skips wrong-owner scan entries with sanitized diagnostics', () async {
    final room = SolsStreamAddress.fromBytes(_key(2).bytes);
    final wrongOwner = Account(
      lamports: 1,
      owner: _key(8).toBase58(),
      data: BinaryAccountData(_slotData(room)),
      executable: false,
      rentEpoch: BigInt.zero,
    );
    final validPda = _key(3).toBase58();
    final diagnostics = <String>[];
    final gateway = SolanaProtectedSlotGateway(
      RecordingSigner(_key(9)),
      _DiscoveryRpcClient(
        userData: _userData(room),
        programAccounts: [
          ProgramAccount(pubkey: _key(4).toBase58(), account: wrongOwner),
          ProgramAccount(
            pubkey: validPda,
            account: _account(_slotData(room)),
          ),
        ],
      ),
      diagnostics: diagnostics.add,
    );

    final result = await gateway.discoverOpenSlot(_key(1).toBase58());

    expect((result as DiscoveredSlot).slotPda, validPda);
    expect(diagnostics, ['slot.discovery.skipped type=SolsStreamAccountIntegrityException']);
  });

  test('does not treat a malformed known User PDA as no live room', () async {
    final gateway = SolanaProtectedSlotGateway(
      RecordingSigner(_key(9)),
      _DiscoveryRpcClient(
        userData: SolsStreamUserAccount.discriminator,
        programAccounts: const [],
      ),
    );

    await expectLater(
      gateway.discoverOpenSlot(_key(1).toBase58()),
      throwsA(isA<SolsStreamBorshException>()),
    );
  });

  test('checks funding before every chunk transaction', () async {
    final room = SolsStreamAddress.fromBytes(_key(2).bytes);
    final rpc = _DiscoveryRpcClient(
      userData: _userData(room),
      programAccounts: const [],
    );
    final delegate = RecordingSigner(_key(9));
    final funding = _RecordingFundingService(true);
    final transactions = SolanaTransactionCoordinator(
      signer: delegate,
      funding: funding,
    );
    final gateway = SolanaProtectedSlotGateway(
      transactions.fundedSigner,
      rpc,
    );

    await gateway.writeOfferWithProtectedKey(
      slotPda: _key(3).toBase58(),
      protectedKey: 'protected',
      payload: Uint8List(1601),
    );

    expect(delegate.sent, hasLength(4));
    expect(funding.calls, delegate.sent.length);
  });
}
