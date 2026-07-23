# SS-0003 Phase 2 (Signaling Hardening) — Security Review

Lane: Critical. Gate: SECURITY_REVIEW (post REVIEW_OK).
Commits reviewed: `291bc0d`, `033bbe4`, `4a03f61` (current working-tree state).
Target environment: **mainnet** (devnet dev-only) — deposit handling is real-funds.

## Verdict: SECURITY_REVIEW_OK

Crypto construction is sound (AES-GCM-256, 128-bit tag verified before plaintext
is returned, random 12-byte nonce per encrypt, PBKDF2-HMAC-SHA256 @ 150k from a
CSPRNG-derived 32-byte `prot`, distinct random nonces + message-type AAD make
offer/answer reuse under one key safe). The `prot` bearer model, reclaim no-op,
and hardcoded discriminators are knowingly deferred/documented residual risks and
are acceptably bounded for this phase. No critical or high blocker.

Two findings are raised below that should not block this gate but must be folded
into the follow-on work: an **unbounded Borsh length read** on attacker-controlled
on-chain bytes that throws an uncaught `RangeError` (`Error`, not `Exception`) and
slips past the `on Exception` poll guards (Medium), and a **latent `prot`-in-URL
leak surface** (`StreamStartedEvent.connectionUrl`) that is currently un-logged but
one `toString`/crash-reporter wiring away from exposure (Medium). Neither is an
unsafe-key/sensitive-logging/auth-downgrade/contract-drift condition that the gate
blocks on today.

---

## Findings

### Critical
None.

### High
None.

### Medium

1. **Unbounded `readVec`/`readFixed` length from attacker-controlled chain bytes →
   uncaught `RangeError` that bypasses the poll guards.**
   `packages/signaling/lib/src/data/solana_program/borsh_reader.dart:24-37`.
   `readVec` reads a `u32` length prefix straight from the on-chain account and
   passes it to `readFixed`, which does `_data.sublist(_offset, _offset + length)`
   with **no check** that `_offset + length <= _data.length`. The slot account is
   a PDA owned by the program, so under the honest-program assumption the layout is
   well-formed — but `fetchSlot` (`solana_signaling_chain_gateway.dart:76-85`)
   feeds whatever bytes the RPC returns into the parser, and a truncated/malformed
   account (malicious or buggy RPC, partial write, future program version) makes
   `sublist`/`ByteData.sublistView` throw `RangeError`. That is an `Error`, not an
   `Exception`, so the `} on Exception {` guards in `watchForAnswer`
   (`solana_signaling.dart:100`) and the absence of any guard around the
   `fetchOffer` polls (`:131`, `:147`) let it propagate uncaught and abort the
   session rather than being treated as a transient "slot not ready yet".
   Risk: denial-of-availability of the signaling session from any non-conforming
   account image; an attacker who can influence the RPC response or race a partial
   write can wedge the peer. Not a memory-safety or decrypt issue (Dart bounds-checks),
   not fund-loss.
   Remediation (must fix in follow-on, not a gate blocker): add a length guard in
   `BorshReader.readFixed`/`readVec` that throws a typed `FormatException` on
   overrun, and broaden the poll catch from `on Exception` to also treat parse
   `FormatException` as a skip/continue (or catch in `fetchSlot` and return `null`).

2. **`prot` capability leaks into an in-app event payload (`StreamStartedEvent`)
   — latent, one wiring step from exposure.**
   `lib/feature/home/view/home_screen.dart:396` emits
   `StreamStartedEvent(session.url)` and
   `lib/core/event_bus/events/stream_domain_event.dart:28-31` stores the **full
   `sols://...&prot=...` URL**. Today this is not exposed: `AppEventBus`
   (`lib/core/event_bus/app_event_bus.dart:40`) is not a BLoC, so
   `AppBlocObserver.onEvent` (`lib/core/bloc/app_bloc_observer.dart:16`) never logs
   it, and `StreamStartedEvent` uses the default `toString` (type name only, no
   field). So the README's "do not pass full URIs to analytics/crash reporters"
   guidance currently holds. The risk is that the secret now lives inside a
   domain-event object: the moment someone (a) routes these events through a
   BLoC/observer that logs `$event`, (b) adds a `toString` for debugging, or
   (c) wires the `TODO Sentry.captureException` in `AppBlocObserver:40-41` and an
   event/state carrying this URL reaches `onError`, the `prot` bearer key is
   exfiltrated to a third party. The on-chain 120s expiry caps the window but is
   ample to decrypt the offer and hijack the answer.
   Remediation (should fix; not a gate blocker because no live sink exists today):
   carry the `prot`-free shareable payload and the secret separately, or strip
   `prot` before it enters any event/state object; alternatively make
   `connectionUrl` a redacting wrapper whose `toString` masks the `prot` query
   param. Add a regression test asserting `prot` never appears in an event/state
   string representation.

### Low

3. **`prot` surfaces in user-facing UI sinks (clipboard, QR, SelectableText).**
   `lib/feature/home/view/widgets/publisher_controls.dart:31,36,43` render the full
   URL as a QR code, a `SelectableText`, and copy it to the system clipboard. This
   is **intentional and required** — the publisher must share the capability
   out-of-band — and matches the README threat model exactly. Flagged only as the
   inventory of legitimate `prot` exits so future changes here get re-reviewed.
   The system clipboard is readable by other apps/clipboard-history; acceptable for
   the share UX but worth a UI note. No change required this phase.

### Info

4. **Hardcoded discriminators / account metas / deposit constant are an unverified
   trust assumption.** `signaling_program_constants.dart:11-19` hardcodes Anchor
   discriminators "from program-client.js", `depositLamports`, and `expiresInSec`;
   `instruction_builder.dart` hardcodes the account-meta order and signer flags.
   Out of scope to verify against the IDL (the IDL is not available — same reason
   reclaim is deferred), but a wrong discriminator/meta on **mainnet** spends real
   SOL on a transaction the program rejects or, worse, mis-routes. Note as an
   assumption to validate when the IDL lands (the reclaim/IDL ticket).

5. **Randomness is cryptographically secure.** `prot` and the room/slot nonces come
   from `cryptography/helpers.dart` `randomBytes` via
   `AesGcmSignalPayloadCodec.randomBytes` (`aes_gcm_signal_payload_codec.dart:27`),
   which is backed by `Random.secure()`. `prot` is base64 of 32 CSPRNG bytes
   (256-bit). The nonce sign-bit mask (`solana_signaling.dart:197`,
   `int64SignBitMask`) drops one bit (63-bit space) for on-chain positivity — a
   non-issue for collision (room/slot nonces are not secrets, only uniqueness/anti-grind).

6. **`readU64` lamport-to-`int` wrap is accounting-only — no security decision rides
   on it.** `borsh_reader.dart:44-49` reads deposits into a Dart `int`. Confirmed:
   `hostDeposit`/`viewerDeposit` flow through `ConnectSlotMapper` into
   `ConnectSlotData` and are never read in any auth/claim/spend branch. Claim
   authorization keys off `viewer` bytes (`_isUnclaimed`/`_isClaimedByMe`,
   `solana_signaling.dart:205-215`) and slot `state`, not deposit amounts. The
   theoretical >2^63 wrap is therefore unreachable as an exploit. OK as-is.

7. **AAD adequacy (handover point 1) — sufficient for this protocol.** AAD is
   `'$slotNonce:$messageType'` (`signal_payload_crypto.dart:25,52`); host/roomPda
   are not bound. Cross-slot confusion is prevented by the PBKDF2 key being derived
   from the **per-slot-random 256-bit `prot`** plus the `slotNonce` salt
   (`_deriveKey`, `:59-70`): two different slots have independent keys, so a
   ciphertext from slot A cannot be AEAD-verified under slot B's key even if an
   attacker forced an equal `slotNonce`. Offer/answer reuse under the *same* key is
   prevented by (a) independent random 12-byte nonces per encrypt and (b) the
   `offer`/`answer` message-type AAD, so an offer ciphertext cannot be replayed as
   an answer (the functional review's negative test confirms this). Binding host
   pubkey/roomPda would be defense-in-depth but is not required given per-slot key
   separation. No change required.

---

## Accepted residual risks (knowingly deferred / documented)

- **Reclaim is a permanent no-op until the IDL ticket** (handover point 3).
  `UnsupportedSignalingReclaimGateway` (`signaling_reclaim_gateway.dart:26-34`) is
  a Null Object; `_compensateOpenedSlot` (`solana_signaling.dart:184-192`) calls it
  and swallows errors. Worst-case mainnet fund loss is **bounded** to the
  room + slot deposits of a single `goLive` whose offer write fails *after* the
  atomic `create_room`+`open_slot` landed: `2 × depositLamports = 0.002 SOL`
  (`signaling_program_constants.dart:19`). The atomicity of open
  (`solana_signaling_chain_gateway.dart:36-39`) guarantees no room-without-slot
  half-state, so there is no over-deposit/double-spend path; the failure window is
  the two `writeOffer` chunked sends. This is documented in README "Funds &
  deposits" with the two open questions (auto-refund-on-expiry vs. explicit
  `close_*`). **Accepted** for this phase as a small, bounded, documented loss;
  resolve in the IDL ticket (and confirm whether the program auto-refunds at the
  120s expiry, which would make the Null Object the permanent correct binding).

- **`prot` is a bearer capability with no revocation beyond the 120s slot expiry**
  (handover point 2). Possession of the full `sols://` URL ⇒ full decrypt + answer
  for that slot until `expiresInSec`. This is the protocol's intended design,
  documented in README "Security model" (out-of-band sharing, strip-before-analytics
  guidance). **Accepted as designed.** Finding #2 above tracks the *implementation*
  risk (the URL now living inside an event object) which is the part that needs
  hardening; the bearer model itself is fine.

- **Contract shape (discriminators/metas/deposit/expiry) is hardcoded and
  unverified against an IDL** (Info #4). Accepted out-of-scope for this gate;
  flagged for the IDL ticket.

---

## Gate mapping

REVIEW_OK (functional, `SS-0003-phase-2-review.md`) → **SECURITY_REVIEW_OK**.
No must-fix-to-pass condition (no unsafe key handling, no sensitive logging on a
live sink, no auth downgrade/unsafe fallback, no storage leak, no contract drift).
Findings #1 and #2 are required follow-ups (Medium) but do not gate this phase.
