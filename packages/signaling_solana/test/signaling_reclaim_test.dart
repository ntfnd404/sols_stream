import 'dart:typed_data';

import 'package:signaling/signaling.dart';
import 'package:signaling_solana/src/data/solana_program/solana_signaling_reclaim_gateway.dart';
import 'package:signaling_solana/src/generated/sols_stream_solana.dart';
import 'package:solana/solana.dart';
import 'package:solana_wallet/solana_signer.dart';
import 'package:test/test.dart';

import 'fakes/reclaim_chain_gateway.dart';
import 'fakes/recording_signer.dart';

Ed25519HDPublicKey _key(int fill) => Ed25519HDPublicKey(List.filled(32, fill));

String _pda(int fill) => _key(fill).toBase58();

ProgramConfig _config(Ed25519HDPublicKey serviceWallet) => ProgramConfig(
  serviceWallet: Uint8List.fromList(serviceWallet.bytes),
  turnPriceLamports: BigInt.zero,
  minHeartbeatIntervalSeconds: 60,
);

ConnectSlotData _slot({Uint8List? viewer}) => ConnectSlotData(
  room: Uint8List(32),
  host: Uint8List(32),
  viewer: viewer ?? Uint8List.fromList(List.filled(32, 7)),
  hostProtectedKey: Uint8List(0),
  viewerProtectedKey: Uint8List(0),
  offerData: Uint8List(0),
  answerData: Uint8List(0),
  state: ConnectSlotState.connected,
  createdAt: BigInt.zero,
  expiresAt: BigInt.zero,
  hostDeposit: BigInt.zero,
  viewerDeposit: BigInt.zero,
  hostRentPaid: BigInt.zero,
  viewerRentPaid: BigInt.zero,
  accessPrice: BigInt.zero,
  hostConfirmed: true,
  viewerConfirmed: true,
);

/// A `JsonRpcException` whose payload carries an Anchor custom-error [code], as
/// the `solana` package surfaces a failed instruction.
JsonRpcException _customError(int code) => JsonRpcException(
  'preflight failure',
  -32002,
  {
    'err': {
      'InstructionError': [
        0,
        {'Custom': code},
      ],
    },
  },
);

int get _depositMismatchCode => SolsStreamProgramErrorParser.codeForName('DepositMismatch')!;

int get _roomAlreadyEndedCode => SolsStreamProgramErrorParser.codeForName('RoomAlreadyEnded')!;

SolanaSignalingReclaimGateway _gateway(
  RecordingSigner signer,
  ReclaimChainGateway chain, {
  int maxAttempts = SolanaSignalingReclaimGateway.defaultMaxAttempts,
}) => SolanaSignalingReclaimGateway(
  signer,
  chain,
  maxAttempts: maxAttempts,
  retryBackoff: Duration.zero,
);

void main() {
  final host = _key(1);
  final serviceWallet = _key(5);
  final slotPda = _pda(2);
  final roomPda = _pda(6);

  group('service_wallet resolution + caching', () {
    test('fetches ProgramConfig once and reuses it across closes', () async {
      final signer = RecordingSigner(host);
      final chain = ReclaimChainGateway(
        config: _config(serviceWallet),
        slots: [_slot(), _slot()],
      );
      final gateway = _gateway(signer, chain);

      expect(
        await gateway.closeConnectSlot(slotPda: slotPda),
        ReclaimOutcome.succeeded,
      );
      expect(
        await gateway.closeConnectSlot(slotPda: slotPda),
        ReclaimOutcome.succeeded,
      );

      expect(chain.fetchConfigCalls, 1);
      expect(signer.sent, hasLength(2));
    });

    test('the resolved service_wallet is used as the skim account', () async {
      final signer = RecordingSigner(host);
      final chain = ReclaimChainGateway(config: _config(serviceWallet), slots: [_slot()]);

      await _gateway(signer, chain).closeConnectSlot(slotPda: slotPda);

      // close_connect_slot accounts: [host, slot, viewer, config, serviceWallet].
      final accounts = signer.sent.single.single.accounts;
      expect(accounts.last.pubKey, serviceWallet);
      expect(accounts.last.isWriteable, isTrue);
    });
  });

  group('config missing ⇒ reclaim disabled for the session', () {
    test('no close is attempted and nothing throws', () async {
      final signer = RecordingSigner(host);
      final chain = ReclaimChainGateway(slots: [_slot()]);
      final gateway = _gateway(signer, chain);

      expect(
        await gateway.closeConnectSlot(slotPda: slotPda),
        ReclaimOutcome.disabled,
      );
      expect(
        await gateway.endRoom(roomPda: roomPda),
        ReclaimOutcome.disabled,
      );
      expect(
        await gateway.closeRoom(roomPda: roomPda),
        ReclaimOutcome.disabled,
      );

      expect(signer.sent, isEmpty);
    });

    test('the disabled outcome is cached (config not re-fetched per close)', () async {
      final signer = RecordingSigner(host);
      final chain = ReclaimChainGateway();
      final gateway = _gateway(signer, chain);

      await gateway.closeConnectSlot(slotPda: slotPda);
      await gateway.closeConnectSlot(slotPda: slotPda);

      expect(chain.fetchConfigCalls, 1);
    });

    test('a fetchConfig failure disables reclaim without throwing', () async {
      final signer = RecordingSigner(host);
      final chain = ReclaimChainGateway(fetchConfigError: StateError('rpc down'));

      expect(
        await _gateway(signer, chain).closeConnectSlot(slotPda: slotPda),
        ReclaimOutcome.disabled,
      );

      expect(signer.sent, isEmpty);
    });
  });

  group('idempotency', () {
    test('an already-closed slot is a no-op success (no send, no throw)', () async {
      final signer = RecordingSigner(host);
      final chain = ReclaimChainGateway(config: _config(serviceWallet), slots: [null]);

      expect(
        await _gateway(signer, chain).closeConnectSlot(slotPda: slotPda),
        ReclaimOutcome.alreadyClosed,
      );

      expect(signer.sent, isEmpty);
    });

    test('a slot read failure is swallowed (deposit left for cleanup_*)', () async {
      final signer = RecordingSigner(host);
      final chain = ReclaimChainGateway(
        config: _config(serviceWallet),
        fetchSlotError: StateError('mid-write'),
      );

      expect(
        await _gateway(signer, chain).closeConnectSlot(slotPda: slotPda),
        ReclaimOutcome.failed,
      );

      expect(signer.sent, isEmpty);
    });

    test('end_room on an already-ended room is idempotent success', () async {
      final signer = RecordingSigner(
        host,
        failures: [_customError(_roomAlreadyEndedCode)],
      );
      final chain = ReclaimChainGateway(config: _config(serviceWallet));

      expect(
        await _gateway(signer, chain).endRoom(roomPda: roomPda),
        ReclaimOutcome.alreadyClosed,
      );

      // Sent once, not retried (idempotent), and did not throw.
      expect(signer.sent, hasLength(1));
    });

    test('close_room on a missing account is idempotent success', () async {
      final signer = RecordingSigner(
        host,
        failures: [const JsonRpcException('Account does not exist', -32002, null)],
      );
      final chain = ReclaimChainGateway(config: _config(serviceWallet));

      expect(
        await _gateway(signer, chain).closeRoom(roomPda: roomPda),
        ReclaimOutcome.alreadyClosed,
      );

      expect(signer.sent, hasLength(1));
    });
  });

  group('bounded retry', () {
    test('DepositMismatch is retried then succeeds', () async {
      final signer = RecordingSigner(
        host,
        failures: [_customError(_depositMismatchCode), null],
      );
      final chain = ReclaimChainGateway(config: _config(serviceWallet), slots: [_slot(), _slot()]);

      expect(
        await _gateway(signer, chain).closeConnectSlot(slotPda: slotPda),
        ReclaimOutcome.succeeded,
      );

      expect(signer.sent, hasLength(2));
    });

    test('retry is bounded and gives up without throwing', () async {
      final signer = RecordingSigner(
        host,
        failures: [
          _customError(_depositMismatchCode),
          _customError(_depositMismatchCode),
        ],
      );
      final chain = ReclaimChainGateway(config: _config(serviceWallet), slots: [_slot(), _slot()]);

      expect(
        await _gateway(
          signer,
          chain,
          maxAttempts: 2,
        ).closeConnectSlot(slotPda: slotPda),
        ReclaimOutcome.failed,
      );

      expect(signer.sent, hasLength(2));
    });

    test('a non-retryable program error is not retried and does not throw', () async {
      // NotHost (6009): a viewer/wrong party — deterministic, no point retrying.
      final signer = RecordingSigner(host, failures: [_customError(6009)]);
      final chain = ReclaimChainGateway(config: _config(serviceWallet));

      expect(
        await _gateway(signer, chain).closeRoom(roomPda: roomPda),
        ReclaimOutcome.failed,
      );

      expect(signer.sent, hasLength(1));
    });

    test('a deterministic code-less on-chain failure is not retried', () async {
      final signer = RecordingSigner(
        host,
        failures: [
          SolanaTransactionException.failedOnChain(
            signature: 'signature',
          ),
        ],
      );
      final chain = ReclaimChainGateway(config: _config(serviceWallet));

      expect(
        await _gateway(signer, chain).closeRoom(roomPda: roomPda),
        ReclaimOutcome.failed,
      );
      expect(signer.sent, hasLength(1));
    });

    test('a raw code-less RPC response is not assumed transient', () async {
      final signer = RecordingSigner(
        host,
        failures: [const JsonRpcException('invalid request', -32602, null)],
      );
      final chain = ReclaimChainGateway(config: _config(serviceWallet));

      expect(
        await _gateway(signer, chain).closeRoom(roomPda: roomPda),
        ReclaimOutcome.failed,
      );
      expect(signer.sent, hasLength(1));
    });

    test('an expired transaction is safe to retry', () async {
      final signer = RecordingSigner(
        host,
        failures: [
          SolanaTransactionException.expired(signature: 'signature'),
          null,
        ],
      );
      final chain = ReclaimChainGateway(config: _config(serviceWallet));

      expect(
        await _gateway(signer, chain).closeRoom(roomPda: roomPda),
        ReclaimOutcome.succeeded,
      );
      expect(signer.sent, hasLength(2));
    });

    test('transport before signing is safe to retry', () async {
      final signer = RecordingSigner(
        host,
        failures: [SolanaTransactionException.transport(), null],
      );
      final chain = ReclaimChainGateway(config: _config(serviceWallet));

      expect(
        await _gateway(signer, chain).closeRoom(roomPda: roomPda),
        ReclaimOutcome.succeeded,
      );
      expect(signer.sent, hasLength(2));
    });

    test('transport after signing is not retried', () async {
      final signer = RecordingSigner(
        host,
        failures: [
          SolanaTransactionException.transport(signature: 'signature'),
        ],
      );
      final chain = ReclaimChainGateway(config: _config(serviceWallet));

      expect(
        await _gateway(signer, chain).closeRoom(roomPda: roomPda),
        ReclaimOutcome.failed,
      );
      expect(signer.sent, hasLength(1));
    });

    test('definite AccountInUse preflight rejection is retried', () async {
      final signer = RecordingSigner(
        host,
        failures: [
          SolanaTransactionException.submissionRejected(
            signature: 'signature',
            transactionError: TransactionError.accountInUse,
          ),
          null,
        ],
      );
      final chain = ReclaimChainGateway(config: _config(serviceWallet));

      expect(
        await _gateway(signer, chain).closeRoom(roomPda: roomPda),
        ReclaimOutcome.succeeded,
      );
      expect(signer.sent, hasLength(2));
    });
  });

  group('viewer placeholder', () {
    test('an unclaimed slot refunds to the host placeholder', () async {
      final signer = RecordingSigner(host);
      final chain = ReclaimChainGateway(
        config: _config(serviceWallet),
        slots: [_slot(viewer: Uint8List(32))], // all-zero == unclaimed
      );

      await _gateway(signer, chain).closeConnectSlot(slotPda: slotPda);

      // viewer account (index 2) falls back to host.
      expect(signer.sent.single.single.accounts[2].pubKey, host);
    });

    test('a claimed slot refunds to the on-chain viewer', () async {
      final signer = RecordingSigner(host);
      final viewerBytes = Uint8List.fromList(List.filled(32, 7));
      final chain = ReclaimChainGateway(
        config: _config(serviceWallet),
        slots: [_slot(viewer: viewerBytes)],
      );

      await _gateway(signer, chain).closeConnectSlot(slotPda: slotPda);

      expect(signer.sent.single.single.accounts[2].pubKey, Ed25519HDPublicKey(viewerBytes));
    });
  });

  group('Null Object rebind', () {
    test('UnsupportedSignalingReclaimGateway no-ops every method', () async {
      const gateway = UnsupportedSignalingReclaimGateway();

      // None of these touch the chain or throw.
      expect(
        await gateway.closeConnectSlot(slotPda: slotPda),
        ReclaimOutcome.disabled,
      );
      expect(
        await gateway.endRoom(roomPda: roomPda),
        ReclaimOutcome.disabled,
      );
      expect(
        await gateway.closeRoom(roomPda: roomPda),
        ReclaimOutcome.disabled,
      );
    });

    test('the real gateway, once rebound, actually sends a transaction', () async {
      final signer = RecordingSigner(host);
      final chain = ReclaimChainGateway(config: _config(serviceWallet), slots: [_slot()]);

      await _gateway(signer, chain).closeConnectSlot(slotPda: slotPda);

      expect(signer.sent, hasLength(1));
    });
  });
}
