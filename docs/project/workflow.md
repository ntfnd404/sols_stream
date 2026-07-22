# Workflow

This project follows **Claude-Native Enterprise AIDD v3**.

## Reference

Full methodology: [Enterprise Claude AIDD Vault](https://obsidian.md)

## Lanes

| Lane | When | Flow |
|---|---|---|
| Trivial | typo, rename, tiny fix | edit → review |
| Professional | features, refactors, new capabilities | idea → prd → research → vision → plan → implement → review → qa |
| Critical | auth, crypto, secrets, storage, migrations, API contracts, package-boundary changes touching trust boundaries | Professional + security review |

Default: `Professional`

## Gates

```
IDEA_READY → PRD_READY → RESEARCH_DONE → VISION_APPROVED → PLAN_APPROVED
→ TASKLIST_READY → IMPLEMENT_STEP_OK → REVIEW_OK
→ SECURITY_REVIEW_OK (Critical) → QA_PASS → RELEASE_READY → DOCS_UPDATED
```

## Roles

| Role | Owns |
|---|---|
| Analyst | Phase PRD |
| Researcher | Codebase facts, vision |
| Planner | Plan, brief, tasklist |
| Implementer | Code, phase/tasklist updates |
| Reviewer | Review summary |
| Security Reviewer | Security review (Critical) |
| QA | QA report |

## Batch Model

- Read phase/plan/prd
- Propose batch (2-5 related tasks)
- Wait for approval
- Implement
- Run checks
- Update docs
- Show diff
- Stop on meaningful boundary

## Roadmap And Backlog

`docs/project/roadmap.md` is the durable source of truth for completed,
in-flight, planned, and deferred work. Ticket workspaces under `docs/<TICKET>/`
are temporary branch-local execution artifacts and must never be linked from
the roadmap.

- New unscheduled work receives a `BL-NNN` identifier.
- Starting a backlog item assigns an `SS-NNNN` ticket and records
  `SS-NNNN (from BL-NNN)` in `In-flight`.
- `/aidd-new-ticket` moves an existing planned ticket or promoted backlog item
  to `In-flight`; it does not create an untracked parallel source of work.
- `/aidd-ship-feature` moves the ticket to `Completed` only after all required
  gates pass. The completed entry records the outcome and durable merge, PR, or
  commit reference rather than a `docs/<TICKET>/` path.
- Cancelled or intentionally paused work moves to `Deferred / open items` with
  a reason.
- Out-of-scope findings from planning, review, security review, or QA must be
  registered in the roadmap before the current ticket ships.
- Every roadmap edit updates `Last reviewed` and the rolling `Last 3 changes`
  log. A ticket or backlog ID may appear in only one lifecycle section.

## External Execution Overlays

External skills and plugins may help execute work inside the workflow, but they
do not change gate progression.

| Layer | Role |
|---|---|
| `/aidd-*` | Workflow commands and gate routing |
| `dart-*` / `flutter-*` | Stack-specific execution skills selected by batch type |
| Superpowers | General execution methodology: brainstorming, TDD, debugging, `/execute-plan`, pre-review |

Superpowers `/execute-plan` is allowed only for an approved batch after
`PLAN_APPROVED` / `TASKLIST_READY`. Superpowers code-reviewer is a pre-review,
not `REVIEW_OK`. Critical phases still require `security-reviewer`.

Architecture work that changes bounded contexts, package ownership, secret
handling, storage, crypto, or redaction policy is Critical even when the code
change is mostly refactoring.

## On-Chain Contract Workflow

- The versioned Anchor IDL belongs to `packages/signaling_solana/idl/`.
- Run `make check-idl` before reviewing changes to Solana accounts,
  instructions, parsers, or gateways.
- When the deployed contract changes, run `make fetch-idl`, review the generated
  diff, and update adapter code and tests in the same ticket.
- An unexplained IDL drift blocks review. IDL ownership, funding policy, and
  trust-boundary changes use the Critical lane.

## Documentation

- `docs/project/` — persistent truth (conventions, style, ADR, templates)
- `docs/project/roadmap.md` — durable ticket and backlog lifecycle
- `docs/project/testing-strategy.md` — test-level ownership and deferred test capabilities
- `docs/<TICKET>/` — feature workspace (branch-local, cleaned before merge)

## Workflow Version

`3`
