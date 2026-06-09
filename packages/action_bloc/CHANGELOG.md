# Changelog

## 0.1.0

Initial release.

- `ActionBlocMixin<S, A>` — adds a fire-and-forget `actionStream` + `emitAction`
  to any `BlocBase`.
- `ActionBlocListener<B, S, A>` — handles actions in the widget tree;
  `listenWhen(previous, current)` filtering with listener-local previous;
  `MultiBlocListener`-compatible.
- `ActionBlocConsumer<B, S, A>` — `BlocBuilder` plus optional state and action
  listeners, with `actionListenWhen` / `stateListenWhen` filters.
- `ActionBlocObserver` — `BlocObserver` mixin exposing `onAction(bloc, ActionChange)`
  with bloc-global previous/current.
