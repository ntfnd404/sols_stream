# Architecture

Workflow Version: 3

Packages-first Flutter workspace monorepo. One app first, explicit module ownership,
layered internals, and lightweight guardrails around imports and topology.

---

## Philosophy

- **Feature-first app** — UI flows live under `lib/feature/`
- **Modular monolith** — business and infrastructure code split into workspace packages
- **Clean Architecture** — dependencies point inward
- **DDD / bounded contexts** — each business package owns its model and use cases
- **Hexagonal** — consumer modules own port interfaces; adapters implement them
- **Hard guardrails** — architecture docs + validator checks + import policy

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
│   │   ├── config/           # AppEnvironment, RpcEnvironment, EnvironmentLoader
│   │   ├── di/               # AppDependencies, AppDependenciesBuilder
│   │   ├── event_bus/        # AppEventBus, domain events
│   │   └── routing/          # AppRouterDelegate, AppRouter
│   ├── common/
│   │   ├── widgets/          # shared widgets (promoted from features)
│   │   └── extensions/       # shared Dart extensions
│   └── feature/
│       ├── app/              # root feature: App widget, AppScope
│       └── home/             # home screen: WebRTC + HLS + Wallet UI
├── packages/
│   ├── signaling/            # Solana on-chain WebRTC P2P signaling
│   ├── solana_wallet/        # Solana identity, keypair, funding
│   ├── secure_storage/       # encrypted platform key-value storage
│   ├── action_bloc/          # BLoC one-shot side-effects pattern
│   └── ui_kit/               # design tokens, theme
├── docs/
└── pubspec.yaml
```

---

## Dependency Graph

Arrow direction: `A → B` means A depends on B. Must remain a **DAG** (no cycles).

```text
action_bloc    → flutter_bloc
secure_storage → flutter_secure_storage
solana_wallet  → secure_storage, solana, http
signaling      → solana_wallet, solana, cryptography
ui_kit         → Flutter SDK only
lib/           → all package public APIs as needed
```

If a cycle appears: move only the minimum shared primitive lower, or introduce
a lightweight value object. Do not solve cycles by creating a mega-package.

---

## Package Taxonomy

### Business packages

- `signaling` — P2P signaling protocol, ConnectSlot, SDP encryption
- `solana_wallet` — Solana identity, SolanaSigner interface, keypair, funding

Each business package owns: domain entities, repository contracts, use cases,
and internal implementations.

### Infrastructure packages

- `secure_storage` — wraps `flutter_secure_storage` (one external boundary)

### UI package

- `ui_kit` — design tokens, theme, reusable UI only. No business logic.

### Utility

- `action_bloc` — BLoC Action stream pattern (no business knowledge)

---

## Module Ownership

| Package | Owns |
|---------|------|
| `signaling` | P2P signaling protocol, ConnectSlot state machine, SDP encryption |
| `solana_wallet` | Solana wallet identity, `SolanaSigner` interface, keypair lifecycle, devnet funding |
| `secure_storage` | Encrypted platform key-value persistence |
| `action_bloc` | `ActionBlocMixin`, `ActionBlocListener` — one-shot UI side-effects |
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

Each business package follows this internal shape:

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

This standard is enforced by:

- `docs/project/conventions.md`
- `docs/project/architecture.md` (this file)
- `AGENTS.md`
- `CLAUDE.md`
- `.claude/bin/aidd_validate.sh`
