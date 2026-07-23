/// Root type for in-process application events shared across features.
///
/// Domain events belong to their bounded-context packages. Application events
/// coordinate presentation workflows without coupling their BLoCs directly.
/// Implementations are structurally immutable snapshots: the class and all
/// instance fields are final, and mutable value collections are not exposed.
abstract base class AppEvent {
  const AppEvent();
}
