# ADR-0001: Record architecture decisions

- **Status:** Accepted
- **Date:** 2026-09-28

## Context

Casper will involve many decisions with real trade-offs: operating system, schema design, chunking, model choice, routing policy, gateway build-vs-buy, AWS compute shape and more. Several months from now, in a code review or a job interview, it will matter not just *what* was chosen but *why*, what the alternatives were and what evidence supported the choice. Memory and commit messages don't hold that reliably.

## Options considered

### Option A: No formal record
- **Pros:** No overhead.
- **Cons:** Reasons are forgotten; decisions get re-argued; no evidence for interviews or for a customer asking "why did you build it this way?".

### Option B: A single running design document
- **Pros:** Everything in one place.
- **Cons:** Grows unwieldy; hard to see when a decision was made or later reversed; edits erase history.

### Option C: Architecture decision records (Michael Nygard style)
- **Pros:** One short file per decision; numbered and dated; superseded rather than edited, so history is kept; widely recognised in industry.
- **Cons:** Small overhead per decision; requires the discipline to write them.

## Decision

We will record every significant decision as an ADR in `docs/adr/`, using [0000-template.md](0000-template.md). ADRs are numbered sequentially and never deleted: a changed decision gets a new ADR that supersedes the old one. Friday review days include writing any ADRs from the week.

## Consequences

- There is a written trail of reasoning to draw on for the case study, README and interviews.
- Writing an ADR forces the options and evidence to be made explicit before committing to a choice.
- A little time each week goes into writing them.

## How we'll know if this was wrong

If ADRs stop being written, or are written after the fact without real options considered, the process isn't earning its keep and should be simplified.

## References

- Michael Nygard, "Documenting Architecture Decisions" (2011)
- adr.github.io
