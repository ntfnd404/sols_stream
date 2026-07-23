# Package Boundaries

Workflow Version: 3

## Hard Rules

- Owned protocol, provider-capability, and adapter package source must not import `package:flutter/*`:
  `solana_wallet`, `signaling`, `signaling_solana`. This is a source-level
  boundary, not a claim that every transitive dependency is pure Dart;
  `solana_wallet` currently reaches the Flutter-backed `secure_storage` package.
- Runtime packages may depend on Flutter plugins only for the runtime they own:
  `realtime_media` owns WebRTC; `streaming` owns video playback.
- UI code lives in `lib/feature/*` and `packages/ui_kit`.
- Cross-package deep imports from app code are forbidden.
- Consumer packages define ports; adapter packages implement them.

The canonical dependency graph lives in
[`architecture.md`](architecture.md#dependency-graph). This document defines
enforced rules and must not duplicate that graph.

## Enforcement

Architecture tests check:

- no `package:flutter/*` imports in DDD packages;
- no `signaling -> solana_wallet` dependency;
- no app-level `package:<local>/src/*` imports;
- no app-level direct Solana broadcast;
- one shared funded/bypass signaling transaction coordinator;
- absence of the removed generic wallet shared kernel and legacy signaling API.
