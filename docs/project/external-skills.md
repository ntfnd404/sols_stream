# Flutter-Dart: External Skills Overlay

Which external skills apply to this adaptor and where they conflict with project conventions.

See also: `docs/project/gate-skill-matrix.md`.

## Active Set

19 skills split into three applicability categories:

### Fully applicable (core set)

| Skill | Role in this adaptor |
|---|---|
| `dart-run-static-analysis` | supplements `dcm_analyze` in `/aidd-run-checks` |
| `dart-add-unit-test` | primary test-authoring recipe |
| `dart-generate-test-mocks` | for tests with RPC / storage dependencies |
| `dart-collect-coverage` | required in Critical lane |
| `dart-fix-runtime-errors` | recovery after QA_FAIL |
| `dart-use-pattern-matching` | for sealed types in this project |
| `dart-resolve-package-conflicts` | at any gate before IMPLEMENT |
| `flutter-add-widget-test` | paired with BLoC widgets |
| `flutter-add-widget-preview` | for the `ui_kit` package |
| `flutter-add-integration-test` | QA-level for Critical phases |
| `flutter-build-responsive-layout` | UI work |
| `flutter-fix-layout-issues` | recovery on layout exceptions |
| `flutter-apply-architecture-best-practices` | secondary — primary source is `conventions.md` |

### Applicable with caveats (project-specific overrides)

| Skill | Override |
|---|---|
| `flutter-implement-json-serialization` | OK for non-sensitive DTOs; **forbidden** for signatures, keys, signed-tx — use custom code paths there |
| `flutter-setup-declarative-routing` | one-shot — not needed after initial setup |
| `flutter-setup-localization` | one-shot — not needed after initial setup |
| `dart-generate-test-mocks` | fakes/mocks go in separate files under `test/fakes/` or `test/mocks/`, never inline |

### Not applicable in this project

| Skill | Reason |
|---|---|
| `flutter-use-http-package` | network calls go through the `solana_wallet` workspace package |
| `dart-build-cli-app` | primary artifact is a Flutter app |
| `dart-migrate-to-checks-package` | uses `package:test` + `flutter_test`; migration not planned |

## Conflict Priority

When a skill recommendation conflicts with project rules, the project wins:

1. `docs/project/conventions.md`
2. `docs/project/adr/*`
3. `docs/project/code-style-guide.md`
4. **Skill**
5. Flutter/Dart defaults

Example: `flutter-apply-architecture-best-practices` may recommend a Logic layer with providers/services.
This project uses BLoC + sub-feature folders + scope-based DI. Conventions win.

## Memory Bindings

These memory cards modify skill behaviour:
- "BLoC-only + sub-feature folders" — overrides state-management parts of any Flutter skill
- "Test helpers in separate file" — overrides `dart-generate-test-mocks`
- "No relative imports" — post-processing after any skill that generates code
- "Empty line before return" — post-processing after any skill that generates code
- "Selective catches in use cases" — overrides error-handling parts of skills
