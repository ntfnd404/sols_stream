# action_bloc

Typed, one-shot **side effects** for `flutter_bloc` — navigation, SnackBars,
dialogs, focus changes — delivered through a fire-and-forget action stream that
lives **outside** BLoC state.

State describes *what the UI looks like*; actions describe *something that
should happen once*. Putting one-shot effects in state forces awkward
"consumed" flags and replays on rebuild. `action_bloc` keeps them separate.

## Install

```yaml
dependencies:
  action_bloc:
    git: # or path/version once published
  flutter_bloc: ^9.0.0
```

## Quick start

Add the mixin to a BLoC and emit actions:

```dart
sealed class CounterAction {}
class CounterMaxedOut extends CounterAction {}

class CounterBloc extends Bloc<CounterEvent, int>
    with ActionBlocMixin<int, CounterAction> {
  CounterBloc() : super(0) {
    on<Increment>((event, emit) {
      final next = state + 1;
      emit(next);
      if (next >= 10) emitAction(CounterMaxedOut());
    });
  }
}
```

Handle them in the widget tree:

```dart
ActionBlocConsumer<CounterBloc, int, CounterAction>(
  actionListener: (context, action) => switch (action) {
    CounterMaxedOut() => ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Max reached')),
    ),
  },
  builder: (context, state) => Text('$state'),
)
```

Or listen without building:

```dart
ActionBlocListener<CounterBloc, CounterAction>(
  listener: (context, action) { /* effect */ },
  child: child,
)
```

## Delivery contract: fire-and-forget

Actions are **best-effort** UI effects, not state:

- `actionStream` is a broadcast stream with **no buffer**.
- An action emitted while **no listener is subscribed is dropped** — an effect
  with no one to handle it is a no-op, by design.
- A **late subscriber does not receive past actions**. There is no replay.
- The action **carries its own data** (e.g. `ShowSnackBar(message)`). No state
  snapshot is delivered with it; if a handler needs current state, read
  `bloc.state` directly at that point.

Emit actions in response to events; treat a missed action during
teardown/initialization as harmless.

## Filtering with `listenWhen`

`listenWhen` (and `ActionBlocConsumer.actionListenWhen`) receives the previous
and current action, mirroring `BlocListener.listenWhen`:

```dart
ActionBlocListener<MyBloc, MyAction>(
  // Suppress the same action emitted twice in a row.
  listenWhen: (previous, current) => previous != current,
  listener: (context, action) { /* effect */ },
  child: child,
)
```

`previous` is **listener-local**: it tracks actions delivered to *this*
subscription (null on the first action and after a bloc swap), and updates on
every action whether or not it passed the filter. This differs from the
**bloc-global** `previous` reported to `ActionBlocObserver` (see below).

## Observing actions globally

Mix `ActionBlocObserver` into your `BlocObserver` for logging/analytics:

```dart
final class AppBlocObserver extends BlocObserver with ActionBlocObserver {
  @override
  void onAction(BlocBase<Object?> bloc, ActionChange<Object?> change) {
    log('${bloc.runtimeType}: ${change.current}');
  }
}
```

Here `change.previous` is the **bloc-global** last action (null on the first
emission), independent of any listener.

## `MultiBlocListener` compatibility

`ActionBlocListener` is a `SingleChildWidget`, so it composes inside
`MultiBlocListener` alongside regular `BlocListener`s.

## Requirements

`ActionBlocListener` / `ActionBlocConsumer` resolve the BLoC from the nearest
`BlocProvider` when `bloc` is omitted. The target BLoC must implement
`ActionBlocStreamable<A>` (via `ActionBlocMixin` or directly); otherwise the
listener throws a `StateError` on mount.

## Public API

| Symbol | Kind | Description |
|---|---|---|
| `ActionBlocMixin<S, A>` | mixin | Adds `actionStream` + `emitAction` to a `BlocBase` |
| `ActionBlocListener<B, A>` | widget | Calls `listener(context, action)`; filter via `listenWhen(previous, current)` |
| `ActionBlocConsumer<B, S, A>` | widget | `BlocBuilder` + optional state/action listeners |
| `ActionBlocObserver` | mixin | Mix into a `BlocObserver`; override `onAction(bloc, ActionChange)` |
| `ActionChange<A>` | class | Observer payload: bloc-global `previous` + `current` |
| `ActionBlocStreamable<A>` | interface | Exposes `actionStream` |
| `ActionBlocStateStreamable<S, A>` | interface | `StateStreamable<S>` + `ActionBlocStreamable<A>` |

## Dependencies

`flutter_bloc`, `nested` (for `MultiBlocListener` compatibility), Flutter SDK.

## Extraction checklist (when moving to its own repo)

- Remove `publish_to: none` and `resolution: workspace` from `pubspec.yaml`.
- Add `repository` / `homepage` / `issue_tracker` / `topics` to `pubspec.yaml`.
- Add a package-local `analysis_options.yaml` (lints are currently inherited
  from the monorepo root and will be lost on extraction).
- Confirm the SDK lower bound (`environment.sdk`) suits the target audience.
