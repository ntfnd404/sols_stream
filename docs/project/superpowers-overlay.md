# Superpowers Overlay

Workflow Version: 3

Superpowers is an optional Claude Code plugin layer for structured execution:
brainstorming, TDD, systematic debugging, `/execute-plan`, subagent-driven
development, code review, and skill authoring.

It does not replace AIDD.

```text
/aidd-* = workflow and gates
dart-* / flutter-* = stack execution skills
Superpowers = general execution methodology
AIDD docs/vault = source of truth
```

## Authority

Project workflow authority remains:

1. `docs/project/conventions.md`
2. `docs/project/adr/*`
3. `docs/project/code-style-guide.md`
4. `docs/project/workflow.md`
5. AIDD skills and agents
6. External skills and plugins, including Superpowers

Superpowers may help execute work inside a gate, but it must not advance gate
status, replace required artifacts, or bypass batch approval.

## Allowed Use

| Superpowers capability | AIDD use | Limit |
|---|---|---|
| `/brainstorming` | Idea shaping, PRD clarification, scope discovery | Output must be captured in AIDD artifacts; it is not `PRD_READY` by itself |
| Adversarial spec review | PRD/plan critique before implementation | Professional: recommended; Critical: required before `PLAN_APPROVED` |
| TDD | Implementation batches with behavioral logic | Recommended for domain, application, BLoC, codec, gateway, and regression work; not mandatory for every UI/layout change |
| Systematic debugging | QA_FAIL, flaky tests, runtime bugs, root cause analysis | Investigate cause before fixes; update research/plan when assumptions change |
| `/execute-plan` | Execute an already approved implementation batch | Only after `PLAN_APPROVED` or `TASKLIST_READY`; never execute an entire phase without checkpoints |
| Code-reviewer | Pre-review/self-check | Not `REVIEW_OK`; the AIDD reviewer still owns the review artifact |
| Subagents | Parallel research, review, or test exploration | Do not bypass role ownership; production code remains implementer-owned |
| Writing-skills | Improve AIDD or project skills | Workflow-critical changes require validation |

## Gate Rules

- `/aidd-*` commands are the only workflow commands.
- `dart-*` and `flutter-*` skills are stack execution skills selected by batch
  type. They operate within the current AIDD gate.
- Superpowers commands are execution aids. They do not create or close gates.
- `REVIEW_OK`, `SECURITY_REVIEW_OK`, and `QA_PASS` must come from the AIDD
  review/security/QA pipeline, not from Superpowers code-reviewer output.
- Critical work keeps the security-reviewer gate even when Superpowers review
  has already run.

## Execution Checkpoint

When Superpowers is used during implementation, the checkpoint must report:

- Which approved batch was executed.
- Which stack skills were relevant (`dart-*` / `flutter-*`), if any.
- Which Superpowers capability was used.
- Test/check evidence.
- Docs-drift result: either updated docs or "no docs update needed".

## Documentation Drift

Implementation often reveals details that were not known during planning. If
Superpowers discovers a changed assumption, API constraint, library behavior, or
architecture risk, the relevant AIDD artifact must be updated before the batch
is considered complete.
