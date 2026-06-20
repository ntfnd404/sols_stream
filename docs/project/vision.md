# Vision

Workflow Version: 3

---

## What is sols.stream

sols.stream is a cross-platform streaming platform built on Flutter and WebRTC.
It enables real-time P2P video/audio calls, live broadcasts, and stream discovery —
with signaling coordinated through the Solana blockchain.

---

## Current state

P2P WebRTC signaling via Solana on-chain ConnectSlot:
- Publisher taps "Go Live" → offer encrypted and written to Solana → shareable QR/link
- Viewer scans/pastes link → answer encrypted and written to Solana → media established
- HLS/LL-HLS playback for passive viewing

---

## Target state

| Capability | Status |
|------------|--------|
| P2P WebRTC calls (1:1) | ✅ Done |
| Solana on-chain signaling | ✅ Done |
| HLS/LL-HLS playback | ✅ Done |
| Signaling server (WebSocket fallback) | ⬜ Planned |
| Group calls (SFU) | ⬜ Planned |
| Stream catalog / discovery | ⬜ Planned |
| Screen sharing | ⬜ Planned |
| Recording / VOD | ⬜ Planned |
| Paid streams — creator tariffs (per-session / per-minute) | ⬜ Planned |
| Paid / access-controlled stream entry | ⬜ Planned |
| Platform fee + creator↔platform revenue split | ⬜ Planned |
| Donations (optional split to platform) | ⬜ Planned |
| Subscriptions (monthly — skip per-use fees) | ⬜ Planned |
| Personal cabinet / balance (debit for entry & P2P calls) | ⬜ Planned |

---

## Monetization & access (roadmap)

Planned revenue model (not yet implemented — future ticket(s); SS-0003 stays
free P2P). Captured so it is not lost.

**Model**
- **Creator tariffs** — a stream creator charges viewers per-session or
  per-minute (on-chain `price_per_session` / `price_per_minute`, already in
  `create_room`).
- **Platform fee** — the platform owner takes a fee on stream creation and/or
  entry, plus a configurable cut of creator revenue and donations (donations may
  optionally route 100% to the creator).
- **Subscriptions** — a monthly plan that waives per-use entry/creation fees.
- **Personal cabinet / balance** — fees are debited from a user's in-app balance;
  applies to paid stream entry **and** to all participants of a P2P call.
- **Access control** — paid/closed streams gate entry (on-chain `access_mode` +
  the reserved `protected_key` fields in `ConnectSlotData`, empty today).

**On-chain hooks already present:** `create_room` carries `access_mode`,
`connection_mode`, `price_per_minute`, `price_per_session`; `ConnectSlot` stores
`host/viewer_protected_key` + per-party deposits. The client centralises room
config in `signaling`'s `RoomCreationParams` (today `.p2pFree()`).

**Open questions to resolve before building (need a discovery/ADR):**
1. **Contract capabilities** — obtain the program IDL: does it implement the
   platform fee, revenue split, per-minute settlement, and deposit reclaim, or
   are those app-side? (Also blocks the deposit-reclaim work — see
   `packages/signaling/README.md` "Funds & deposits".)
2. **Custodial vs non-custodial** — a "personal cabinet balance" implies a
   custodial platform balance **or** an on-chain prepaid account; today the model
   is non-custodial (each user signs/pays with their own keypair). This decision
   reshapes `solana_wallet` and the payment UX, and revisits the "not a custodial
   wallet" non-goal below.

> Track as its own ticket via `/aidd-new-ticket` when prioritised (the contract
> IDL + the custodial-vs-on-chain ADR are prerequisites).

### Memo — finishing deposit reclaim (SS-0003 left the seam, IDL completes it)

SS-0003 shipped the IDL-independent half of deposit reclaim and left a clean
seam; the IDL ticket only has to fill the data layer. **Already in place:**
`create_room` + `open_slot` are one atomic transaction; `SignalingReclaimGateway`
(`closeSlot`/`closeRoom`) is a port with an `UnsupportedSignalingReclaimGateway`
Null-Object default; `goLive` runs best-effort compensation against it on
post-open failure; deposits are now parsed and surfaced on `ConnectSlotData`.

**First decision (from the IDL) — does the program auto-refund on expiry?**
- **Yes (deposits return at `expiresInSec`):** nothing more to build. The Null
  Object stays the permanent binding; just document it and close the item.
- **No (explicit close required):** build a real `SignalingReclaimGateway`.

**If an explicit close is required, the IDL must yield:**
1. **Discriminators** for the close/reclaim instruction(s) — `close_slot` and
   (if separate) `close_room` — added to `SignalingProgramConstants` alongside
   the existing `disc*` 8-byte arrays.
2. **Account metas + ordering** for each (which signer, which PDAs are writeable,
   rent-refund recipient) — to build the `Instruction` in `instruction_builder.dart`.
3. **Preconditions / allowed states** — who may close and in which
   `ConnectSlotState` (e.g. only `host` after `expired`, only an unclaimed slot),
   so the gateway fails cleanly instead of bouncing an on-chain error.
4. **Refund semantics** — full vs partial deposit return, and whether the room
   must be closed before/after its slots — to order the two close calls.

**Then, for mainnet durability (only in the "No" branch):** add a **persisted
reclaim ledger** (record `{roomPda, slotPda, nonces, deposits, expiresAt}` before
`write_offer`; clear on confirmed-connection or successful compensation) so a
crash mid-`goLive` does not orphan real SOL. A lazy janitor reclaims expired
ledger entries on next app start / before the next `goLive`. Reuse
`secure_storage` for the store; expose the ledger as an application port so
`signaling` stays persistence-free. Deferred deliberately until this branch is
confirmed (building it under the "Yes" branch would be dead weight).

## Non-goals

- Not a general-purpose social network
- Not a production-grade custodial wallet (devnet only for now)
- Not a Bitcoin/EVM chain product — Solana only
- Not a centralized platform — on-chain signaling by default

---

## Stakeholders

| Role | Description |
|------|-------------|
| Product Owner | ntfnd404 |
| Orchestrator | Claude Code (AIDD v3) |
| Agents | analyst, researcher, planner, implementer, reviewer, qa |

---

## Architecture summary

```
Flutter app (lib/)
    ↕
packages/signaling   ← Solana on-chain WebRTC signaling protocol
packages/solana_wallet ← Solana identity, keypair, devnet funding
packages/secure_storage ← encrypted keypair persistence
packages/ui_kit      ← design system
```

See `docs/project/architecture.md` for full topology.

---

## Why this approach

- **On-chain signaling** eliminates centralised signaling servers — no single point of failure
- **Flutter** enables one codebase for macOS, iOS, Android, Web, Linux, Windows
- **AIDD v3** methodology ensures spec-driven, reviewable, auditable development
- **Workspace packages** keep bounded contexts explicit and independently testable
