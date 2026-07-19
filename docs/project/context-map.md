# Context Map

Workflow Version: 3

The canonical package dependency graph is maintained only in
[`architecture.md`](architecture.md#dependency-graph). This map describes
relationships and published language, not build dependencies.

## Bounded Contexts And Capabilities

| Context / Package | Type | Published Language | Relationship |
|---|---|---|---|
| `solana_wallet` | provider capability | signer, reader, funding service, assembly | Owns the current local-key identity/persistence, balance, signing, and transaction semantics; production custody remains an explicit release decision |
| `signaling` | bounded context | peer signaling, participant identity, gateway ports | Owns the on-chain rendezvous application language without Solana SDK types |
| `signaling_solana` | anti-corruption adapter | Solana implementations of signaling ports | Translates signaling operations to generated Solana wire operations |
| `realtime_media` | runtime capability | media session controller and handles | Owns WebRTC runtime lifecycle |
| `streaming` | runtime capability | HLS source and playback controller | Owns playback lifecycle |
| `secure_storage` | infrastructure adapter | secure key-value storage | Isolates platform-backed encrypted persistence |
| `ui_kit` | UI package | theme and tokens | Supplies presentation primitives only |

## Context Rules

- `signaling` owns signaling protocol language; `signaling_solana` owns Solana
  wire format and program-specific translation.
- `signaling` must not import `solana_wallet`; the app composition root binds
  both through `signaling_solana`.
- `signaling_solana` is the anti-corruption layer between the signaling
  protocol and Solana wallet/transaction capabilities.
- A future chain adds its own `<chain>_wallet` and `signaling_<chain>` adapter.
  Generic wallet contracts are introduced only for a demonstrated shared
  consumer use case, never by erasing provider-specific transaction semantics.
- Runtime packages are not DDD contexts. They may expose platform render handles
  when UI rendering requires them.
- App features consume package public APIs only.
- “Flutter-free” for wallet/signaling packages currently means no direct
  `package:flutter/*` source import. `solana_wallet` still has a transitive
  Flutter toolchain dependency through `secure_storage`; pure-Dart portability
  is not claimed.
