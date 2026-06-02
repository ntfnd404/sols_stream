# Workflow

This project follows **Claude-Native Enterprise AIDD v3**.

## Reference

Full methodology: [Enterprise Claude AIDD Vault](https://obsidian.md)

## Lanes

| Lane | When | Flow |
|---|---|---|
| Trivial | typo, rename, tiny fix | edit → review |
| Professional | features, refactors, new capabilities | idea → prd → research → vision → plan → implement → review → qa |
| Critical | auth, crypto, secrets, storage, migrations, API contracts | Professional + security review |

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

## Documentation

- `docs/project/` — persistent truth (conventions, style, ADR, templates)
- `docs/<TICKET>/` — feature workspace (branch-local, cleaned before merge)

## Workflow Version

`3`
