# BLoC Communication

Workflow Version: 3

Rules for coordinating independent BLoCs without making them know about each
other.

---

## Principle

Do not frame cross-feature coordination as "Bloc A talks to Bloc B". With proper
decoupling, both BLoCs depend on a shared third thing:

- a source of truth for state, or
- a typed event channel for facts.

BLoCs must not import another feature's `bloc/`, read another BLoC through
`context.read<OtherBloc>()`, subscribe to another BLoC's stream, or use
`BlocListener<OtherBloc, ...>` for cross-feature coordination.

`BlocListener` is for UI side effects in the same presentation subtree
(navigation, SnackBar, dialog), not BLoC-to-BLoC wiring.

---

## Decision Matrix

Ask these questions in order.

### 1. Is it state or a fact?

| Need | Meaning | Use |
|---|---|---|
| State | There is a current value and consumers care about "how is it now?" | State stream from a source of truth |
| Fact | Something happened at a moment in time; there is no current value | `AppEventBus` typed event |

Examples of state: current user, selected account, session lock, theme,
connectivity, current WebRTC role.

Examples of best-effort presentation facts: a stream preview started or
stopped, a peer-connected notification should be shown, or another feature may
refresh its non-critical view. Financial outcomes and session authority are
state, even when an event originally caused them.

### 2. If it is state, where does the state live?

| State kind | Abstraction | Layer / owner | Examples |
|---|---|---|---|
| Persisted, remote, OS-backed, or database-backed | Reactive repository or gateway with `current` + `Stream` / watch API | Owning package `domain` contract + `data` implementation | auth status from storage, settings from storage, Drift watch query |
| Ephemeral app runtime state with no external source | Application service / store with current value + `Stream` | Owning package `application`, or `lib/core` only when app-wide shell state | session lock, selected in-memory room, cross-screen draft |
| One-time fact | `AppEventBus` typed event | `lib/core/event_bus` event contract | peer-connected notification, non-critical presentation refresh hint |

The stream is not the architecture. The source of truth is. A repository is
correct only when it wraps a real data source. An in-memory mailbox used only to
coordinate two BLoCs is a service/store, not a repository.

---

## Allowed Patterns

### Shared State

Use this when consumers need the current value and future changes.

```text
Source of truth (repository/gateway/service/store)
  ▲ mutates / reads                 ▲ watches
Bloc A                              Bloc B
```

Rules:

- The source exposes a current value and a stream of changes.
- A BLoC subscribes in its constructor, maps changes to an internal event, and
  cancels in `close()`.
- Both BLoCs know only the shared abstraction, not each other.
- If only one consumer should mutate the state, expose a read-only interface for
  other consumers.

### Event Bus

Use this when consumers need to react to a fact and no current value exists.

```text
AppEventBus
  ▲ emit                            ▲ subscribe/filter
Bloc A                              Bloc B
```

Rules:

- Emit typed immutable `AppEvent` subtypes.
- Subscribers filter by event type.
- Subscribers translate bus events into internal BLoC events.
- Cancel subscriptions in `close()`.
- Do not reconstruct current state from event history.

`AppEventBus` is an asynchronous, in-process broadcast stream. It has no replay,
persistence, delivery acknowledgement, or subscriber-independent buffering.
Events emitted before a subscriber listens are lost. Therefore it is suitable
only for best-effort presentation coordination; durable state, financial
outcomes, and required workflow transitions must live in an owned source of
truth and be queryable after a missed notification.

Delivery order is preserved within one subscription. Subscribers own and cancel
their subscriptions; the composition root owns and disposes the bus. Emitting
after disposal throws `StateError`. A subscriber failure follows Dart stream and
zone semantics and must not be treated as delivery acknowledgement. Failure in
one listener must not prevent delivery to other active listeners;
`cancelOnError` is an explicit subscriber choice, not a bus policy. Delivery
means that the listener was invoked, not that its application logic completed
successfully.

Lifecycle teardown uses this order:

1. stop event producers;
2. close BLoCs and other consumers, which cancel their owned subscriptions;
3. cancel any remaining non-consumer subscriptions;
4. dispose `AppEventBus`.

The bus does not own subscriptions and does not add retries, timeouts,
acknowledgements, or forced cancellation. A leaked or paused subscription is an
owner lifecycle defect, not something the bus attempts to recover.

### Composition-Time Parameters

If two BLoCs only need the same initial parameter, compute it once from the same
source of truth and pass it to both factories.

```dart
final initialRole = intent.initialWebRtcRole;
final homeBloc = HomeScope.createBloc(context, intent: intent);
final callBloc = CallScope.createBloc(context, role: initialRole);
```

Do not create one BLoC and read its state to create another BLoC when the value
already comes from a shared input such as route intent.

### Coordination

If the requirement is "when A and B are both ready, do C", do not spread that
logic across A and B. Create an explicit coordinator:

- a use case / application service when it belongs to business or application
  workflow, or
- a dedicated BLoC when it is a presentation workflow.

The coordinator depends on sources. The coordinated BLoCs stay independent.

---

## Anti-Patterns

- Passing a BLoC into another BLoC.
- Importing another feature's `bloc/`.
- `context.read<OtherBloc>()` for cross-feature coordination.
- One BLoC subscribing to another BLoC's `stream`.
- `BlocListener<OtherFeatureBloc, ...>` to drive another feature.
- Event bus for state.
- Repository with no real data source.
- Global god-bus carrying unrelated state and commands.
- Empty one-method use cases that only delegate to a repository/service with no
  added rule, translation, or orchestration.

---

## Layer Notes

Use cases are application-layer business rules: they orchestrate a user or system
operation. Domain-layer business rules are invariants of the business concepts
themselves.

Do not put use cases in `domain/`. Put them in an owning package's
`application/` layer when they add real value. If the operation is pure
delegation, call the repository/gateway/service directly.

For app-only presentation flows, `lib/feature/*` remains `bloc/di/view` only.
If shared state or coordination becomes reusable business/application logic,
promote it into the owning package instead of adding `application/` inside the
feature.
