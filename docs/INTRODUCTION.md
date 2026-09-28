# Introduction to Casper

> A note on naming: [PLAN.md](PLAN.md) was written when the project was called "Cairn". Read every "Cairn" there as "Casper".

## What Casper is

Casper is a **private "ask my documents" assistant with receipts**. You point it at your Obsidian vault and a folder of PDFs, then ask things like "What did I decide about the battery charge limit on the laptop?" It answers in a sentence or two and links to the exact note and heading it used. If the answer isn't in your documents, it says so instead of making something up.

**It runs on your hardware.** Private notes are only ever sent to the model on your own GPU. Everything else can use a stronger cloud model (Claude) when that is worth the cost, or when the GPU laptop is switched off.

**It is measured and observable.** A set of test questions with known answers is scored every time something changes, and every question leaves a trace showing what happened and how long each step took.

**It can be deployed for someone else.** In week 8 a cloud copy is built on AWS with Terraform, and in week 9 a second, real user is onboarded onto it.

## The journey of one question

Say you type: *"What's the excess on my travel insurance?"*

**1. The question arrives.** You type it into the web UI on your phone, the CLI, or ask Claude Desktop, which calls Casper's MCP (Model Context Protocol) server. Whichever you use, it becomes a request to Casper's API with your API key attached, so Casper knows who you are and which documents you may see.

**2. Casper turns the question into numbers.** An embedding model converts the question into a vector: a long list of numbers that captures its *meaning*. Questions about "insurance excess" and "how much I pay before the policy kicks in" end up with similar numbers.

**3. Casper searches two ways at once.** A *vector search* finds chunks of your documents whose meaning is close to the question. A *keyword search* finds chunks that contain the actual words ("excess", "travel insurance"). Each finds things the other misses, so their results are merged into one ranked list. Both searches only look at your documents, filtered in the database itself.

**4. Casper checks what it found.** If nothing relevant came back, it tells you it couldn't find that in your notes without bothering a model at all.

**5. Casper decides which model to ask.** The model gateway looks at what was retrieved. If any chunk is labelled `private`, the question may only go to the local model on your GPU. If the GPU laptop is off, a private question fails clearly rather than leaking to the cloud. A non-private question can fall back to Claude.

**6. The model writes a grounded answer.** Casper sends the model the question plus the retrieved chunks, numbered as sources, with instructions to answer only from them and to cite them as `[1]`, `[2]`. The answer streams back word by word, so you see text within a fraction of a second.

**7. You get the receipts.** Citation numbers are mapped back to real files and headings (e.g. `Insurance/Travel policy.md > Excess`), so you can click through and check.

**8. Everything is recorded.** A trace records how long each step took, which chunks were found, which model answered, how many tokens it used and what it cost. Nothing from the notes themselves goes into logs. If an answer was bad, you can open the trace and see whether retrieval or generation was at fault.

## What each folder is for

| Folder | Purpose |
|---|---|
| `src/casper/` | The application code. One package per component; each has a README explaining its job and the questions to answer before building it. |
| `src/casper/ingest/` | Reads documents, splits them into chunks, embeds them and syncs them into the database. |
| `src/casper/store/` | The database schema and all database access. |
| `src/casper/retrieval/` | Hybrid search with tenant and sensitivity filters. |
| `src/casper/generation/` | Builds prompts and produces grounded, cited, streamed answers. |
| `src/casper/gateway/` | The single front door for every model call: routing, auth, rate limits, cost. |
| `src/casper/api/` | The FastAPI service every interface talks to. |
| `src/casper/mcp_server/` | Exposes Casper as tools for Claude Desktop and Claude Code. |
| `src/casper/observability/` | Structured logs, traces and metrics. |
| `evals/` | Golden datasets, eval runners and results. Private datasets never leave your machine. |
| `tests/` | Automated tests, with synthetic fixtures only. |
| `scripts/` | Scratch scripts and helpers (week 1 experiments live here, not in `src/`). |
| `ui/` | The minimal web UI (week 3). |
| `infra/` | Prometheus and Grafana config (week 7) and Terraform for AWS (week 8). |
| `data/` | Your local documents and working files. Git-ignored except for `.gitkeep`. |
| `docs/` | The plan, architecture, glossary, ADRs, experiments, learning log, runbook, playbook and case study. |

## How the learning workflow works

**PLAN → learning log → ADRs → experiments.**

1. **[PLAN.md](PLAN.md)** tells you what to learn and build each day, as outcomes rather than instructions, with "check yourself" questions to answer out loud before moving on.
2. **[learning-log/](learning-log/)**: every day ends with a short entry in your own words (five minutes, even three bullet points). This becomes the raw material for the case study and interview answers.
3. **[adr/](adr/)**: whenever you make a significant decision (operating system, ORM or raw SQL, chunking strategy, routing policy, AWS compute shape), write an ADR (architecture decision record): the context, the options, what you chose and how you'd know it was wrong.
4. **[experiments/](experiments/)**: whenever you believe something is an improvement, measure it before and after, and write it up with numbers.

Friday is review day: tidy up, commit, update the README status line, and write any ADRs from the week.

## How to use Claude Code on this repo

The rules live in [CLAUDE.md](../CLAUDE.md), which Claude Code reads automatically. In short:

- **Claude is a tutor and reviewer, not a code generator.** It won't write implementation code in `src/casper/` or `evals/runners/` unless you explicitly say "write it for me" or "just do it".
- **Help escalates gradually:** it asks what you think, then explains, then hints, then gives pseudocode, and only then gives a minimal snippet with every line explained.
- **You design the interfaces.** Propose a function signature or data structure, and Claude critiques it.
- **Tooling is fair game.** Dockerfiles, Compose, CI, the Makefile and doc templates can be written for you, with an explanation.
- **Sessions end with check-yourself questions**, a prompt to write your learning log and a reminder to record any decisions as ADRs.

A good rhythm: try for 20 minutes, ask for a *hint*, try again, then ask for a *review*.
