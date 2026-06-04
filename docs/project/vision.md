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

---

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
