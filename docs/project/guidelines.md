# Guidelines

Workflow Version: 3

# Flutter-Dart Guidelines Overlay

These rules are appended to `docs/project/guidelines.md` when the Flutter-Dart adaptor is applied.

---

## Framework Patterns

Prefer `StatelessWidget` over `StatefulWidget` wherever possible.
Move state to a BLoC or a `StatefulWidget` ancestor; keep leaf widgets stateless and `const`.

`AppScope` must sit **above** `App` in the widget tree so all features can access dependencies.
Feature scopes live inside `AppRouterDelegate.build()` — above `Navigator`, below `MaterialApp`.

Never read `InheritedWidget` inside `initState`. Use `didChangeDependencies` with `_initialized` guard.

---

## Testing Strategy

Unit-test: domain logic, BLoC event handlers, data mappers, crypto utilities.
Integration-test: full feature flows against real external systems (never mock them).
Never mock internals of `*Impl` — test consumers through interface fakes.

Test doubles location:
```
test/feature/<feature>/
  fakes/   ← working in-memory implementations
  mocks/   ← mocktail/mockito
```

---

## Error Handling

Transient errors → one-shot `Action` → `SnackBar`. Never put them in `State`.
Persistent errors → typed nullable field in `State` only when UI must stay error-visible.
Never use bare `catch (_) {}` — always log, rethrow, or emit an action.

---

## Logging

Use `dart:developer` `log()`. Never `print()`.
Never log: private keys, mnemonics, seeds, raw SDP, connection secrets, wallet addresses.

---

## Performance

Use `const` constructors. Prefer `ListView.builder` for long lists.
Never run expensive work in `build()`. Profile before optimising.

---

## Accessibility

All interactive elements need a semantic label. Minimum tap target: 48×48 dp.
Provide text alternatives for QR codes. Respect system font scaling.

---

## Platform Notes

Always declare required entitlements explicitly on macOS/iOS.
HLS is supported on Android, iOS, macOS, Web only — guard with platform check.
flutter_secure_storage requires `keychain-access-groups` entitlement on macOS.

## Design Patterns

| Pattern | Where used |
|---------|-----------|
| **Repository** | `domain/repository/` interfaces + `data/repository/` implementations |
| **Gateway** | `application/` port interfaces + `data/` adapter implementations |
| **Factory** | `FeatureScope` + `BlocFactory` — DI without a service locator |
| **Observer** | BLoC streams — UI reacts to emitted state changes |
| **Strategy** | Pluggable algorithms (coin selection, signing strategies) |

## Test Structure Mirroring

Mirror the source structure in tests:
`packages/<module>/lib/src/foo.dart` → `packages/<module>/test/foo_test.dart`

This makes it immediately clear which test file covers which source file.

## Integration Test Rule

Integration tests must run against real external implementations — never mock persistence or storage layers. If a test requires mocking the database or secure storage to pass, it is a unit test, not an integration test.
