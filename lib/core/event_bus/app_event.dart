/// Root type for in-process application events shared across features.
///
/// Domain events belong to their bounded-context packages. Application events
/// coordinate presentation workflows without coupling their BLoCs directly.
abstract base class AppEvent {
  const AppEvent();
}
