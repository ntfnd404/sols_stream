# <TICKET-ID> Phase N PRD -- <Name>

<!--
Status lifecycle:
  PRD_READY        - analyst handoff; spec-critic not yet run.
  SPEC_CRITIQUED   - spec-critic produced >=3 observations; analyst addressed
                     blocking findings. Set by spec-critic, not by analyst.
Researcher MUST refuse to consume a PRD still at PRD_READY.
-->
Status: `PRD_READY`
Ticket: <TICKET-ID>
Phase: N
Lane: Professional
Workflow Version: 3
Workflow Minor: 3.3
Owner: Analyst

---

## Clarification round

<!--
Workflow Minor 3.2 requires every PRD to include EITHER:
  - 3-5 clarifying Q/A pairs raised by the analyst against the idea and
    answered by the ticket owner, OR
  - a `### Considered and rejected` stub listing >=3 ambiguities the analyst
    explicitly considered and chose NOT to raise, with justification.
A PRD missing both will fail `.claude/bin/aidd_validate.sh`. Use placeholder
ticket IDs like `SS-XXXX` in any example Q/A you include here.
-->

- **Q1 (analyst -> owner):** <!-- question -->
  - **A:** <!-- answer -->

### Considered and rejected

- <!-- Ambiguity considered and rejected, with reason -->

---

## Phase Intent

<!-- What this phase must deliver and why it exists now. -->

---

## Deliverables

1. <!-- Deliverable 1 -->
2. <!-- Deliverable 2 -->

---

## Scenarios

### Positive

- <!-- Happy-path scenario and expected outcome -->

### Negative / Edge

- <!-- Failure mode or boundary condition -->

---

## Success Metrics

<!--
Verification format rule (Workflow Minor 3.2):
Every Verification cell MUST start with one of three prefixes:
  - `test:`     - automated test name or path
  - `command:`  - shell command that produces a verifiable result
  - `manual:`   - human-executed check with recorded evidence
Prose verifications ("works correctly", "looks good") are forbidden and will
be flagged FAIL by `.claude/bin/aidd_validate.sh`.
-->

| Criterion | Verification |
|-----------|--------------|
| Example AC | command: `grep -q foo file.txt` |
| | |

---

## Constraints

- <!-- Rules or assumptions the phase must obey -->

---

## Out Of Scope

- <!-- Explicit exclusions -->

---

## Open Questions

- [ ] None
