# Conventions

Workflow Version: 3

# Flutter-Dart Conventions Overlay

These rules are appended to `docs/project/conventions.md` when the Flutter-Dart adaptor is applied.

---

## Architecture: Layered Modules + Ports/Adapters

The project uses package ownership and consumer-owned ports without claiming a
repository-wide textbook Clean Architecture layout. The canonical topology and
dependency graph live only in [architecture.md](./architecture.md); do not copy
them into overlays or conventions.

### Package Type Rules

| Type | Rule |
|------|------|
| **bounded context** | Owns its language, policies, application ports, and internal adapters. |
| **adapter** | Implements a consumer-owned port and translates an external system. |
| **runtime capability** | Owns one platform runtime lifecycle such as WebRTC or playback. |
| **infrastructure** | Isolates a platform or provider boundary such as secure storage. |
| **UI** (`ui_kit`) | Design system only. No business logic. |

---

### DDD Package Boundaries

- A bounded context owns its language. Do not share mutable "core domain" models across contexts.
- Ports belong to the consumer context. Adapter packages implement those ports; they do not define the contract for the consumer.
- DDD/application packages must not import `package:flutter/*`.
- Platform/runtime packages may depend on Flutter plugins only inside their runtime adapter surface.
- App `lib/feature/*` is presentation-only: BLoC, UI state, widgets, and feature DI.
- Secret-bearing value objects and DTOs must provide redacted diagnostics; never rely on default `toString`.
- Raw external exceptions must not cross adapter boundaries or reach UI/logs.
  Convert them to sanitized typed failures; textual redaction alone is not a
  security boundary for arbitrary provider bodies.

### Developer Tool Ownership

- Prefer Flutter/Dart CLI capabilities for root development workflows; do not
  maintain a custom server or wrapper when the SDK already owns the behavior.
- Root app tooling, when genuinely necessary, lives in root `tool/`;
  package-specific tooling lives in the owning package's `tool/`.
- Tool entrypoints live directly under `tool/`. Capability-specific tool code
  uses a named folder such as `tool/idl/`. Reserve `tool/support/` for code
  genuinely shared by multiple commands; do not use `tool/src/`, which has no
  package-privacy meaning.
- Tool process settings use `config/tooling/*`, never Flutter dart-define files.
- Wire offsets, protocol ranges, and process exit codes must use named constants
  with comments explaining the external standard or binary layout.
- Versioned Solana IDL belongs to `signaling_solana`; `signaling` remains
  independent of Solana wire artifacts.

---

## Architecture Patterns

### Strategy over `switch` on type

When a use case branches by entity type or domain type, register a **Strategy** per type instead of `switch(entity.type)`. Each strategy declares which type it supports; the use case asks the registry.

```dart
// ❌ Closed for extension
class SignTransactionUseCase {
  Future<String> call(Transaction tx) {
    switch (tx.kind) {
      case TxKind.p2pkh: ...
      case TxKind.p2wpkh: ...
    }
  }
}

// ✅ Strategy registry — adding a new kind doesn't touch the use case
abstract interface class SigningStrategy {
  bool supports(TxKind kind);
  Future<String> sign(Transaction tx);
}
```

OCP: adding a new kind = adding a new strategy, never editing the use case.

### Gateway interfaces belong in `domain/` (DIP)

The high-level module declares the contract; the low-level module implements it.

- `XxxGateway` interface lives in `<consumer>/domain/gateway/`
- Implementation lives in the infra package (e.g. `bitcoin_node/`)
- Never put the gateway interface in the adapter package — that inverts DIP

### Thin use case rule

Do not create a use case that only delegates to a single repository or gateway method with no added logic. Call the repository/gateway directly. A use case is justified only when it:

- Orchestrates multiple calls, or
- Translates between bounded contexts, or
- Enforces a domain rule, or
- Handles scenario-specific exceptions

### ID generation lives in the Application layer

Generating an aggregate ID is a use-case responsibility, not a repository concern. Repositories receive a fully-formed entity. This keeps repositories CRUD-only.

---

## State Management: BLoC Only

- **BLoC only** — no Cubits (enforced by linter)
- Events: past-tense user actions (`FeatureItemsRequested`, `ThemeChanged`)
- State: hand-written immutable class; use an enum `status` only when the UI has
  meaningful process phases. This project does not use State code generation.
- `abstract interface class` for interfaces; `Impl` suffix for implementations
- Observable changes are represented by new immutable State snapshots. Private
  BLoC fields may own dependencies, subscriptions, timers, cancellation or
  opaque runtime handles, but not presentation values that affect later
  transitions without a new State emission.
- **Never** expose public fields or methods on BLoC — all logic via events
- Inside an asynchronous event handler, check `emit.isDone` before emitting
  after an async gap. `isClosed` is a lifecycle check, not a substitute for the
  handler's emitter completion contract.

---

## BLoC State Discipline

State carries **only persistent UI signals**. One-shot effects go to a separate Action stream.

### What belongs in `State`

- `status` enum (process phase)
- Data lists, currently-rendered values
- Typed nullable failure for **persistent** error rendering (`KeysException? failure`) — only when the error is meant to stay visible until the user acts

### What does NOT belong in `State`

- `Exception? exception` — never. A transient error is not state.
- `lastErrorMessage` — never. Same reason.
- Navigation triggers, focus requests, dialog flags — these are actions, not state.
- Inter-event values that affect observable behavior belong in `State` so
  transitions remain explicit and testable. Private fields are allowed only
  for owned runtime handles and bookkeeping that are not presentation state.
- A final reference to an externally owned platform handle is an opaque
  capability reference, not a claim that the platform object is deeply
  immutable. UI-visible handle replacement still requires a new State snapshot.

### Status enum standard

```dart
enum XxxStatus { idle, processing }
```

- Choose names that describe the actual UI contract and avoid synonymous phases
  such as both `initial` and `idle` without a behavioral difference.
- A persistent terminal or retryable failure may be represented by a typed
  failure field and, when useful, an `error` status. One-shot feedback remains
  an Action.
- `status` and `failure` must describe one coherent snapshot. Do not reset to
  `idle` when the UI still renders a persistent failure.

### Side-effect channels

Two distinct channels for effects outside `State`. The one-line distinction:

> **Action = "the feature talks to its own UI."**
> **EventBus = "the feature talks to another feature, without knowing which."**

| Channel | API | Direction | Coupling | Use when |
|---|---|---|---|---|
| **Action stream** | `emitAction(XxxAction(...))` + `EphemeralBlocListener` | BLoC → UI of the **same** feature | UI subtree listens directly | SnackBar, navigation, focus, clipboard, dialog |
| **Event bus** | `_eventBus.emit(XxxAppEvent(...))`; subscribers use `_eventBus.on<XxxAppEvent>()` and cancel in `close()` | Cross-feature presentation coordination | Emitter and subscribers depend only on the event contract | Broadcast → refresh; cross-feature notifications |

Why both exist:
- **Action stream** keeps presentation effects *out of state* so widget rebuild does not retrigger SnackBars / navigation. Action is consumed once, then gone.
- **EventBus** keeps BLoCs *out of each other's import graph*. Even `BlocListener<OtherBloc, OtherState>` is forbidden across features — it couples presentation to a concrete BLoC and inverts the dependency direction. EventBus carries typed `AppEvent` subtypes; subscribers attach independently.

Rules:
- Never route UI effects (SnackBar, navigation) through the event bus — couples presentation to the bus and inverts dependency direction (presentation → domain becomes domain → presentation).
- Never route cross-feature notifications through `emitAction` — actions are scoped to one BLoC's widget subtree; another feature will never see them.
- Never use `BlocListener<OtherFeatureBloc, …>` across features — use EventBus.
- Never use the event bus for state. If consumers need "how is it now?", use a shared state source instead.
- Never make one BLoC subscribe to another BLoC. Subscribe to a repository/gateway/service/store stream or to `AppEventBus`.
- Broad `catch (e, stack)` in a BLoC handler **must** `emitAction(XxxUnexpectedFailedAction())` **before** `addError(e, stack)` — the user must see feedback even if the BLoC closes afterward.

For the full state-stream vs event-bus decision matrix, see [bloc-communication.md](./bloc-communication.md).

### Action naming

All concrete action classes end with `Action`, symmetric with `Bloc / Event / State`. Example: `FeatureErrorOccurredAction`, `FeatureSendFailedAction`.

All concrete BLoC input classes end with `Event`; all state classes end with
`State`. Each BLoC uses the classic aggregate files `*_bloc.dart`,
`*_event.dart`, `*_state.dart`, and optional `*_action.dart`. All concrete
types of the same category live in that category file; `events/` and
`actions/` subdirectories are forbidden. Internal callback events remain
private to the BLoC library.

### Application events versus domain events

- `AppEvent` is an in-process, cross-feature notification carried by
  `AppEventBus`.
- Domain events belong inside their bounded-context package and end with
  `DomainEvent`.
- Presentation or runtime lifecycle notifications must not be named domain
  events.

---

## Layered Error Handling

Each layer handles only the errors that belong to its contract.

| Layer | Responsibility | Catch pattern |
|---|---|---|
| **Gateway / DataSource** | Translate external `Exception` failures into consumer-owned exceptions while allowing programming `Error` values to propagate | `on Exception catch (_, stack)` + `Error.throwWithStackTrace(DomainException(), stack)` |
| **Use Case** | Catch only exceptions that are part of the use-case scenario (cross-BC translation, algorithm fallbacks, security sanitization) | **Selective** `on X catch` + `on Y { rethrow }` — no broad `catch (e, stack)` unless justified |
| **BLoC / Controller** | Catch bounded-context domain exceptions for UI feedback | `on XxxException catch (e) → emitAction`; unexpected → `addError` |
| **Domain Service** | Mostly no `try/catch`; only expected algorithm branches (e.g. `InsufficientFundsException` inside a coin-selection loop) | — |

### Selective catches in use cases

Broad `catch (e, stack)` in a use case **masks programmer errors** (TypeError, RangeError) as domain exceptions. Hides bugs from the zone handler.

```dart
// ❌ Hides bugs
try {
  return await _doWork();
} catch (e, stack) {
  Error.throwWithStackTrace(const SomeException(), stack);
}

// ✅ Selective — programmer errors propagate
try {
  return await _doWork();
} on KeysStorageException catch (_, stack) {
  Error.throwWithStackTrace(const FeatureStorageException(), stack);
} on FeatureException {
  rethrow;
}
```

If there is no language translation and no recovery — drop the `try/catch` entirely. Pure delegation is fine.

### Typed exception at a layer boundary

A typed wrapper is justified when at least one material contract change holds:

| Criterion | Question |
|---|---|
| (a) Change abstraction | Does the wrapper translate vocabulary across BCs? |
| (b) Hide secrets | Could the underlying exception's message leak sensitive data? |
| (c) Can recover | Can the caller distinguish typed wrappers and act differently? |

Adding context alone does not justify another exception type. Preserve a stack
when translating, but do not retain provider objects or messages. Do **not**
dismiss a real boundary contract merely because current consumers use generic
catching; consumer habits do not define the layer contract.

### `rethrow` vs `Error.throwWithStackTrace`

- `rethrow` — re-throws the **same** exception object. Use when adding no translation.
- `Error.throwWithStackTrace(newException, stack)` — creates a **new** exception while preserving the original stack. Use when translating across a boundary.
- **Never** `throw e` — loses the stack trace.

```dart
// ✅ rethrow — same type, same instance
on TransactionException {
  rethrow;
}

// ✅ throwWithStackTrace — new domain exception, original stack preserved
} catch (_, stack) {
  Error.throwWithStackTrace(const TransactionFetchException(), stack);
}
```

### `on Exception catch` at infrastructure boundaries

Use `on Exception catch` (not bare `catch`) when wrapping infrastructure calls
to let Dart `Error` subclasses (`TypeError`, `AssertionError`, `RangeError`)
propagate to the zone handler — these are programmer errors, not domain exceptions.

```dart
// ❌ Masks programmer errors as domain exceptions
try {
  return await _gateway.fetchBalance(address);
} catch (e, stack) {
  Error.throwWithStackTrace(const BalanceFetchException(), stack);
}

// ✅ Programmer errors propagate; Exception subclasses are caught
try {
  return await _gateway.fetchBalance(address);
} on Exception catch (_, stack) {
  Error.throwWithStackTrace(const BalanceFetchException(), stack);
}
```

---

## Dependency Injection: Constructor-Based

- Constructor-based DI (no GetIt or service locator)
- `InheritedWidget` at feature scope
- `Scope` pattern: `FeatureScope.createBloc(context)` + `AppScope(dependencies)`
- `AppDependencies` is the only application-lifetime instance holder
- `AppBootstrap` initializes process-global SDK state but stores no runtime instances
- `AppScope` stores one dependency-container reference and owns its widget-tree lifecycle
- Replacing the app dependency graph at runtime is forbidden; restart the composition root
- Runtime SDK handles are created and closed by their owning module assemblies
- `AppResourceDisposalStack` registers whole assemblies/resources, never their private internals
- DI build failures are reported, cleaned up, and rethrown with the original stack trace
- Scope factory naming: public static method `createBloc(...)`, private state field `_blocFactory`, inherited field `blocFactory`
- Use `Factory<T>` / `ParamFactory<T, P>` from `lib/core/di/typedefs/factory.dart` for DI factories
- Stateful features own a `di/` directory with their scope and BLoC factory;
  view-only features do not add empty layers.

---

## Feature Organization

Feature = **BLoC + DI + View only** — no domain or data code inside a feature.
Domain and data are shared exclusively via packages.
Platform/runtime capability ownership also belongs in packages, not features:
WebRTC peer connections, media streams, HLS playback controllers, cryptography,
storage, RPC/chain adapters, and broker clients are package responsibilities.
Feature BLoCs orchestrate those package APIs and expose presentation state only.

Media controls must name their direction. Local publication controls affect
outgoing senders only; participant playback controls affect incoming receivers
only. Hiding a widget is not equivalent to stopping capture or detaching an RTP
sender. Route session type and participant role are separate typed values and
must not be encoded into one intent enum.

```
lib/feature/<feature>/
├── bloc/           # BLoC + State + Event + optional Action
├── di/             # Scope + BLoC factory when the feature owns state
├── model/          # Optional presentation-only values
└── view/           # Screens and widgets
```

The root `app` feature may additionally own `routing/` and `lock/`. A view-only
feature may contain only `view/`. Split a feature only after it contains
multiple independent workflows with distinct state and lifecycle.

### Workflow Ownership

A feature is an app presentation module, not a bounded context. Each independent
presentation workflow gets its own BLoC and scope when it has distinct state
and lifecycle.

### Cross-Feature Communication

Features are independent presentation modules. They **must not** import each
other's `bloc/` internals. Allowed channels:

- **AppEventBus** — typed `AppEvent` subtypes for cross-feature notifications
- **Shared state source** — repository/gateway/service/store stream when multiple consumers need the same current value
- **Router** — composition point (`AppRouterDelegate.build()`)
- **AppScope** — exposes the app-level dependency container and closes its owned lifecycle

Shared UI moves to `lib/common` when app-specific or `ui_kit` when reusable. A
feature does not publish a `shared/` API for other features.

Direct BLoC-to-BLoC subscription across features is forbidden because it
couples presentation modules through concrete state machines.
Do not create one BLoC from another BLoC's state when both can be created from the same route parameter or dependency.
See [bloc-communication.md](./bloc-communication.md) for the full decision matrix.

---

## Domain Model Policy

**Never** use API/database types in domain layer:
- Decoupling from API changes
- Type safety with domain enums
- Testability without API dependencies
- Use factory constructors for mapping: `fromApi()`, `fromDb()`, `tryFromApi()`

---

## Testing Discipline

### Test double placement

Test doubles (fakes, mocks, stubs) **never** live inline in a test file or as private `_Class` at the bottom. Each lives in its own file under a role-named subfolder.

```
test/feature/<feature>/
  <test_name>_test.dart
  fakes/
    fake_<name>.dart        ← working in-memory implementation
  mocks/
    mock_<name>.dart        ← mocktail/mockito, verifies interactions
```

**No `helpers/` folder.** Use `fakes/` or `mocks/` only.

### xUnit taxonomy

- `Fake*` — working simplified implementation
- `Mock*` — mocktail/mockito; verifies call expectations
- `Stub*` — minimal concrete; returns fixed values; no expectations
- `Spy*` — records calls for later assertion without blocking

### Test through interfaces, not implementations

Unit-test consumers through interface fakes/mocks. **Never** mock dependencies of an `*Impl` to test the impl itself — that tests implementation details. Impls are tested via integration tests against the real external system.

```dart
// ❌ Tests GatewayImpl by mocking its internal http.Client
final gateway = BlockGenerationGatewayImpl(rpcClient: BitcoinRpcClient(..., client: mockHttp));

// ✅ Test the BLoC through a fake gateway
final bloc = RegtestMiningBloc(blockGenerationGateway: FakeBlockGenerationGateway());
```

### mocktail constraints

- Mock `abstract class` or `abstract interface class` only — **never** `final class`.
- Declaration: `class MockFoo extends Mock implements FooInterface {}`
- Prefer `Fake*` over `Mock*` when you don't need to assert call counts or argument capture.

---

## Generic Design Rules

### Wrapper over parallel maps

When a `Map<String, X>` needs additional metadata per entry (e.g. `isStochastic`), do **not** add a parallel `Map<String, bool>` — it duplicates the same name-as-identity fragility (silent overwrite on duplicate key) and couples two structures by a string.

Introduce a typed wrapper instead:

```dart
final class StrategyResult {
  final String name;
  final bool isStochastic;
  final Result result;
}
```

Use `List<StrategyResult>` (preserves order) or `Map<String, StrategyResult>` (lookup by name).

### Non-instantiable groupings: functions vs constants class vs static-method class

When a set of related items has no instance state, pick the form by what is actually being grouped — not by habit:

1. **Only named constant values, no behavior** → `abstract final class XxxConstants` with `static const` fields, no constructor.
   Example: `SignalingProgramConstants`, `SignalCryptoConstants`, `SignalingProtocolConstants`.

2. **Independent stateless functions with no shared private helpers, where a class name would add nothing over the function names** → top-level functions in a focused file.
   Example: `instruction_builder.dart` (`buildCreateRoom`, `buildOpenConnectSlot`, ...), `borsh_writer.dart` (`bString`, `bVec`).

3. **A cohesive service**: operations share a private helper, or the class name documents a concept the method names don't (a parser, a codec, a crypto service) → `final class Xxx { const Xxx._(); static ... }` (private constructor, `final` to block subclassing).
   Example: `PassphrasePayloadCrypto` (encrypt/decrypt share key derivation), `PeerInviteCodec` (`decode` only makes sense named after what it decodes).

Do not add `abstract` to case 3 — the private constructor already makes the class non-instantiable; `abstract` adds nothing once a constructor exists. Do not wrap case 2 in a class merely to satisfy `avoid_classes_with_only_static_members` — the lint accepts an explicit private constructor (case 3) precisely for groupings that earn it.

### External dependency threshold

Use a maintained dependency for generic, well-established behavior when it
reduces lifecycle or correctness risk. Keep code in-house only when behavior is
project-specific, the implementation is genuinely smaller than the dependency
surface, and the team accepts ownership of tests and maintenance. Do not copy a
third-party implementation into `lib/core` merely to reduce dependency count.

---

## Code Optimization Rules

- **Function length**: decompose methods over ~80 lines
- **No magic numbers**: all numeric literals (except 0, 1, -1) must be named constants
- **No dead code**: version control preserves history
- **Single responsibility**: if describing a method requires "and", split it
- **Loop complexity**: filter → transform → accumulate as separate pipeline steps

---

## Working Method

### Verify library claims via pub-cache

Before asserting how a third-party library is structured (a class exists, a mixin is exposed, a method signature), **read the source** in `~/.pub-cache/hosted/pub.dev/<package>-<version>/` and cite `file.dart:line`.

```bash
find ~/.pub-cache -path '*<package>-<version>*/lib/src/*.dart'
grep -rn '<ClassName>' <path>
```

Applies to all roles writing implementation or review notes about library internals — `researcher`, `planner`, `implementer`, `reviewer`. The `dart` MCP server's `read_package_uris` and `rip_grep_packages` tools achieve the same with lower token cost; prefer them when available.

Rationale: model guesses about library APIs are wrong often enough that one citation per non-trivial claim saves a round of corrections.

---

## Hard Rules (Never Violate)

```
No `!` null assertion — extract to local variable, null-check
No `dynamic` in owned APIs, DTOs, or JSON parsing — use `Object` or `Object?`.
An exact third-party SDK signature may require `dynamic`; confine it to that
adapter, document the requirement, and convert immediately.
No `print` — use `dart:developer` log or project logger
No Cubit — BLoC only
No GetIt or service locator — constructor DI + InheritedWidget
No private `_buildXxx` methods — extract as separate widget classes
No relative imports in production `lib/` — use `package:` imports. Test-only
helpers and package-local `test/tool` internals may use relative imports.
No `BlocProvider.value` — always `BlocProvider(create: ...)`
No passing BLoC as constructor parameter to a Widget — use `context.read<T>()`
No `BlocProvider(create: (_) => widget.bloc)` — hands lifecycle to provider while BLoC was created externally
No `^` in package dependency versions — use exact package versions. SDK
environment constraints may use the supported caret range.
No repository/service implementations inside a feature directory — use module `data/`
No entities or interfaces inside a feature directory — use module `domain/`
No imports from another feature's `bloc/` or `domain/` — cross-feature only via event bus or router
No BLoC-to-BLoC subscriptions — use a shared state source or `AppEventBus`
No event bus for state — use repository/gateway/service/store stream
No repository without a real data source — use an owning package/app-shell service/store for ephemeral app state
No imports of module `src/data/*` from features — use public API (barrel) only
No deep-import `package:<module>/src/*` across package boundaries. Tests inside
the owning package may import their own `src` to verify private adapters.
No import of app code (`lib/`) from a workspace package
No top-level `components/` directory — business code belongs in `packages/`
No god-object BLoCs handling multiple flows — one BLoC per flow
No raw provider `Exception` object in BLoC state. A sanitized typed failure is
allowed when the UI must persist and render it.
No contradictory `status`/`failure` snapshot. An `error` status is allowed when
it is part of the explicit UI contract.
No broad `catch` in infrastructure or use cases that converts Dart `Error`
values into expected failures.
No `throw e` — use `rethrow` or `Error.throwWithStackTrace(newException, stack)`
No inline test doubles — `fakes/` or `mocks/` subfolders only, never `helpers/`
No mocktail on `final class` — only `abstract class` or `abstract interface class`
No mocking dependencies of `*Impl` to unit-test the impl — test through interfaces
No import of `/gateway/` or `/repository/` paths from `lib/feature/**/view/**`
Never commit with analyzer warnings/infos
```

---

## Navigation: Navigator 2.0

Use a custom `AppRouterDelegate` that wraps `Navigator`.
This is the only way to place feature scopes **below `MaterialApp`**
(so `Theme`, `MediaQuery`, `Localizations` are available)
but **above `Navigator`** (so all pushed routes share the same BLoC instances).

```dart
// AppRouterDelegate wraps Navigator with feature scopes above it
class AppRouterDelegate extends RouterDelegate<AppRoute>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoute> {
  @override
  Widget build(BuildContext context) {
    return FeatureScope(
      child: AnotherScope(
        child: Navigator(
          key: navigatorKey,
          pages: _buildPages(),
          onPopPage: _onPopPage,
        ),
      ),
    );
  }
}
```

Never wire feature scopes inside individual `Page`/`Route` widgets —
BLoC instances will be recreated on every navigation push.

---

## Monorepo Topology Rules

- Default topology is **Scheme A**: one Flutter app at the repo root, reusable code in `packages/`.
- Do **not** create a top-level `components/` directory for business code — use `packages/`.
- Introduce `apps/` only when a second independently releasable app actually exists.
- Do **not** adopt `melos` by default. Add it only when pub workspace + `make` stop being sufficient for filtered multi-package commands, shared scripts, coordinated versioning, or complex CI orchestration.

---

## `lib/core/` Mandate

`lib/core/` contains **only**:
- `bloc/` — app-wide BLoC observation
- `bootstrap/` — process-global app initialisation
- `config/` — validated app environment contracts
- `di/` — composition root and application-lifetime ownership
- `event_bus/` — `AppEventBus` and cross-feature application events
- `security/` — app-shell redaction and safe diagnostics helpers

**Not allowed in `lib/core/`:**
- UI theme, tokens, fonts → `ui_kit`
- Extensions without architectural role → `lib/common/`
- Domain logic → `packages/*`
- Feature state and routing → `lib/feature/*`

Cross-package adapters belong in an owning adapter package. Do not create
`lib/core/adapters` as an escape hatch for dependency cycles.

---

## `lib/common/` Guard

`lib/common/` is for app-local shared helpers only (widgets, extensions, small utilities).

It **must not** become a second unofficial shared platform layer. If a type or UI primitive is reusable beyond this app shell, promote it into a `packages/` package.

---

## Design Principles

SOLID, KISS, YAGNI, GRASP (High Cohesion, Low Coupling).

Patterns in use: Repository, Gateway, Factory, Observer, Strategy, Ports & Adapters.

Each entity has **one owner package** — no shared ownership of the same concept across packages.

---

## BLoC Broad Catch Ordering

Broad `catch (e, stack)` in a BLoC event handler **must** call `emitAction(XxxUnexpectedFailedAction())` **before** `addError(e, stack)`. The user must see feedback even if the BLoC closes after the error.

```dart
// ✅ Action first, then addError
} catch (e, stack) {
  emitAction(const XxxUnexpectedFailedAction());
  addError(e, stack);
}
```

---

## README Touch Rule

Any change to a package's layer structure — subfolder add, remove, or rename under `domain/`, `application/`, or `data/` — must update that package's `README.md` in the same commit. This is a process rule; reviewer discipline is the enforcement mechanism.

---

## Dependencies

- Use **exact versions**: `solana: 0.32.0+1`, not `^0.32.0+1`.
- List dependencies alphabetically within each group in `pubspec.yaml`.
