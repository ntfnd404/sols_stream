# Code Style Guide

Workflow Version: 3

# Flutter-Dart Code Style Overlay

These rules are appended to `docs/project/code-style-guide.md` when the Flutter-Dart adaptor is applied.

---

## Formatting

- Page width: **120 characters**
- **Always** use trailing commas in multi-line constructs
- **Always** use curly braces in `if`/`for`/`while` — never omit
- **Always** use single quotes for strings
- **Always** add blank line before `return` when preceding code exists (except arrow functions)

## Naming

| Construct | Convention | Example |
|-----------|-----------|---------|
| Classes / Interfaces | `UpperCamelCase` | `FeatureRepository` |
| Implementations | `UpperCamelCase` + `Impl` | `FeatureRepositoryImpl` |
| Enums | `UpperCamelCase` | `FeatureStatus` |
| Enum values | `lowerCamelCase` | `FeatureStatus.loading` |
| Methods / fields | `lowerCamelCase` | `generateAddress` |
| Private members | `_lowerCamelCase` | `_featureRepository` |
| Files | `snake_case.dart` | `feature_repository.dart` |
| Constants | `lowerCamelCase` | `defaultTimeout` |

## Class Member Ordering

The project uses the enforceable DCM 1.38 default order:

1. Public fields
2. Private fields
3. Public getters
4. Private getters
5. Public setters
6. Private setters
7. Constructors
8. Public methods
9. Private methods

This order is the single source of truth for regular classes in the IDE and
the AIDD gate.

### Widget Member Ordering

1. Constructors
2. Named constructors
3. `const` fields
4. Static methods
5. `final` fields
6. Mutable fields
7. `initState`
8. Private methods
9. Overridden public methods
10. `build`

### BLoC Member Ordering

1. Public fields, then private dependency/subscription fields
2. Public and private getters
3. Constructor with `super.initialState` + `on<>` registrations
4. Public methods, including `close`
5. Event handlers and other private methods

## Type Safety

- **Always** declare return types — never omit
- **Always** use `final` for non-reassigned locals
- **Always** use `const` for compile-time constants
- **Always** declare `const` constructors for immutable classes and use `const`
  invocations whenever every argument is compile-time constant.
- **Never** use `var` when type is not obvious from the right side
- **Never** use `dynamic` — use `Object` or `Object?`

## Async Patterns

- **Always** check `isClosed` before `emit()` after async gaps in BLoC
- **Never** ignore Futures — use `unawaited()` if fire-and-forget
- **Always** cancel subscriptions in `dispose` / `close`

## Widget Lifecycle

`StatefulWidget` lifecycle order in source:

1. `initState`
2. `didChangeDependencies` / `didUpdateWidget`
3. `build`
4. `dispose`

- **Always** use `const` constructors where possible
- Arrow functions only for single-expression bodies — multi-line bodies use `{ ... return; }`
- **Never** create private `_buildXxx` methods — extract as separate widget classes

## InheritedWidget Access in State

**Never** call `context.read<T>()`, `context.watch<T>()`, or any `InheritedWidget`-based lookup inside `initState` — the widget is not yet in the tree and the lookup will throw.

**Always** use `didChangeDependencies` with an `_initialized` guard for `late final` fields that depend on `InheritedWidget`:

```dart
class _MyState extends State<MyWidget> {
  late final MyDependency _dep;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    _dep = context.read<MyDependency>();
  }
}
```

The guard is mandatory when the field is `late final` — assigning it twice throws `LateInitializationError`. `didChangeDependencies` can be called multiple times (e.g., when an ancestor `InheritedWidget` updates).

## BLoC Lifecycle

- **Scope** = high in tree, exposes a **factory** for creating BLoC instances via static method + `InheritedWidget`. Scope does **not** hold or own BLoC instances.
- **`BlocProvider(create: ...)`** = low in tree, near the screen / `BlocBuilder`. Auto-disposes the BLoC when removed.
- **One BLoC per flow** — no god-object BLoCs handling multiple flows.

```dart
// Scope: high in tree, exposes factory
class FeatureScope extends StatefulWidget {
  const FeatureScope({required this.child});
  final Widget child;

  static FeatureBloc createBloc(BuildContext context) {
    final scope = context
        .getInheritedWidgetOfExactType<_InheritedFeatureScope>();
    if (scope == null) {
      throw StateError('FeatureScope not found in widget tree');
    }

    return scope.blocFactory();
  }
  // ...
}

// Screen: BlocProvider(create:) low in tree
class FeatureScreen extends StatelessWidget {
  const FeatureScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<FeatureBloc>(
    create: (_) => FeatureScope.createBloc(context),
    child: const _FeatureView(),
  );
}
```

Full three-level pattern:

```dart
// Level 1: Scope (StatefulWidget) — holds dependencies, exposes static factory
class FeatureScope extends StatefulWidget {
  const FeatureScope({super.key, required this.child});
  final Widget child;

  static FeatureBloc createBloc(BuildContext context) {
    final scope = context
        .getInheritedWidgetOfExactType<_InheritedFeatureScope>();
    if (scope == null) {
      throw StateError('FeatureScope not found in widget tree');
    }

    return scope.blocFactory();
  }

  @override
  State<FeatureScope> createState() => _FeatureScopeState();
}

// Level 2: State — wires dependencies from AppScope
class _FeatureScopeState extends State<FeatureScope> {
  late final Factory<FeatureBloc> _blocFactory;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final deps = AppScope.of(context);
    _blocFactory = () => FeatureBloc(
      featureRepository: deps.featureRepository,
    );
  }

  @override
  Widget build(BuildContext context) => _InheritedFeatureScope(
    blocFactory: _blocFactory,
    child: widget.child,
  );
}

// Level 3: InheritedWidget — exposes factory down the tree
class _InheritedFeatureScope extends InheritedWidget {
  const _InheritedFeatureScope({
    required this.blocFactory,
    required super.child,
  });

  final Factory<FeatureBloc> blocFactory;

  @override
  bool updateShouldNotify(_InheritedFeatureScope old) => false;
}
```

## Use Cases

For use cases with a **single method**, name it `call` instead of `execute`. This allows invoking the use case instance as a function.

```dart
// ❌ Legacy
class GetItemsUseCase {
  Future<List<Item>> execute() => _repository.getItems();
}
// await useCase.execute()

// ✅ Modern
class GetItemsUseCase {
  Future<List<Item>> call() => _repository.getItems();
}
// await useCase()
```

Multi-method services keep explicit method names — `call` is reserved for single-purpose use cases.

## Import Organization

1. `dart:` imports
2. `package:flutter/` imports
3. `package:` third-party imports
4. `package:` project imports (alphabetical)

Production code under `lib/` always uses `package:` imports. Test code may use
relative imports for test-only helpers and package-local `test/tool` internals
that are not exposed through a package `lib/` API.

```dart
// ❌
import '../local/feature_local_store.dart';

// ✅
import 'package:data/src/local/feature_local_store.dart';
```

## Examples

### Correct

```dart
// Good: null-safe, typed, formatted
final String? name = user.name;
if (name != null) {
  final greeting = 'Hello, $name';

  return greeting;
}
```

### Incorrect

```dart
// Bad: null assertion, missing type, no braces
final greeting = 'Hello, ${user.name!}';
if (condition) return greeting; // no braces, no blank line
```

## Test File Structure

`main()` is always the **first declaration** in a test file.
Private helpers, factory methods, and fakes come **after** `main()`.

```dart
// ✅
void main() {
  group('FeatureBloc', () {
    test('emits loaded state', () { ... });
  });
}

FeatureBloc _buildBloc({FeatureRepository? repo}) =>
    FeatureBloc(repository: repo ?? FakeFeatureRepository());
```

## Method Placement

Prefer **private instance methods** over top-level file-private functions
when the function is only used by one class.
Do not mark such helpers `static` unless they truly have no instance dependency.

```dart
// ❌ Top-level — pollutes file namespace, obscures ownership
String _formatBalance(int lamports) => '${lamports / 1e9} SOL';

// ✅ Private instance method — cohesive, scoped to the class
class _FeatureTile extends StatelessWidget {
  String _formatBalance(int lamports) => '${lamports / 1e9} SOL';
}
```

## Initialising Formals

Always use initialising formals (`this.field`) instead of an initialiser list for simple field assignment.

```dart
// ❌ Initialiser list for simple assignment
class Foo {
  final String _id;
  Foo(String id) : _id = id;
}

// ✅ Initialising formal
class Foo {
  final String _id;
  const Foo(this._id);
}
```

Exception: when the parameter name must differ from the field, or the initialiser list performs additional logic (`assert`, `super(...)`, or a derived assignment).

## Instance Field Sub-Ordering

Within each visibility group, order instance fields:
1. `final` fields first
2. `late` fields second
3. Nullable (`T?`) fields last

Public fields before private fields within each group.

## `on Exception catch` at Infrastructure Boundaries

Use `on Exception catch` (not bare `catch`) when wrapping infrastructure calls
to prevent Dart `Error` subclasses (`TypeError`, `AssertionError`, `RangeError`)
from being silently treated as domain exceptions.

```dart
// ❌ Masks programmer errors as domain exceptions
try {
  return await _gateway.fetch();
} catch (e, stack) {
  Error.throwWithStackTrace(const FetchException(), stack);
}

// ✅ TypeError/AssertionError propagate to zone handler
try {
  return await _gateway.fetch();
} on Exception catch (_, stack) {
  Error.throwWithStackTrace(const FetchException(), stack);
}
```

## BLoC Public API

Never expose public fields or public methods on BLoC classes.
All interaction happens through events. Expose only the `stream` and `state` that `flutter_bloc` provides via the base class.

### BLoC Type And File Naming

- Every concrete BLoC input ends with `Event`.
- Every concrete one-shot UI output ends with `Action`.
- Every BLoC state ends with `State`.
- Use the classic aggregate layout per BLoC:
  `feature_bloc.dart`, `feature_event.dart`, `feature_state.dart`, and
  `feature_action.dart` when the BLoC exposes actions.
- Keep all events for one BLoC in its single `*_event.dart` file, all states in
  `*_state.dart`, and all actions in `*_action.dart`. Do not create
  `events/` or `actions/` subdirectories.
- UI-dispatched events are public. Platform callbacks and internal async
  results are private library events.

## BLoC Coordination

- Do not read one BLoC's state to create another BLoC when both values can come from the same route argument or dependency.
- Do not subscribe to another BLoC's stream. Subscribe to a shared source of truth or `AppEventBus`.
- For shared state, subscribe in the BLoC constructor, dispatch an internal event such as `_SessionLockChanged`, and cancel in `close()`.
- For one-time facts, subscribe to `AppEventBus`, filter by typed event, dispatch an internal event, and cancel in `close()`.
- Use `BlocListener` only for UI effects in the same presentation subtree, not for BLoC-to-BLoC coordination.

See [bloc-communication.md](./bloc-communication.md) for the full decision matrix.

## Test File Imports

- **Between test files**: relative imports are allowed and required — `package:` URIs resolve only to a package's `lib/` directory, so `../fakes/fake_foo.dart` is correct inside `test/`.
- **Production code from tests**: always use `package:` imports.

## StatefulWidget Lifecycle Order

Source file order must match the lifecycle call order:

1. `initState`
2. `didChangeDependencies`
3. `didUpdateWidget`
4. `build`
5. `dispose`
6. Public methods
7. Private methods
