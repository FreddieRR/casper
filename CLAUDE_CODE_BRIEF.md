# Project brief for Claude Code: "Cairn" (working name)

> **How Freddie uses this file:** create an empty folder, put this file and `START_HERE.md` in it, run `git init`, start `claude` in that folder and say: *"Read CLAUDE_CODE_BRIEF.md and follow it."*
>
> "Cairn" is a placeholder name (a cairn is a pile of stones marking a path, which fits a system that marks where knowledge lives). Ask Freddie if he wants a different name before creating anything.

---

## 0. Your role in this repo (read this first)

Freddie is building this project **to learn**. He wants to understand every part of it well enough to defend it in a job interview. That changes how you should behave:

- **You scaffold; Freddie builds.** In this first session you set up the repository, tooling and documentation. You do **not** implement the core logic (ingestion, chunking, retrieval, generation, gateway, evaluation, MCP (Model Context Protocol) server). Those modules get a docstring, a README and `TODO(week N)` markers only.
- **No pre-designed interfaces.** Do not write function signatures or class skeletons for core modules. Designing the interfaces is part of Freddie's learning.
- **Tooling and configuration are fair game.** Packaging, linting, CI (continuous integration), Docker Compose for the database, Makefile, `.gitignore`, templates and docs are yours to write fully.
- **Write a `CLAUDE.md`** (content in section 10) so every future Claude Code session keeps behaving as a tutor rather than a code generator.
- **Ask before you start** (questions in section 12).

---

## 1. Who Freddie is (context for tone and level)

- Software developer at risr/ (assessment and lifelong-learning tech). Day-to-day stack: Python/Flask, Angular, CouchDB, Docker. Computer Science graduate (University of Birmingham).
- Founder of Rkadia, an agri-tech social enterprise serving small-scale fish farmers in India (WhatsApp-based platform, computer-vision fish-disease detection that started as his final-year project).
- **Career goal:** move into a **Forward Deployed Engineer (FDE)** role, ideally at an AI company. FDEs embed with customers, integrate with messy real systems, ship quickly, measure outcomes and explain trade-offs to non-technical people.
- Comfortable with general software engineering; **new to AI engineering** (LLMs (large language models), embeddings, RAG (retrieval-augmented generation), evals, observability of AI systems).
- Preferences: UK English spelling; expand abbreviations on first use; short paragraphs with bolded mini-headers for multi-point explanations; when he asks for a code fix, give the **entire updated file** with comments explaining the changes; proactively flag bugs and suggest alternatives.

---

## 2. The project in one paragraph

Cairn is a **self-hosted, private AI knowledge assistant** that answers questions over a person's or organisation's documents (an Obsidian vault, PDFs, notes) with **cited answers**. It runs on hardware Freddie owns, routes each request to either a **local model** (Ollama on his GPU laptop) or a **cloud model** (Claude API) according to a privacy/cost/availability policy, and exposes itself through an **MCP server** (so it plugs straight into Claude Desktop and Claude Code), a small web UI and a CLI (command-line interface). It is **measured** (an evaluation harness running in CI), **observable** (traces of every request plus infrastructure dashboards), **secure** (per-tenant isolation, prompt-injection tests, no public exposure) and **multi-tenant**: Freddie is tenant #1 and uses it daily; in week 8 he builds a second environment on **AWS** with Terraform (Claude via Amazon Bedrock as the model), and in week 9 onboards a **real external user** onto it as tenant #2 using a written deployment playbook.

---

## 3. Why it is shaped this way

| Design choice | Why it matters for an FDE CV | Why it matters day to day |
|---|---|---|
| Freddie's own vault is tenant #1 | Dogfooding produces real usage data and honest trade-off stories | He actually uses it every day |
| Local + cloud routing, not local-only | Real deployments are hybrid; the interesting decisions are privacy vs quality vs cost vs availability | Private notes never leave the house; hard questions still get a strong model |
| MCP server as a first-class interface | MCP is how AI companies' customers integrate tools today; building one is directly relevant | Use his knowledge base from inside Claude Desktop / Claude Code |
| Evaluation harness in CI | The single biggest differentiator between hobby RAG and professional AI engineering | Changes are proven to help rather than guessed |
| LLM tracing + infra metrics | FDEs debug production systems for customers | He can see why an answer was bad |
| Tenant #2 onboarded from a playbook | "I onboarded a new customer in N hours" is the FDE story | Forces the system to be configurable, not hard-coded |
| Graceful degradation when the GPU node is off | Reliability thinking | Still works when the laptop is off or he is away |

---

## 4. Functional scope

### Core (must exist by week 9)
1. **Ingestion:** Obsidian markdown (frontmatter, headings, wikilinks, tags) and PDFs; heading-aware chunking; incremental sync using content hashes (only changed files re-processed); a sensitivity label per document (e.g. `private` / `normal`).
2. **Storage:** PostgreSQL with pgvector for embeddings **and** Postgres full-text search for keywords (one database; the "why not a dedicated vector DB?" trade-off is an ADR (architecture decision record)).
3. **Retrieval:** hybrid search (vector + keyword) merged with reciprocal rank fusion; metadata filtering by tenant and sensitivity.
4. **Generation:** grounded answers with inline citations to file and heading; "I don't know" when the context does not support an answer; streaming responses.
5. **Model gateway:** OpenAI-compatible endpoint in front of all models; providers: Ollama (local) and Anthropic (cloud); routing policy (private content → local only; fallback to cloud for non-private requests when the GPU node is offline); API keys; rate limiting; token and cost accounting.
6. **Interfaces:** MCP server (tools such as `search_notes`, `get_note`, `ask`), minimal mobile-friendly web UI, CLI.
7. **Evaluation:** hand-written golden dataset; retrieval metrics (recall@k, MRR (mean reciprocal rank)); answer metrics (faithfulness, citation correctness) with an LLM-as-judge that is calibrated against Freddie's own labels; a small regression suite run in GitHub Actions.
8. **Observability:** structured logs; OpenTelemetry traces exported to self-hosted Langfuse; Prometheus + Grafana for latency percentiles, request volume, error rate, route mix, cost and GPU metrics.
9. **Security:** tenant isolation tests; prompt-injection test suite (malicious documents); secrets via environment variables; remote access only via Tailscale (no ports opened to the internet).
10. **Operations:** Docker Compose deployment, backups with a tested restore, a runbook, a capacity note from a load test.
11. **AWS environment:** Terraform-managed (remote state in S3), container images in ECR pushed by GitHub Actions via OIDC (no long-lived keys), a database with pgvector, secrets in Secrets Manager or Parameter Store, CloudWatch logs, a Bedrock provider in the gateway, budget alarm, and a timed destroy-and-rebuild.
12. **Tenant #2:** configuration-driven onboarding, a deployment playbook, a golden set built with that user, and a written case study.

### Stretch (only if time allows)
Reranker model; Anthropic-style contextual retrieval; Telegram bot interface; a simple agent loop that can run several searches before answering; comparing Freddie's gateway with LiteLLM; fine-tuning an embedding model.

### Explicitly out of scope
Training or fine-tuning LLMs; a polished front-end framework app; public internet exposure; any risr/ work documents (confidential; never ingest them).

---

## 5. Architecture

```
            ┌─────────────────────── Interfaces ───────────────────────┐
            │  MCP server        Web UI (mobile)        CLI            │
            └───────────────┬──────────────────────────────────────────┘
                            │
                    ┌───────▼────────┐        ┌───────────────────────┐
                    │  API service   │◄──────►│ Postgres + pgvector   │
                    │  (FastAPI)     │        │ chunks, embeddings,   │
                    │  retrieval +   │        │ full-text index,      │
                    │  answer logic  │        │ tenants, API keys     │
                    └───────┬────────┘        └──────────▲────────────┘
                            │                            │
                    ┌───────▼────────┐          ┌────────┴─────────┐
                    │ Model gateway  │          │ Ingestion worker │
                    │ auth, limits,  │          │ parse → chunk →  │
                    │ routing, cost  │          │ embed → upsert   │
                    └───┬────────┬───┘          └──────────────────┘
                        │        │
             ┌──────────▼──┐  ┌──▼─────────────┐
             │ Ollama      │  │ Anthropic API  │
             │ (GPU laptop)│  │ (cloud)        │
             └─────────────┘  └────────────────┘

  All services emit: structured logs + OpenTelemetry traces → Langfuse
                     metrics → Prometheus → Grafana
  Evaluation runner: golden datasets → API → scores → evals/results/ + CI gate
```

**Deployment topology (target):** an always-on node (optionally a cheap mini PC bought around week 7) runs Postgres, the API, gateway, Langfuse, Prometheus and Grafana; the GPU laptop runs Ollama and can be switched off; everything is reachable only over Tailscale. Until then, everything runs on the GPU laptop.

**Cloud topology (week 8+):** a separate AWS environment in Freddie's **personal** AWS account, representing "a customer's cloud": compute is either one EC2 instance running Compose or ECS Fargate + RDS (Freddie decides via ADR), models via Amazon Bedrock. Tenant #2 is hosted here.

---

## 6. Tech stack

Decided (keep unless Freddie changes them):
- **Python 3.12+**, managed with **uv**; **ruff** for lint/format; **pytest**; **pre-commit**.
- **FastAPI** + **pydantic** / **pydantic-settings** for the API and config.
- **PostgreSQL + pgvector** (Docker image `pgvector/pgvector`).
- **Ollama** for local models (runs natively on the host for simpler GPU access).
- **Anthropic Python SDK** for the cloud provider.
- **Official MCP Python SDK** for the MCP server.
- **OpenTelemetry**, **Langfuse** (self-hosted), **Prometheus**, **Grafana**.
- **Docker** (multi-stage, non-root images) and **Docker Compose**; **GitHub Actions**; **Tailscale**.
- **AWS** (week 8+): Terraform, S3, ECR, EC2 or ECS Fargate, RDS or self-managed Postgres, Secrets Manager/SSM, CloudWatch, IAM Identity Center, Amazon Bedrock; GitHub OIDC for deploys.

Deliberately left for Freddie to decide and record as ADRs (do not decide for him):
- Ubuntu on the laptop vs WSL2 (Windows Subsystem for Linux)
- Chunking strategy and sizes; embedding model; local generation model
- Whether to use an ORM (object-relational mapper) or raw SQL
- Whether to build the gateway by hand or adopt LiteLLM (the plan has him build a thin one first, then compare)
- EC2 + Compose vs ECS Fargate + RDS on AWS; Secrets Manager vs SSM Parameter Store; how tenant #2 reaches the AWS environment
- Web UI approach (plain HTML + HTMX, or something he knows like Angular)

---

## 7. Hardware notes

- Spare **ASUS ROG Zephyrus G14 (2025)**, 32 GB RAM, **RTX 5070 Ti laptop GPU with 12 GB VRAM** (confirmed). Blackwell generation: needs a current NVIDIA driver and a recent CUDA/Ollama stack. Model choices must fit in VRAM (video memory); 7–14B parameters at 4-bit is the comfortable range.
- A laptop used as a server needs: a battery charge limit (e.g. `asusctl` on Linux), lid-close behaviour set to "do nothing", good airflow.
- Budget of a few hundred pounds; likely spends: £20–40 of Claude API credit, AWS usage in weeks 8–9 (kept low with a budget alarm and teardown), optionally a mini PC (~£150–250) for the always-on node.

---

## 8. Non-negotiables

- **Never commit personal data.** `data/`, `.env`, any vault paths, eval datasets built from private notes (`evals/datasets/private/`) and Langfuse/Postgres volumes must be git-ignored. Public example datasets use synthetic or public-domain documents only.
- **No risr/ work documents**, ever. **No risr/ AWS accounts, profiles or credentials**: the AWS work uses Freddie's personal account only.
- **No AWS credentials in the repo or CI secrets**; CI uses OIDC role assumption. Terraform state lives in S3, never in Git.
- **Secrets only through environment variables**; ship `.env.example` with placeholder values.
- **Every significant decision gets an ADR** in `docs/adr/`.
- **Every experiment gets a write-up** in `docs/experiments/` with numbers.

---

## 9. The scaffolding task for this session

Create exactly this structure (adjust the package name if Freddie renames the project):

```
cairn/
├── CLAUDE.md
├── README.md
├── LICENSE                      # MIT
├── .gitignore
├── .env.example
├── .pre-commit-config.yaml
├── pyproject.toml
├── Makefile
├── docker-compose.yml
├── .github/workflows/ci.yml
├── docs/
│   ├── INTRODUCTION.md
│   ├── PLAN.md                  # move START_HERE.md here (git mv), keep content unchanged
│   ├── ARCHITECTURE.md
│   ├── GLOSSARY.md
│   ├── RUNBOOK.md               # stub
│   ├── CASE_STUDY.md            # stub
│   ├── PLAYBOOK_TENANT_ONBOARDING.md   # stub
│   ├── adr/
│   │   ├── 0000-template.md
│   │   └── 0001-record-architecture-decisions.md
│   ├── experiments/
│   │   ├── README.md
│   │   └── 0000-template.md
│   └── learning-log/
│       ├── README.md
│       └── template.md
├── src/cairn/
│   ├── __init__.py              # __version__ only
│   ├── cli.py                   # only a `--version` command so CI has something to run
│   ├── config.py                # docstring + TODO only
│   ├── ingest/      (README.md, __init__.py)
│   ├── store/       (README.md, __init__.py)
│   ├── retrieval/   (README.md, __init__.py)
│   ├── generation/  (README.md, __init__.py)
│   ├── gateway/     (README.md, __init__.py)
│   ├── api/         (README.md, __init__.py)
│   ├── mcp_server/  (README.md, __init__.py)
│   └── observability/ (README.md, __init__.py)
├── evals/
│   ├── README.md
│   ├── datasets/README.md       # documents the JSONL schema; private/ is git-ignored
│   ├── datasets/private/.gitkeep
│   ├── datasets/public/.gitkeep
│   ├── runners/.gitkeep
│   └── results/.gitkeep
├── tests/
│   └── test_smoke.py            # imports package, checks version
├── scripts/
│   └── check_env.sh             # prints OS, nvidia-smi, docker, ollama, uv versions; no side effects
├── ui/README.md
├── infra/
│   ├── prometheus/README.md
│   ├── grafana/README.md
│   └── terraform/README.md      # week 8: purpose, planned modules, cost warnings (NAT gateway, idle RDS), no .tf files yet
└── data/.gitkeep                # everything else in data/ ignored
```

### File-by-file requirements

**`README.md`** (written for a recruiter first, a developer second)
- One-line pitch and a 3–4 sentence summary.
- "Why this exists" (private, measured, hybrid local/cloud AI for real documents).
- Planned features as a checklist (unchecked), grouped as in section 4.
- The architecture diagram from section 5.
- Placeholder sections: **Evaluation results** (empty table with columns: experiment, recall@5, MRR, faithfulness, p95 latency, cost/100 queries), **Key decisions** (links to ADRs), **Quickstart** ("coming in week 3"), **Roadmap** (9 weeks, one line each).
- A "Status: week 0 of 8" line Freddie will update.

**`docs/INTRODUCTION.md`** (for Freddie and any reader)
- What Cairn is in plain English (a private "ask my documents" assistant with receipts).
- A worked example: the journey of one question from typing it to getting a cited answer, stage by stage, in simple language.
- What each folder is for.
- How the learning workflow works: PLAN → learning log → ADRs → experiments.
- A short "how to use Claude Code on this repo" section summarising the tutor rules.

**`docs/ARCHITECTURE.md`**: the diagram, one short paragraph per component describing its *responsibility* (not its implementation), data flow for ingestion and for a query, and a "decisions pending" list linking to future ADR numbers.

**`docs/GLOSSARY.md`**: plain-English definitions, one or two sentences each, of: LLM, token, context window, quantisation, VRAM, embedding, vector, cosine similarity, chunk, vector database, HNSW, BM25/full-text search, hybrid search, reciprocal rank fusion, reranker, RAG, grounding, hallucination, citation, prompt injection, golden dataset, recall@k, MRR, faithfulness, LLM-as-judge, MCP, tool use, agent, gateway, rate limiting, token bucket, SSE (server-sent events), OpenTelemetry, trace, span, p50/p95 latency, tenant, ADR, runbook, container image, multi-stage build, infrastructure as code, Terraform state, VPC, IAM role, OIDC, ECR, ECS/Fargate, RDS, Amazon Bedrock.

**Module `README.md` files** (one per `src/cairn/*` package), each containing:
- *Responsibility:* one paragraph.
- *Built in:* the week/days from `docs/PLAN.md`.
- *Concepts to understand first:* bullet list linking to GLOSSARY entries.
- *Questions to answer before writing code:* 3–5 design questions (e.g. for `ingest`: "What should happen when a note is renamed?", "How will you know a file changed?").
- *Definition of done:* observable behaviour, not implementation.
- No code.

**`evals/README.md` and `evals/datasets/README.md`**: explain the purpose of evals, the folder layout, and propose a JSONL (JSON Lines) schema for a golden item: `id`, `question`, `expected_answer`, `expected_sources` (list of file#heading), `tags`, `difficulty`, `notes`. State that private datasets never leave the machine and that CI runs only against `datasets/public/` with a small synthetic corpus.

**`docs/adr/0000-template.md`**: Nygard-style: Title, Status, Date, Context, Options considered (with pros/cons), Decision, Consequences, How we'll know if this was wrong.

**`docs/adr/0001-record-architecture-decisions.md`**: filled in: we record decisions as ADRs.

**`docs/experiments/0000-template.md`**: Hypothesis, Setup (dataset, versions, config), Variables changed, Results table, Interpretation, Decision/next step.

**`docs/learning-log/template.md`**: Date, Plan day, What I did, What I learned (in my own words), What confused me, Questions for next time, Link to commits.

**`pyproject.toml`**: project metadata, `requires-python >=3.12`, a `cairn` console script pointing at `cairn.cli:main`, dev dependency group with `ruff`, `pytest`, `pre-commit`. Do **not** add runtime AI dependencies yet; Freddie adds each one when he reaches it, so he knows why it is there.

**`Makefile`** targets: `setup`, `lint`, `format`, `test`, `up`, `down`, `logs`, `psql`, `check-env`, `eval` (prints "not implemented yet: week 4").

**`docker-compose.yml`**: only a `db` service (pgvector/pgvector, named volume, healthcheck, credentials from `.env`). Commented-out placeholder blocks with a one-line explanation and the week they arrive for: `api` (week 3), `langfuse` (week 7), `prometheus` and `grafana` (week 7). Note in a comment that Ollama runs on the host, not in Compose.

**`.github/workflows/ci.yml`**: on push/PR: install uv, `uv sync`, `ruff check`, `ruff format --check`, `pytest`. Leave commented placeholder jobs `evals` (week 4) and `build-and-push` to ECR via OIDC (week 8).

**`.gitignore`**: Python defaults, `.env`, `*.tfstate*`, `.terraform/`, `*.tfvars` (keep a `*.tfvars.example`), `data/*` (keep `.gitkeep`), `evals/datasets/private/*` (keep `.gitkeep`), `evals/results/*.local.*`, IDE files, Docker volumes, `*.sqlite`, `.DS_Store`.

**`.env.example`**: `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`, `DATABASE_URL`, `OLLAMA_BASE_URL`, `ANTHROPIC_API_KEY=`, `CAIRN_VAULT_PATH=`, `CAIRN_ENV=dev`, with comments.

**`CLAUDE.md`**: exactly the content in section 10 (adapt the project name if changed).

After creating files: run `uv sync`, `make lint`, `make test`, `docker compose up -d db` and confirm the healthcheck passes, then make an initial commit: `chore: scaffold repository`.

---

## 10. Content for `CLAUDE.md`

```markdown
# CLAUDE.md: how to work with Freddie on Cairn

## The most important rule
Freddie is building Cairn to learn AI engineering and to be able to explain every line in a
Forward Deployed Engineer interview. Act as a **tutor and code reviewer**, not a code generator.

## Default behaviour
- Before helping, check `docs/PLAN.md` and ask which week/day Freddie is on if unclear.
- Do NOT write implementation code in `src/cairn/` (ingest, store, retrieval, generation,
  gateway, api, mcp_server, observability) or in `evals/runners/` unless Freddie explicitly
  says "write it for me" or "just do it".
- Instead, use escalating help: (1) ask what he thinks and why, (2) explain the concept with a
  small analogy or example, (3) give a hint, (4) give pseudocode, (5) only then a minimal
  snippet, and explain every line of it.
- Never design function signatures or class structures for him unprompted. Ask him to propose
  one, then critique it.
- You MAY write freely: tooling config, Dockerfiles, Compose files, CI workflows, Makefile
  targets, doc templates. Explain what you wrote.

## Reviewing Freddie's code
- Proactively flag bugs, security issues (especially prompt injection, secrets, tenant
  leakage), missing tests and unclear naming. Explain *why* each matters.
- When Freddie asks for a fix, provide the ENTIRE updated file, with comments explaining the
  changes, and a short explanation of the reasoning.
- Suggest alternatives and the trade-offs between them.

## Style
- UK English spelling.
- Expand abbreviations/acronyms on first use, e.g. "MRR (mean reciprocal rank)".
- Multi-point explanations: short paragraphs with bolded mini-headers.
- Prefer pointing to official docs over long lectures; link them.

## End of every session
- Ask Freddie 2–3 short "check yourself" questions about what he built today.
- Prompt him to write today's entry in `docs/learning-log/` in his own words (don't write it
  for him).
- If a decision was made, prompt him to write or update an ADR.

## Safety rails
- Never commit anything from `data/`, `.env`, or `evals/datasets/private/`.
- Never ingest or reference risr/ work documents.
- Home remote access is Tailscale only; never suggest opening home router ports. Any public
  endpoint on AWS needs an ADR describing its attack surface first.
- AWS: Freddie's personal account only (never risr/ profiles). No credentials in the repo;
  CI uses OIDC. Remind him about cost (budget alarm, NAT gateways, idle databases, teardown).
```

---

## 11. Definition of done for this session

- All files above exist, CI passes locally (`make lint`, `make test`), the `db` container is healthy.
- `docs/PLAN.md` contains Freddie's plan (moved from `START_HERE.md`) and `README.md` links to it.
- Initial commit made. Offer to help Freddie create the GitHub repository (public is fine because no personal data is committed; confirm with him).
- Finish by summarising what was created and telling Freddie to open `docs/PLAN.md`, Week 1, Day 1.

---

## 12. Ask Freddie these before creating anything

1. Keep the name "Cairn", or choose another?
2. Which machine is this session running on (his main computer or the G14)? If the G14: is it on Windows, WSL2 or Ubuntu? (If he hasn't decided, the plan covers this on Day 1; scaffold anyway, it's OS-independent.)
3. Public or private GitHub repository?
