# Flutter-Dart: Gate ↔ Skill Matrix

Mapping of AIDD v3 gates to external skills for the Flutter/Dart stack.

See also: `docs/project/external-skills.md`.

## Matrix

| Gate | Role | AIDD skill | External skills (optional) | Trigger |
|---|---|---|---|---|
| `IDEA_READY → PRD_READY` | analyst | `/aidd-new-ticket` (idea), then `/aidd-new-phase` (PRD) | — | requirements analysis does not need code skills |
| `PRD_READY → RESEARCH_DONE` | researcher | — | `flutter-apply-architecture-best-practices` | when architectural scale is uncertain |
| `RESEARCH_DONE → VISION_APPROVED` | researcher | — | `flutter-apply-architecture-best-practices` | same |
| `VISION_APPROVED → PLAN_APPROVED` | planner | — | `flutter-setup-declarative-routing`, `flutter-setup-localization`, `dart-resolve-package-conflicts` | one-shot setup tasks in the plan |
| `PLAN_APPROVED → TASKLIST_READY` | planner | `/aidd-new-phase` | — | tasklist is assembled from the plan |
| `TASKLIST_READY → IMPLEMENT_STEP_OK` | implementer | `/aidd-start-phase`, `/aidd-run-checks` | `flutter-add-widget-test`, `flutter-add-widget-preview`, `flutter-build-responsive-layout`, `flutter-fix-layout-issues`, `flutter-implement-json-serialization`, `dart-add-unit-test`, `dart-generate-test-mocks`, `dart-use-pattern-matching`, `dart-fix-runtime-errors`, `dart-run-static-analysis` | by batch type |
| `IMPLEMENT_STEP_OK → REVIEW_OK` | reviewer | — | `dart-run-static-analysis` | re-verify the diff |
| `REVIEW_OK → SECURITY_REVIEW_OK` (Critical) | security-reviewer | — | — | security review is a manual gate; skills do not help |
| `SECURITY_REVIEW_OK / REVIEW_OK → QA_PASS` | qa | `/aidd-complete-phase` | `flutter-add-integration-test`, `flutter-add-widget-test`, `dart-add-unit-test`, `dart-collect-coverage` | by PRD purpose type |
| `QA_PASS → RELEASE_READY → DOCS_UPDATED` | (orchestrator) | `/aidd-ship-feature`, `/aidd-validate` | — | final gate — no code skills needed |

## Skill Selection by Batch Type

When the planner assembles a batch, select skills by the nature of the work:

| Batch type | Recommended skills |
|---|---|
| New UI feature | `flutter-add-widget-preview` → `flutter-build-responsive-layout` → `flutter-add-widget-test` |
| New use case / domain | `dart-use-pattern-matching` (sealed types) + `dart-add-unit-test` + `dart-generate-test-mocks` |
| Bug fix (runtime) | `dart-fix-runtime-errors` (or `flutter-fix-layout-issues` for UI) |
| Refactor | `dart-use-pattern-matching` + `dart-run-static-analysis` |
| Setup phase | `dart-resolve-package-conflicts`, optionally `flutter-setup-*` |
| Critical QA | `flutter-add-integration-test` + `dart-collect-coverage` required |

## Lane Minimums

| Lane | Minimum external skills to pass gates |
|---|---|
| Trivial | `dart-run-static-analysis`; optionally `dart-fix-runtime-errors` / `flutter-fix-layout-issues` |
| Professional | + `dart-add-unit-test` or `flutter-add-widget-test` (if the change is behavioural) |
| Critical | + `dart-collect-coverage` (QA evidence) + `flutter-add-integration-test` (UI Critical) |

## Conventions Override

All skills execute within the context of `docs/project/conventions.md`.
Conflicts are resolved in favour of the project — see `docs/project/external-skills.md § Conflict Priority`.
