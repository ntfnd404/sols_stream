# SS-0003 Phase 2 (Signaling Hardening) — Code Review

Lane: Critical. Reviewer: independent REVIEW_OK gate.
Commits reviewed: `291bc0d` (signaling hardening), `033bbe4` (ui_kit theme builders).

## Verdict: REVIEW_OK

All Phase 2 items (2.4–2.12 + ui_kit) are implemented for real, not stubbed (the
one intentional no-op — `UnsupportedSignalingReclaimGateway` — is a sound,
documented Null Object). Layer boundaries hold, the ACL split is clean, atomicity
and compensation are correct, and AAD message-type binding is symmetric. The
findings below are all minor/nit and none block the gate. They should be folded
into the security-review pass or the follow-on IDL ticket.

---

## Findings

### Blocker
None.

### Major
None.

### Minor

1. **`ConnectionUrlCodec.parse` uses `!` null-assertions** —
   `packages/signaling/lib/src/application/connection_url_codec.dart:42-46`.
   The Hard Rules list `No '!' null assertion`. The values are provably non-null
   here (the loop above throws on any missing/empty key), so this is safe at
   runtime, but it still violates the stated convention. Fix: capture each value
   in the validation loop into locals (e.g. a `Map<String,String>` of validated
   params) and read those, or use `as String` after the guard. Cheap to resolve.

2. **`BorshReader.skipU64` is now dead code** —
   `packages/signaling/lib/src/data/solana_program/borsh_reader.dart:40`.
   2.5 switched the parser from `skipU64` to `readU64` for the deposit fields;
   `skipU64` now has no callers (confirmed by repo-wide search). Conventions list
   `No dead code`. Fix: remove `skipU64` (and its `_u64Bytes` reuse is unaffected —
   `readU64`/`readI64` still use it).

### Nit

3. **`goLive` line length / readability** —
   `packages/signaling/lib/src/application/solana_signaling.dart:59,71`. The `prot`
   generation and `_codec.encode(...)` calls are long single lines; not a rule
   violation but inconsistent with the wrapped style used elsewhere in the file.
   Defer to the formatter / analyzer if it flags `lines_longer_than_80_chars`.

4. **`SignalingSession` lacks a doc comment** —
   `packages/signaling/lib/src/application/signaling_session.dart:1`. Every other
   application DTO in this package carries a class-level doc; this one (now with
   the added `roomPda`, item 2.8) has none.

---

## Item-by-item verification

- **2.4a Atomicity** — PASS. `SolanaSignalingChainGateway.openSignalingSlot`
  (`solana_signaling_chain_gateway.dart:36-39`) sends a single
  `signAndSend([createRoom, openSlot])`. PDA derivation is pure and ordered
  (room PDA derived first, then slot PDA from the room PDA), so instruction order
  guarantees `create_room` precedes `open_slot`; either both deposits land or
  neither. Matches the README "Atomicity" claim.

- **2.4b Reclaim port** — PASS. `SignalingReclaimGateway` is its own port
  (`closeSlot`/`closeRoom`), properly ISP-segregated from `SignalingChainGateway`,
  with a `const UnsupportedSignalingReclaimGateway` Null-Object default wired in
  the `SolanaSignaling` constructor. Null Object semantics are sound (no-op async,
  never throws). Exported from the barrel.

- **2.4c Compensation** — PASS. `goLive` only wraps the *post-open* steps
  (`encode` + `writeOffer`) in try/catch (`solana_signaling.dart:70-76`); nothing
  is on-chain before `openSignalingSlot`, so the failure window is correctly
  bounded — no compensation runs when `openSignalingSlot` itself throws.
  `_compensateOpenedSlot` (`:184-192`) swallows reclaim errors and `rethrow`s the
  original, so the primary failure is never masked. Test
  `solana_signaling_golive_test.dart` exercises both the happy path (no reclaim)
  and the offer-write failure (slot+room reclaimed, original `StateError`
  rethrown). Good.

- **2.5 ACL split** — PASS, clean. Parser → `ConnectSlotAccount` (full wire image,
  incl. deposits + protected keys + bump) → `ConnectSlotMapper` → slim
  `ConnectSlotData` (deposits in; protected keys + bump dropped). The domain VO
  imports only `connect_slot_state.dart` and `dart:typed_data` — no Borsh, no
  byte offsets. Parser now reads deposits via `readU64` (was `skipU64`). Mapper
  validates `stateIndex` range before indexing the enum. Mapper + parser tests
  cover bounds, deposits, protected-key passthrough, and raw-index preservation.

- **2.6 RoomCreationParams validation** — PASS. Factory validates title 1..64,
  u8 code ranges, non-negative prices; `.p2pFree()` stays `const` and routes
  through the private const ctor, correctly bypassing runtime validation with
  known-valid literals. `const RoomCreationParams.p2pFree()` const usages in
  `signaling_chain_gateway.dart`, `instruction_builder.dart`, and the gateway
  impl still compile (private ctor is const). Tests cover all branches.

- **2.7 Dead `randomBytes`** — PASS. `SignalPayloadCrypto` no longer exposes a
  static `randomBytes`; the remaining `randomBytes` on `SignalPayloadCodec` /
  `AesGcmSignalPayloadCodec` is the live codec API used by `goLive`. Correct.

- **2.8 `roomPda` on `SignalingSession`** — PASS (added). See nit #4.

- **2.9 AAD message-type binding** — PASS. Encrypt and decrypt both build the AAD
  as `utf8.encode('$slotNonce:$messageType')`
  (`signal_payload_crypto.dart:25` and `:52`) — identical format. Call sites pass
  `'offer'`/`'answer'` consistently (offer write & fetch use `'offer'`; answer
  submit & watch use `'answer'`). The codec test verifies a cross-type decode
  (`offer` ciphertext, `answer` AAD) fails, plus wrong-prot and wrong-slotNonce.

- **2.10 README Security model** — PASS. New "Security model" + "Funds & deposits"
  sections document the `prot` capability key, threat surface, AAD scoping, and
  the reclaim deferral. README layer-structure table updated for the ACL split and
  the new ports — satisfies the README Touch Rule.

- **2.11 ConnectionUrlCodec** — PASS. URL encode/decode moved to the
  application-layer `ConnectionUrlCodec`; removed from the gateway interface and
  impl (no stale `buildConnectionUrl`/`parseConnectionUrl` references anywhere).
  See minor #1 for the `!` usage inside it.

- **2.12 Tests** — PASS. 6 test files: crypto round-trip + 3 negative AAD/key
  cases, parser (3), mapper (4), room params (6), fetchOffer/watchForAnswer state
  machine (8), goLive compensation (2). Doubles live in `fakes/` per convention
  (Fake/Recording naming; no inline doubles, no `helpers/`). Gateways tested
  through interface fakes, not by mocking the Impl. Coverage of the new behavior
  is genuine.

- **ui_kit** — PASS. The four component-theme builders are now top-level functions
  (`buildCardTheme`, `buildFilledButtonTheme`, `buildOutlinedButtonTheme`,
  `buildInputDecorationTheme`) — conventions §"Non-instantiable groupings" case 2.
  `AppTheme` is kept as `final class` + private const ctor with `static`
  members — case 3 (the name documents a concept the function names don't, and
  `builder`/`fromVariant`/`_buildScope` cohere). Both compliant. All call sites
  (`lib/feature/app/view/app.dart`, ui_kit tests/README) updated; no broken refs.

---

## Notes for the security-reviewer (Critical gate)

These are *flags*, not findings — full crypto/on-chain assessment is the security
gate's job:

1. **AAD does not bind `prot` or slot identity beyond `slotNonce`.** AAD is
   `'$slotNonce:$messageType'`. Key separation across slots comes from PBKDF2
   (`prot + slotNonce` salt), not the AAD. Confirm this is sufficient — e.g.
   whether the host pubkey / roomPda should also be bound so a payload from one
   host's slot can't be presented under another slot that happens to reuse a
   `slotNonce` value. Likely fine given `prot` is per-slot random, but worth an
   explicit call.

2. **`prot` is a bearer capability with no expiry beyond on-chain slot expiry.**
   README documents this; security gate should confirm the 120s `expiresInSec`
   window and the "strip `prot` before analytics/crash-reporters" guidance are
   enforced by the consuming UI (`lib/`), not just documented.

3. **Deposit reclaim is a permanent no-op until the IDL ticket.** On mainnet a
   `goLive` whose offer write fails after the atomic open leaks the room+slot
   deposits unless the program auto-refunds at expiry. The atomic tx bounds the
   exposure to a single failed-offer slot, and compensation is wired, but the
   actual on-chain reclaim does not exist yet. Confirm this residual exposure is
   acceptable for the mainnet target, or that auto-refund-on-expiry is verified.

4. **`readU64` lamport assumption.** `BorshReader.readU64` returns Dart `int`;
   the doc notes values above 2^63 would wrap. Deposits never reach that, but the
   value is read straight from chain — confirm no path treats an attacker-set
   deposit field as trusted in a way that a wrap could exploit (currently it is
   only surfaced for accounting, never used in a security decision).
