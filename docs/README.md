# docs

Project documentation following the AIDD v3 workflow.

## Structure

- `docs/project/` — persistent project truth (conventions, style guide, guidelines, workflow, templates, ADRs)
- `docs/project/roadmap.md` — completed, in-flight, planned, and deferred work
- `docs/project/testing-strategy.md` — test-level ownership and execution policy
- `docs/evidence/<TICKET>/` — reviewed decisions and reproducible acceptance
  evidence
- `docs/<TICKET>/` — branch-local ticket workspace and scratch material

Ticket workspaces are ignored by default. Accepted artifacts are moved to
`docs/evidence/<TICKET>/`, which is tracked normally; `git add -f` is not part of
ticket closure.

## Workflow

See `docs/project/workflow.md` for the full gate model and lane definitions.
Use `docs/project/roadmap.md` as the durable status/dependency index. Detailed
acceptance evidence belongs to the owning versioned evidence directory and is
linked from the roadmap rather than copied into it.
