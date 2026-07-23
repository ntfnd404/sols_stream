import 'dart:typed_data';

import 'package:signaling/signaling.dart';
import 'package:solana/encoder.dart' show Instruction;
import 'package:solana/solana.dart' show Ed25519HDPublicKey;
import 'package:solana_wallet/solana_wallet.dart';
import 'package:sols_stream/core/di/app_dependencies.dart';
import 'package:sols_stream/core/di/app_resource_disposal_stack.dart';
import 'package:sols_stream/core/event_bus/app_event_bus.dart';

AppDependencies fakeAppDependencies({
  FakeSolanaWallet? wallet,
  AppResourceDisposalStack? resourceDisposalStack,
  AppErrorReporter errorReporter = _ignoreError,
  bool ownEventBus = true,
}) {
  final solanaWallet = wallet ?? const FakeSolanaWallet();
  final chain = StubChainGateway();
  final disposalStack = resourceDisposalStack ?? AppResourceDisposalStack();
  final eventBus = AppEventBus();
  if (ownEventBus) {
    disposalStack.register(
      eventBus,
      (resource) => resource.dispose(),
    );
  }

  return AppDependencies(
    eventBus: eventBus,
    peerSignaling: OnChainPeerSignaling(
      slots: StubProtectedSlotGateway(),
      chain: chain,
      broker: StubKeyBrokerGateway(),
      identity: SignalingParticipantIdentity.fromPublicKey(
        publicKeyBytes: solanaWallet.publicKey.bytes,
        addressEncoder: (_) => solanaWallet.address,
      ),
      peerInviteBase: const PeerInviteCodec().parseBase(
        Uri.parse(
          'https://p2p.sols.stream/home?intent=p2p&role=viewer',
        ),
      ),
    ),
    walletReader: solanaWallet,
    resourceDisposalStack: disposalStack,
    errorReporter: errorReporter,
  );
}

void _ignoreError(Object error, StackTrace stackTrace) {}

// Shared test helper file intentionally groups the fake dependency graph.
// ignore: prefer-match-file-name
class FakeSolanaWallet implements SolanaWalletReader, SolanaSigner {
  final int balance;

  @override
  Ed25519HDPublicKey get publicKey => Ed25519HDPublicKey(List.filled(32, 0));

  @override
  String get address => '11111111111111111111111111111111';

  const FakeSolanaWallet({this.balance = 1_000_000_000});

  @override
  Future<int> getBalanceLamports() async => balance;

  @override
  Future<String> signAndSend(List<Instruction> instructions) async => 'signature';

  @override
  Future<String> signForProof(List<Instruction> instructions) async => 'proof';
}

class StubChainGateway implements SignalingChainGateway {
  @override
  Future<SlotAddresses> openSignalingSlot({
    required int slotNonce,
    RoomCreationParams room = const RoomCreationParams.p2pFree(),
    int expiresInSeconds = 120,
  }) => throw UnimplementedError();

  @override
  Future<void> endRoom(String roomPda) async {}

  @override
  Future<void> closeRoom(String roomPda) async {}

  @override
  Future<void> claimSlot({required String slotPda, required String roomPda}) async {}

  @override
  Future<ConnectSlotData?> fetchSlot(String slotPda) async => null;

  @override
  Future<ProgramConfig?> fetchConfig() async => null;

  @override
  Future<void> confirmConnection(String slotPda) async {}

  @override
  Future<void> sendHeartbeat() async {}

  @override
  Future<int> readStreamCount() async => 0;
}

class StubProtectedSlotGateway implements ProtectedSlotGateway {
  @override
  Future<ProtectedSlotDiscoveryResult> discoverOpenSlot(
    String hostAddress,
  ) async => const ProtectedSlotUnavailable(
    ProtectedSlotUnavailableReason.noJoinableSlot,
  );

  @override
  Future<String> buildSignedProof(String slotPda) async => '';

  @override
  Future<void> writeOfferWithProtectedKey({
    required String slotPda,
    required String protectedKey,
    required Uint8List payload,
  }) async {}

  @override
  Future<void> writeAnswerWithProtectedKey({
    required String slotPda,
    required String protectedKey,
    required Uint8List payload,
  }) async {}
}

class StubKeyBrokerGateway implements KeyBrokerGateway {
  @override
  Future<String> unprotect({
    required String protectedKey,
    required String hostAddress,
    required String offerId,
    String? signedProof,
    String? slotPda,
  }) async => '';

  @override
  Future<String> protect({
    required String passphrase,
    required String hostAddress,
    required String offerId,
    Duration ttl = defaultKeyProtectionTtl,
  }) async => '';
}
