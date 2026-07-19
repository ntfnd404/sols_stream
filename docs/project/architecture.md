# Architecture

Workflow Version: 3

Packages-first Flutter workspace monorepo. One app first, explicit module ownership,
layered internals, and lightweight guardrails around imports and topology.

---

## Philosophy

- **Feature-first app** — UI flows live under `lib/feature/`
- **Modular monolith** — business and infrastructure code split into workspace packages
- **Layered modular architecture** — package ownership and dependency direction
  are explicit, with documented exceptions instead of an unsupported claim of
  strict Clean Architecture
- **DDD where justified** — packages with independent business language own that
  language; provider capabilities are not labelled bounded contexts by default
- **Hexagonal** — consumer modules own port interfaces; adapters implement them
- **Layered guardrails** — selected boundaries are executable architecture
  tests; analyzer/DCM and documentation provide additional checks and guidance

The main design goal is **predictable growth**: new capabilities can be added without
collapsing into a shared dumping ground.

---

## Topology Standard

### Scheme A — current (default)

```text
/
  lib/                      # single Flutter app (presentation only)
    core/
    common/
    feature/
  packages/                 # workspace packages (business + infrastructure)
  docs/
  test/
  pubspec.yaml              # app + workspace root
```

Rules:
- One app at the repository root
- Reusable business and infrastructure code in `packages/`
- Keep `lib/feature/*` app-specific
- Do **not** introduce top-level `components/` for business code
- Do **not** introduce `apps/` until a second releasable client exists

### Scheme B — escalation path

Move to this only when the repository actually contains multiple products
(separate release cycles, separate branding, or separate CI lanes).

---

## Project Structure

```text
sols_stream/
├── lib/
│   ├── core/
│   │   ├── bootstrap/        # app initialisation
│   │   ├── bloc/             # app-wide BLoC observation
│   │   ├── config/           # RPC, wallet, broker, and peer-invite contracts
│   │   ├── di/               # AppDependencies, AppScope, composition lifecycle
│   │   ├── event_bus/        # AppEventBus, cross-feature application events
│   │   └── security/         # app-shell redaction and safe diagnostics helpers
│   ├── common/
│   │   ├── widgets/          # shared widgets (promoted from features)
│   │   └── extensions/       # shared Dart extensions
│   └── feature/
│       ├── app/              # root feature: App widget, routing, lock UI
│       ├── hub/              # entry hub
│       ├── home/             # home shell: transport/role selection + layout
│       ├── call/             # WebRTC call presentation
│       └── account/          # account/settings presentation
├── packages/
│   ├── solana_wallet/        # Solana identity, balance, funding, persistence, signing
│   ├── signaling/            # WebRTC/P2P signaling protocol + application ports
│   ├── signaling_solana/     # Solana adapter for signaling ports
│   ├── realtime_media/       # WebRTC peer media session runtime
│   ├── streaming/            # HLS playback/streaming runtime
│   ├── secure_storage/       # encrypted platform key-value storage
│   └── ui_kit/               # design tokens, theme
├── docs/
└── pubspec.yaml
```

---

## Dependency Graph

Arrow direction: `A → B` means A depends on B. Must remain a **DAG** (no cycles).

```text
secure_storage → flutter_secure_storage
solana_wallet  → secure_storage, solana, http
signaling      → archive, cryptography, http
signaling_solana → signaling, solana_wallet, solana, http
realtime_media → flutter_webrtc
streaming      → video_player
ui_kit         → Flutter SDK only
lib/           → package public APIs as needed
```

If a cycle appears: move only the minimum shared primitive lower, or introduce
a lightweight value object. Do not solve cycles by creating a mega-package.

---

## Package Taxonomy

### Bounded-context packages

- `signaling` — P2P signaling application language, ConnectSlot, and SDP
  protection. It does not import the Solana SDK, but its current application
  model is intentionally oriented around an on-chain rendezvous protocol.

`signaling` owns its language, application contracts, policies, and internal
implementations.

`OnChainPeerSignaling` currently calls the concrete
`PassphrasePayloadCrypto` implementation from its application layer. This is a
known dependency-direction exception tracked separately from protocol-security
work. Until a second implementation or testing need justifies a port, the
project documents the exception instead of adding an unused abstraction.

### Adapter packages

- `signaling_solana` — Solana gateway implementations for signaling ports

Adapter packages translate between a consumer-owned port and an external
system. They do not become a second owner of the consumer's domain model.

### Provider and runtime capability packages

- `solana_wallet` — provider-specific Solana identity, balance, funding,
  signing, persistence, and keypair lifecycle
- `realtime_media` — WebRTC peer connection, local/remote media lifecycle
- `streaming` — HLS playback and streaming lifecycle

Provider/runtime packages own one technical capability and expose only the
contracts required by consumers. They are not DDD bounded contexts by default.

### Multi-chain extension

Additional chains use provider-specific pairs such as `evm_wallet` with
`signaling_evm` or `bitcoin_wallet` with `signaling_bitcoin`. `signaling` keeps
consumer-owned protocol ports; each chain adapter implements them using its own
identity, signing, fee, nonce/finality, custody, and failure semantics. The app
composition root selects a compatible pair.

Do not introduce a generic wallet shared kernel, provider switches, nullable
chain fields, or universal transaction DTOs before a second provider proves a
shared consumer contract. A future portfolio/account abstraction belongs to the
consumer that needs it, not automatically to a provider package.

### Infrastructure packages

- `secure_storage` — wraps `flutter_secure_storage` (one external boundary).
  Consequently, `solana_wallet` has no direct Flutter source imports but is not
  transitively portable to a pure-Dart runtime.

### UI package

- `ui_kit` — design tokens, theme, reusable UI only. No business logic.

---

## Module Ownership

| Package | Owns |
|---------|------|
| `signaling` | P2P signaling protocol, ConnectSlot state machine, SDP encryption |
| `solana_wallet` | Solana identity, reader, signer, persistence, and environment-specific funding |
| `signaling_solana` | Generated Solana wire SDK integration, program decoders/builders, chain/reclaim/protected-slot gateways |
| `realtime_media` | WebRTC peer connection, SDP offer/answer creation, media tracks, renderer handles |
| `streaming` | HLS source/auth model, playback controller lifecycle, video-player adapter |
| `secure_storage` | Encrypted platform key-value persistence |
| `ui_kit` | Design tokens, `AppTheme`, shared UI building blocks |

Ownership rule: every non-trivial concept has **one home package**. Other packages
consume its public API and do not re-own the same concept.

---

## Public API Standard

Every package exposes:
- One public barrel: `package:<name>/<name>.dart`
- Optional DI entry point: `packages/<name>/lib/src/<name>_assembly.dart`

Everything under `src/` is private implementation detail.

Rules:
- App code imports package barrels, **never** `package:<name>/src/*`
- Packages may use `src/` imports **inside the same package**
- Cross-package deep imports are forbidden

---

## Internal Package Structure

Bounded-context packages use this as the default internal shape, adapting it
when the ownership model does not need every layer:

```text
packages/<name>/
├── lib/
│   ├── <name>.dart             # public barrel
│   └── src/
│       ├── domain/             # entities, value objects, contracts, pure policies
│       ├── application/        # use cases, gateway/codec interfaces, output DTOs
│       └── data/               # implementations, mappers, adapters internal to the module
│           ├── crypto/         # (if applicable) crypto adapters
│           └── <system>/       # (if applicable) external system adapters
└── test/
```

Layer responsibilities:
- `domain/` — what the business **is**
- `application/` — what the business **does** (use cases) and what it **needs** (interfaces)
- `data/` — **how** it's done (implementations)

Package boundaries answer "who owns this capability?"  
Layer boundaries answer "what kind of code is this?"

---

## App Layer Rules

### `lib/feature/*`

Contains **only**:
- `bloc/` — BLoC + State + Event + Action
- `di/` — FeatureScope (DI wiring)
- `view/` — screens (`view/<name>_screen.dart`) + widgets (`view/widgets/`)

Must **not** contain:
- `domain/` or `data/` folders — those belong in `packages/`
- Repository implementations
- Domain entities or interfaces
- Cross-package `src/` imports

### `lib/common/*`

App-local shared helpers only — widgets, extensions, small utilities.

Must not become a second unofficial shared platform layer. When a widget or utility
is reusable beyond this app shell, promote it into a `packages/` package.

### `lib/core/*`

Composition root, routing, config, event bus, and app-wide adapters owned by the app shell.

Allowed subdirectories: `di/`, `routing/`, `event_bus/`, `adapters/`, `config/`, `bootstrap/`.

---

## Decision Triggers

### When to create a new package

Create a package when the code has at least one of:
- Clear bounded-context ownership
- Reusable business capability independent of the app shell
- An isolated external adapter (one external boundary)
- A separate dependency profile
- Meaningful independent test surface

Do not create a package for a handful of helpers.

### When to promote from `lib/feature/*` to `packages/*`

Promote when the code becomes:
- Reusable across multiple screens or flows
- Business-oriented rather than purely presentational
- A likely future cross-app capability

### When to introduce `apps/`

Only when Scheme B conditions are actually met (second releasable app).

### When to adopt `melos`

Not by default. Add `melos` only when pub workspace + `make` become insufficient
for filtered multi-package commands, shared scripts, coordinated versioning, or
complex CI orchestration.

---

## Import Policy

### Allowed

```text
lib/feature/*         → package public barrels
lib/feature/*         → ui_kit
lib/*                 → lib/core/*, lib/common/*
module/application    → own domain
module/data           → own domain, other packages' public APIs
```

### Forbidden

```text
lib/*                 → package:<module>/src/*
packages/*            → app code in lib/*
feature X             → feature Y bloc/domain internals
lib/feature/**/view/**  → any URI containing /gateway/ or /repository/
```

---

## Guardrails

- Architecture tests enforce the boundaries listed in
  [package-boundaries.md](./package-boundaries.md).
- Dart/Flutter analyzer failures block acceptance.
- DCM currently reports advisory style/warning debt; the AIDD wrapper does not
  yet propagate those findings as a failing exit code.
- This file, `conventions.md`, `AGENTS.md`, and `CLAUDE.md` guide reviews but are
  not executable enforcement by themselves.
