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

## Source of truth & re-sync

There is **no Anchor IDL** in the repo. The on-chain program's instruction and
account discriminators and the custom-error map (`SOLS_ERROR_NAMES`) are
transcribed from the production web client `program-client.js` into
`SignalingProgramConstants` and `SolanaErrorCodes` (one place each). The contract
is **still in development**, so the client ships new versions periodically.

Account parsers and instruction builders that mirror the contract are also
transcribed from this source and kept byte-exact: `ConnectSlotAccountParser`
(Upgrade-07 layout), `ProgramConfigAccountParser` (the `[b"config"]` PDA →
`service_wallet`), and the reclaim builders `buildCloseConnectSlot` /
`buildEndRoom` / `buildCloseRoom` in `instruction_builder.dart` (account order
and signer/writable flags are load-bearing — verified by tests).

- **Captured source:** `packages/signaling/reference/program-client.js`
  — from `https://p2p.sols.stream/ipfs/<CID>/program-client.js`. The IPFS **CID is
  the version** (immutable content hash); a contract update yields a new CID.
- **Current capture:** CID `bafybeiabqt3ptjgc6c7u62rzf72mwlsmk6g7sd3ah7ykedlkkiqcxtkf5q`,
  2026-06-21, sha256 `1191815b8df70204f8641061bcae2aaa6605ea0b7e1e073021125d10cc1a6b9e`.
- **Re-sync workflow:** drop the new `program-client.js` over the captured copy →
  `git diff` to see what changed → re-validate the affected discriminators (each
  also equals the Anchor sighash `sha256("global:"+ix)[:8]`) and the error map →
  edit `signaling_program_constants.dart` / `solana_error_codes.dart` → bump the
  CID/hash/date here and in the constants header.

## Layer structure

```
domain/        — ConnectSlotData, ConnectSlotState, RoomCreationParams, ProgramConfig (VOs)
application/   — SolanaSignaling (Use Case), SignalingSession, FetchedOffer (Output DTOs),
                 SignalingChainGateway + SignalingReclaimGateway (ports), ConnectionUrlCodec
data/crypto/         — EncryptedPayload DTO, SignalPayloadCrypto (AES-GCM/PBKDF2)
data/solana_program/ — InstructionBuilder, ConnectSlotAccountParser (Borsh) →
                       ConnectSlotAccount (wire DTO) → ConnectSlotMapper → domain;
                       ProgramConfigAccountParser → ProgramConfigAccount → ProgramConfigMapper;
                       SolanaSignalingReclaimGateway (real reclaim impl);
                       SolanaErrorCodes + solanaCustomErrorCode (Anchor error decode)
```

The on-chain account crosses an **Anti-Corruption boundary**: the parser reads the
raw Borsh layout into the wire DTO `ConnectSlotAccount` (every field, incl.
deposits and the reserved protected keys), and `ConnectSlotMapper` translates it
into the slim domain `ConnectSlotData`. The domain never sees Borsh, the PDA
`bump`, or always-empty reserved fields. The singleton `ProgramConfig` account
crosses the same boundary (`ProgramConfigAccountParser` → `ProgramConfigAccount`
→ `ProgramConfigMapper`), exposing only the `service_wallet` the reclaim flow
needs.

## Funds & deposits

Each session deposits SOL on-chain (anti-spam / account rent):

- **Host** pays `0.001 SOL` for the room + `0.001 SOL` for the slot (`0.002` total).
- **Each viewer** pays `0.001 SOL` when claiming the slot.

**Atomicity.** `create_room` + `open_slot` are sent as **one atomic transaction**,
so the host never ends up with a paid-for room but no slot — either both deposits
land or neither does.

**Reclaim seam.** Reclaim is modelled as a dedicated port,
`SignalingReclaimGateway` (`closeConnectSlot` / `endRoom` / `closeRoom`), injected
into `SolanaSignaling`. On a `goLive` that opens a slot but then fails (e.g. the
offer write), the use case runs a best-effort **compensation** step against this
port.

The real binding, `SolanaSignalingReclaimGateway` (`data/solana_program/`), sends
each close as its **own single-instruction transaction** (the default 200k CU
budget fits one close; batching could exceed it — ComputeBudget is a later
phase), so every step fails independently. It is **best-effort, idempotent, and
never throws**: an already-closed account is idempotent success, `DepositMismatch`
(6023) and transient RPC errors are retried a bounded number of times, and any
residual deposit is left for the program's passive `cleanup_*` fallback.

The mandated **1% skim** goes to the on-chain `service_wallet`, read from the
`ProgramConfig` (`[b"config"]`) and cached for the session — **never** a literal
and **never** a caller-supplied parameter. A missing/unreadable config disables
reclaim for the session (the program would reject a close without a service
wallet anyway); the leak then equals the do-nothing baseline. Anchor custom
errors are decoded by name via `solanaCustomErrorCode` + `SolanaErrorCodes` for
diagnostics and the retry classifier.

> Production wiring (rebinding `SignalingAssembly` from the
> `UnsupportedSignalingReclaimGateway` Null Object to the real gateway, plus the
> `_disconnect()` stream-stop / viewer-leave call sites) lands in the app-wiring
> batch; until then the Null Object remains the default binding.

On **devnet** the wallet auto-airdrops on a low balance (see `solana_wallet`); on
**mainnet** the atomic open transaction above plus this reclaim seam bound the
exposure of an abandoned slot/room.

## Room economics (single mode today)

`create_room` carries `access_mode`, `connection_mode`, `price_per_minute`, and
`price_per_session`. The app currently creates only **public, free, P2P** rooms,
centralised in `RoomCreationParams.p2pFree()`. Paid / access-controlled / non-P2P
rooms (and the on-chain `protected_key` access fields, left empty today) are the
**monetization roadmap** — see `docs/project/vision.md`. This package will not
grow that logic until that ticket lands.

## Security model

The `prot` field in the `sols://` connection URL is a 32-byte random
capability key. **Possession of a full `sols://` URL — specifically the `prot`
query parameter — is sufficient to decrypt and answer a signaling slot.**

Threat surface:

- The URL must be shared out-of-band (QR code, clipboard, deep link). Any
  channel that logs or caches full URIs can expose `prot`.
- The app must not pass a `sols://` URL to analytics, crash reporters, or URL
  shorteners unless the `prot` component is stripped first.
- `prot` is bound to a single slot via PBKDF2 (`prot + slotNonce`) and scoped
  further by a message-type tag in the AAD (`slotNonce:offer` or
  `slotNonce:answer`), so an offer ciphertext cannot be replayed as an answer.
- Slot expiry (`expiresAt`) limits the replay window; after expiry the on-chain
  account is closed and the key material is worthless.

## Intentionally out of scope

- Keypair management and storage → `solana_wallet`
- Wallet funding / airdrop logic → `solana_wallet`
- WebRTC peer connection → `flutter_webrtc` (in `lib/`)
- General-purpose encryption — `SignalPayloadCrypto` is protocol-specific
