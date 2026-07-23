# signaling

**Bounded context:** WebRTC P2P signaling protocol and application services

Handles the automated SDP offer/answer exchange between peers. The package owns
the signaling language, use cases, ports, URL codecs, and crypto. Concrete
Solana program adapters live in `packages/signaling_solana`.

## Public API

```dart
// Publisher
final session = await signaling.publishOffer(sdpOfferJson);
final answer = await session.awaitAnswerSdp();

// Viewer
final offer = await signaling.fetchOffer(Uri.parse(connectionUrl));
await signaling.submitAnswer(offer, sdpAnswerJson);
await signaling.confirm(offer);
```

`OnChainPeerSignaling` receives its viewer base URL from the app composition
root. Local and dev builds currently use the Dart Web client on localhost; a
public Dart Web deployment has not been selected. The signaling package does
not own deployment environment URLs.

`KeyBrokerAssembly` selects and owns the `KeyBrokerGateway` provider:

- remote HTTPS broker for dev/shared environments. The broker verifies
  claims against its Solana cluster.
- local capability broker only for an isolated local validator. It uses a
  scoped, expiring capability envelope so separate local app processes can
  exchange the passphrase without an external broker. The envelope is not
  confidential from users who can read local chain state.

The HTTP adapter requires an injected HTTPS origin and owned `http.Client`,
does not follow redirects, and does not spoof browser headers. Concrete
gateways are internal; consumers use the assembly and application port.

## Dependencies

| Package | Why |
|---------|-----|
| `cryptography` | AES-GCM + PBKDF2 for SDP payload protection |
| `http` | Key broker HTTP adapter |

## Source of truth & re-sync

The protocol package does not own Solana wire artifacts. The versioned Anchor
IDL and generated wire SDK belong to `packages/signaling_solana`; its internal
account decoders, mappers, and instruction factory form the consumer-owned
compatibility layer. Run `make check-idl check-solana-sdk` before changing
on-chain adapters and `make fetch-idl` to refresh the checked-in IDL.

Permanent wire-vector tests protect load-bearing discriminators, account order,
and signer/writable flags. Generated registries cover every IDL declaration;
legacy `ConnectSlot` and projected `User` decoding remain explicit adapter
policies rather than generator defaults.

## Layer structure

```
domain/        — ConnectSlotData, ConnectSlotState, RoomCreationParams, ProgramConfig (VOs)
application/   — PeerSignaling port, OnChainPeerSignaling use case,
                 PeerHostSession / PeerOffer DTOs, chain and protected-slot ports
data/crypto/         — passphrase payload protection
data/http_key_broker_gateway.dart — remote key broker HTTP adapter
data/local_key_broker_gateway.dart — isolated local-development adapter
assembly/             — typed key-broker configuration and owned lifecycle
```

The on-chain account crosses an **Anti-Corruption boundary** in
`signaling_solana`: generated wire models are decoded under call-site-specific
integrity policies, then mapped into the slim `signaling` domain models. The
domain never sees Borsh, PDA bumps, generated variants, or compatibility
fallbacks. `ProgramConfig` crosses the same boundary and exposes only the
service wallet, TURN price, and heartbeat interval needed by the application.

## Funds & deposits

Each session deposits SOL on-chain (anti-spam / account rent):

- **Host** pays `0.001 SOL` for the room + `0.001 SOL` for the slot (`0.002` total).
- **Each viewer** pays `0.001 SOL` when claiming the slot.

**Sequencing.** A host User PDA is created or cleaned up first, then TURN
entitlement is purchased when `user.turn_expires_at` is absent or expired, then
`create_room` and `open_slot` are sent as separate confirmed transactions. The
deployed program rejects `create_room` with `Unauthorized` (6013) when TURN
entitlement is missing.

**Reclaim seam.** Reclaim is modelled as a dedicated port,
`SignalingReclaimGateway` (`closeConnectSlot` / `endRoom` / `closeRoom`),
injected into `OnChainPeerSignaling`. Host teardown closes the retained slot,
then ends and closes the room. Setup compensation uses the same order. Each
step is guarded independently, so one failing step never aborts the rest.

`close_connect_slot` is host-authorized by the deployed program. A viewer must
not attempt to sign it as host. Viewer disconnect therefore leaves immediate
slot closure to the host teardown; that host transaction refunds both the host
and the on-chain viewer. Passive `cleanup_*` remains the fallback when the host
does not return.

The real binding, `SolanaSignalingReclaimGateway` (`packages/signaling_solana`), sends
each close as its **own single-instruction transaction** (the default 200k CU
budget fits one close; batching could exceed it — ComputeBudget is a later
phase), so every step fails independently. It returns a typed `ReclaimOutcome`
(`succeeded`, `alreadyClosed`, `disabled`, or `failed`), is idempotent, and
never exposes raw RPC errors in diagnostics. `DepositMismatch` and transient
RPC errors are classified through generated custom-error helpers and retried a
bounded number of times; any residual deposit is left for the program's passive
`cleanup_*` fallback.

The mandated **1% skim** goes to the on-chain `service_wallet`, read from the
`ProgramConfig` (`[b"config"]`) and cached for the session — **never** a literal
and **never** a caller-supplied parameter. The same config supplies the TURN
service wallet for `purchase_turn` and the minimum heartbeat interval. A
missing/unreadable config disables reclaim for the session (the program would
reject a close without a service wallet anyway); the leak then equals the
do-nothing baseline. Anchor custom errors are decoded through the generated
program error parser for diagnostics and the retry classifier.

`SignalingSolanaAssembly` binds the real `SolanaSignalingReclaimGateway` in
production. Host disconnect awaits the role-authorized teardown before dropping
session handles. The `UnsupportedSignalingReclaimGateway` Null Object remains
the default binding for contexts that do not wire reclaim (and for tests).

On **devnet**, `signaling_solana` checks the configured wallet funding service
immediately before each broadcast transaction (see `solana_wallet`). On
**mainnet**, the ordered confirmed transactions plus this reclaim seam bound
the exposure of an abandoned slot/room. Read-only, proof-signing, and reclaim
operations do not invoke funding sources. Funded and reclaim broadcasts share
one FIFO transaction coordinator, so every funded send checks the balance after
the preceding transaction has completed.

## Room economics (single mode today)

`create_room` carries `access_mode`, `connection_mode`, `price_per_minute`, and
`price_per_session`. The app currently creates only **public, free, P2P** rooms,
centralised in `RoomCreationParams.p2pFree()`. Paid / access-controlled / non-P2P
rooms (and the on-chain `protected_key` access fields, left empty today) are the
**monetization roadmap** — see `docs/project/vision.md`. This package will not
grow that logic until that ticket lands.

## Security model

The HTTP(S) invite carries only routing information and the host address.
Offer and answer passphrases are protected by the configured key broker and
released only after proof validation. Invite URLs, protected keys, proofs,
passphrases, SDP, authorization headers, and broker response bodies must not be
logged. Slot expiry and broker TTL bound the replay window.

## Intentionally out of scope

- Keypair management and storage → `solana_wallet`
- Wallet identity, balance, signing, persistence, and funding → `solana_wallet`
- Funding preconditions at the Solana transaction boundary → `signaling_solana`
- Solana program wire format and gateways → `signaling_solana`
- WebRTC peer connection and media lifecycle → `realtime_media`
- HLS playback lifecycle → `streaming`
- General-purpose encryption
