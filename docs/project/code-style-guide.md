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

Flutter framework convention (verified in `EdgeInsets`, `Container`, `TextButton` source):

1. Constructors (production first, then named, factory, then `@visibleForTesting`)
2. Static const / static final fields
3. Instance fields — final, then late, then nullable (public before private within each)
4. Getters / computed properties
5. Public methods
6. Dispose / close
7. Private methods

Constructors first, static fields second, instance fields last. This matches DCM `member-ordering`.

```dart
// ❌
class Foo {
  static const _timeout = 30; // static before constructor — wrong
  const Foo();
  final String _id;
}

// ✅
class Foo {
  const Foo();
  static const _timeout = 30; // static after constructor
  final String _id;            // instance fields last
}
```

### Widget Member Ordering

1. `const` / `final` fields
2. Constructors
3. `var` / mutable fields
4. `initState`
5. `didChangeDependencies`
6. `didUpdateWidget`
7. `build`
8. `dispose`
9. Public methods
10. Private methods

### BLoC Member Ordering

1. Final repository/service fields
2. Constructor with `super.initialState` + `on<>` registrations
3. Private fields (subscriptions)
4. Event handlers (private, `_onEventName`)
5. `close` override

## Type Safety

- **Always** declare return types — never omit
- **Always** use `final` for non-reassigned locals
- **Always** use `const` for compile-time constants
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

  static FeatureBloc newBloc(BuildContext context) {
    final scope = context
        .getInheritedWidgetOfExactType<_InheritedFeatureScope>();
    if (scope == null) {
      throw StateError('FeatureScope not found in widget tree');
    }

    return scope.newBloc();
  }
  // ...
}

// Screen: BlocProvider(create:) low in tree
class FeatureScreen extends StatelessWidget {
  const FeatureScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<FeatureBloc>(
    create: (_) => FeatureScope.newBloc(context),
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

  static FeatureBloc newBloc(BuildContext context) {
    final scope = context
        .getInheritedWidgetOfExactType<_InheritedFeatureScope>();
    assert(scope != null, 'FeatureScope not found in widget tree');
    return scope!._newBloc();
  }

  @override
  State<FeatureScope> createState() => _FeatureScopeState();
}

// Level 2: State — wires dependencies from AppScope
class _FeatureScopeState extends State<FeatureScope> {
  late final FeatureRepository _featureRepository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _featureRepository = AppScope.of(context).featureRepository;
  }

  bool _initialized = false;

  FeatureBloc _newBloc() => FeatureBloc(
        featureRepository: _featureRepository,
      );

  @override
  Widget build(BuildContext context) => _InheritedFeatureScope(
        newBloc: _newBloc,
        child: widget.child,
      );
}

// Level 3: InheritedWidget — exposes factory down the tree
class _InheritedFeatureScope extends InheritedWidget {
  const _InheritedFeatureScope({
    required this.newBloc,
    required super.child,
  });

  final FeatureBloc Function() newBloc;

  FeatureBloc _newBloc() => newBloc();

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

**Always** use `package:` imports, never relative imports.

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
