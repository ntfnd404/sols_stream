# AGENTS.md

Reference for all AIDD agents in this project.

## Agent Summary

| Agent | Gate | Tools |
|---|---|---|
| analyst | `IDEA_READY` → `PRD_READY` | Read, Glob, Grep, Write |
| researcher | `PRD_READY` → `RESEARCH_DONE` | Read, Glob, Grep, Bash, Write |
| planner | `RESEARCH_DONE` → `PLAN_APPROVED` | Read, Glob, Grep, Write |
| implementer | `TASKLIST_READY` → `IMPLEMENT_STEP_OK` | Read, Write, Edit, Glob, Grep, Bash |
| reviewer | `IMPLEMENT_STEP_OK` → `REVIEW_OK` | Read, Glob, Grep, Write |
| security-reviewer | `REVIEW_OK` → `SECURITY_REVIEW_OK` | Read, Glob, Grep, Write |
| qa | `REVIEW_OK` → `QA_PASS` | Read, Glob, Grep, Write |

## Key Rules

- Implementer is the only code-writing role
- Each role reads only its required artifacts
- Project-specific rules live in `docs/project/conventions.md`
- All agents read conventions at runtime

## Artifact Flow

```
idea (analyst)
→ PRD + research + vision (analyst + researcher)
→ plan + brief + tasklist (planner)
→ code (implementer)
→ review summary (reviewer)
→ security review (security-reviewer, Critical only)
→ QA report (qa)
```

## Agent Definitions

See `.claude/agents/*.md` for full definitions.
