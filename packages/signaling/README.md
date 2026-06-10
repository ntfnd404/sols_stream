# signaling

**Bounded context:** Solana on-chain WebRTC P2P signaling

Handles the automated SDP offer/answer exchange between two peers via the
sols.stream smart contract on Solana. Peers do not exchange data directly —
everything goes through an on-chain ConnectSlot account.

## Public API

```dart
// Publisher
final session = await signaling.goLive(sdpOfferJson);    // → SignalingSession
signaling.watchForAnswer(session);                        // Stream<String> sdpAnswer

// Viewer
final offer = await signaling.fetchOffer(connectionUrl); // → FetchedOffer
await signaling.submitAnswer(offer, sdpAnswerJson);

// Both
await signaling.confirmConnection(slotPda);
```

## Dependencies

| Package | Why |
|---------|-----|
| `solana_wallet` | `SolanaSigner` interface — transaction signing, balance, funding |
| `solana` | RPC client, transaction types, PDA derivation |
| `cryptography` | AES-GCM + PBKDF2 for SDP payload protection |

## Layer structure

```
domain/        — ConnectSlotData (Value Object), ConnectSlotState (Enum)
application/   — SolanaSignaling (Use Case), SignalingSession, FetchedOffer (Output DTOs)
data/crypto/         — EncryptedPayload DTO, SignalPayloadCrypto (AES-GCM/PBKDF2)
data/solana_program/ — InstructionBuilder, ConnectSlotAccountParser (Borsh)
```

## Intentionally out of scope

- Keypair management and storage → `solana_wallet`
- Wallet funding / airdrop logic → `solana_wallet`
- WebRTC peer connection → `flutter_webrtc` (in `lib/`)
- General-purpose encryption — `SignalPayloadCrypto` is protocol-specific
