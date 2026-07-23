import 'dart:typed_data';

import 'package:signaling/signaling.dart';
import 'package:signaling_solana/src/data/solana_program/signaling_protocol_constants.dart';
import 'package:signaling_solana/src/data/solana_program/solana_signaling_chain_gateway.dart';
import 'package:signaling_solana/src/data/solana_program/sols_stream_instruction_factory.dart';
import 'package:signaling_solana/src/data/solana_transaction_coordinator.dart';
import 'package:signaling_solana/src/generated/sols_stream_solana.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';
import 'package:solana_wallet/solana_wallet.dart';
import 'package:test/test.dart';

import 'fakes/recording_signer.dart';

Ed25519HDPublicKey _key(int fill) => Ed25519HDPublicKey(List.filled(32, fill));

Uint8List _u64le(int value) => (ByteData(8)..setUint64(0, value, Endian.little)).buffer.asUint8List();

Uint8List _i64le(int value) => (ByteData(8)..setInt64(0, value, Endian.little)).buffer.asUint8List();

Uint8List _userBlob({
  int role = 0,
  int streamCount = 0,
  int turnExpiresAt = 0,
}) {
  final nick = SignalingProtocolConstants.defaultNickname.codeUnits;
  final nickLen = ByteData(4)..setUint32(0, nick.length, Endian.little);

  return (BytesBuilder()
        ..add(SolsStreamUserAccount.discriminator)
        ..add(List.filled(32, 0))
        ..add(nickLen.buffer.asUint8List())
        ..add(nick)
        ..addByte(role)
        ..add(List.filled(32, 0))
        ..add(List.filled(32, 0))
        ..add(List.filled(8, 0))
        ..add(List.filled(8, 0))
        ..add(_i64le(turnExpiresAt))
        ..add((ByteData(4)..setUint32(0, streamCount, Endian.little)).buffer.asUint8List()))
      .toBytes();
}

Uint8List _configBlob({required Ed25519HDPublicKey serviceWallet}) =>
    (BytesBuilder()
          ..add(SolsStreamProgramConfigAccount.discriminator)
          ..add(List.filled(32, 1))
          ..add(serviceWallet.bytes)
          ..add(_u64le(100))
          ..add(_u64le(0))
          ..add(_u64le(300))
          ..add(_u64le(60))
          ..addByte(253))
        .toBytes();

AccountResult _accountResult(Uint8List? data) => AccountResult(
  context: Context(slot: BigInt.zero),
  value: data == null
      ? null
      : Account(
          lamports: 1,
          owner: SolsStreamProgram.programAddress.toBase58(),
          data: BinaryAccountData(data),
          executable: false,
          rentEpoch: BigInt.zero,
        ),
);

List<int> _disc(RecordingSigner signer, int sendIndex) => signer.sent[sendIndex].single.data.toList().take(8).toList();

// Test-local fake intentionally stays beside the scenarios that exercise it.
// ignore: prefer-match-file-name
final class _FakeRpcClient implements RpcClient {
  final Map<String, Uint8List?> accounts;
  final List<Commitment> accountReadCommitments = [];

  _FakeRpcClient(this.accounts);

  @override
  Future<AccountResult> getAccountInfo(
    String pubKey, {
    Commitment commitment = Commitment.finalized,
    Encoding? encoding,
    DataSlice? dataSlice,
    num? minContextSlot,
  }) async {
    accountReadCommitments.add(commitment);

    return _accountResult(accounts[pubKey]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Test-local guard used to prove cleanup bypasses funding.
final class _FailIfCalledFundingService implements SolanaFundingService {
  int calls = 0;

  @override
  Future<bool> ensureFunded() async {
    calls += 1;

    return false;
  }
}

void main() {
  final host = _key(1);
  final serviceWallet = _key(5);
  late _FakeRpcClient reader;

  Future<SolanaSignalingChainGateway> gateway(
    RecordingSigner signer, {
    required Uint8List? user,
    Uint8List? config,
    SignalingDiagnostics diagnostics = noOpSignalingDiagnostics,
  }) async {
    final instructions = SolsStreamInstructionFactory();
    final userPda = await instructions.deriveUserPda(host);
    final configPda = await instructions.deriveConfigPda();

    reader = _FakeRpcClient({
      userPda.toBase58(): user,
      configPda.toBase58(): config,
    });

    return SolanaSignalingChainGateway(
      signer,
      reader,
      cleanupSigner: signer,
      instructionFactory: instructions,
      diagnostics: diagnostics,
    );
  }

  group('SolanaSignalingChainGateway TURN entitlement', () {
    test('purchases TURN before create_room when entitlement is missing', () async {
      final diagnostics = <String>[];
      final signer = RecordingSigner(host);
      final chain = await gateway(
        signer,
        user: _userBlob(streamCount: 7),
        config: _configBlob(serviceWallet: serviceWallet),
        diagnostics: diagnostics.add,
      );

      final addresses = await chain.openSignalingSlot(slotNonce: 42);

      expect(addresses.roomNonce, 7);
      expect(signer.sent, hasLength(3));
      expect(_disc(signer, 0), SolsStreamPurchaseTurnRequest.discriminator);
      expect(_disc(signer, 1), SolsStreamCreateRoomRequest.discriminator);
      expect(_disc(signer, 2), SolsStreamOpenConnectSlotRequest.discriminator);
      expect(reader.accountReadCommitments, everyElement(Commitment.confirmed));
      expect(
        diagnostics,
        containsAllInOrder([
          'chain.user.idle',
          'chain.turn_entitlement.purchase_required',
          'chain.turn_entitlement.purchase.confirmed',
          'chain.room_create.confirmed',
          'chain.slot_create.confirmed',
          'chain.slot_open.completed',
        ]),
      );
    });

    test('does not purchase TURN when entitlement is active', () async {
      final signer = RecordingSigner(host);
      final chain = await gateway(
        signer,
        user: _userBlob(streamCount: 3, turnExpiresAt: 4102444800), // 2100-01-01
        config: _configBlob(serviceWallet: serviceWallet),
      );

      final addresses = await chain.openSignalingSlot(slotNonce: 42);

      expect(addresses.roomNonce, 3);
      expect(signer.sent, hasLength(2));
      expect(_disc(signer, 0), SolsStreamCreateRoomRequest.discriminator);
      expect(_disc(signer, 1), SolsStreamOpenConnectSlotRequest.discriminator);
    });

    test('fails with a clear error when TURN must be purchased but ProgramConfig is unavailable', () async {
      final signer = RecordingSigner(host);
      final chain = await gateway(
        signer,
        user: _userBlob(streamCount: 3),
      );

      await expectLater(
        chain.openSignalingSlot(slotNonce: 42),
        throwsA(isA<StateError>()),
      );
      expect(signer.sent, isEmpty);
    });
  });

  test('end and close use the unfunded cleanup signer', () async {
    final delegate = RecordingSigner(host);
    final funding = _FailIfCalledFundingService();
    final transactions = SolanaTransactionCoordinator(
      signer: delegate,
      funding: funding,
    );
    final chain = SolanaSignalingChainGateway(
      transactions.fundedSigner,
      _FakeRpcClient(const {}),
      cleanupSigner: transactions.bypassSigner,
    );
    final room = _key(8).toBase58();

    await chain.endRoom(room);
    await chain.closeRoom(room);

    expect(funding.calls, 0);
    expect(delegate.sent, hasLength(2));
  });
}
