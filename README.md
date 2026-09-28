# Casper

**A private "ask my documents" assistant that shows its receipts: cited answers over your own notes, running on hardware you own.**

Casper is a self-hosted AI knowledge assistant that answers questions over a person's or organisation's documents (an Obsidian vault, PDFs, notes) and cites the exact file and heading behind every answer. Each request is routed to either a local model on a home GPU or a cloud model (Claude), based on a privacy, cost and availability policy. Private notes never leave the house. It plugs into Claude Desktop and Claude Code through an MCP (Model Context Protocol) server, and it is measured by an evaluation suite in CI (continuous integration), traced end to end, and deployable into a customer's AWS account with Terraform.

**Status: week 0 of 9**

> The full 9-week build plan is in [docs/PLAN.md](docs/PLAN.md). For a plain-English tour, start with [docs/INTRODUCTION.md](docs/INTRODUCTION.md).

## Why this exists

Most RAG (retrieval-augmented generation) demos are a notebook that works on one example. Real deployments need more:

- **Private by design.** Sensitive documents are only ever sent to a model on hardware you control.
- **Measured, not guessed.** A hand-built golden dataset scores retrieval and answer quality, and a regression suite gates every change in CI.
- **Hybrid local and cloud.** The interesting decisions are trade-offs between privacy, quality, cost and availability, and they are recorded as ADRs (architecture decision records) with numbers.
- **Built for real documents and real users.** It runs on its author's own vault daily, and a second, external tenant is onboarded from a written playbook.

## Planned features

### Ingestion and storage
- [ ] Obsidian markdown parsing (frontmatter, headings, wikilinks, tags) and PDFs
- [ ] Heading-aware chunking
- [ ] Incremental sync using content hashes
- [ ] Sensitivity label per document (`private` / `normal`)
- [ ] PostgreSQL with pgvector for embeddings and Postgres full-text search for keywords

### Retrieval and generation
- [ ] Hybrid search (vector + keyword) merged with reciprocal rank fusion
- [ ] Metadata filtering by tenant and sensitivity
- [ ] Grounded answers with inline citations to file and heading
- [ ] "I don't know" when the context does not support an answer
- [ ] Streaming responses

### Model gateway
- [ ] OpenAI-compatible endpoint in front of all models
- [ ] Providers: Ollama (local), Anthropic (cloud), Amazon Bedrock (AWS)
- [ ] Routing policy: private content stays local; cloud fallback for non-private requests when the GPU node is offline
- [ ] API keys, rate limiting, token and cost accounting

### Interfaces
- [ ] MCP server (`search_notes`, `get_note`, `ask`)
- [ ] Minimal mobile-friendly web UI
- [ ] CLI (command-line interface)

### Evaluation
- [ ] Hand-written golden dataset
- [ ] Retrieval metrics: recall@k, MRR (mean reciprocal rank)
- [ ] Answer metrics: faithfulness, citation correctness
- [ ] LLM-as-judge calibrated against human labels
- [ ] Regression suite in GitHub Actions

### Observability
- [ ] Structured logs
- [ ] OpenTelemetry traces exported to self-hosted Langfuse
- [ ] Prometheus + Grafana: latency percentiles, volume, errors, route mix, cost, GPU metrics

### Security
- [ ] Tenant isolation tests
- [ ] Prompt-injection test suite (malicious documents)
- [ ] Secrets via environment variables only
- [ ] Remote access only via Tailscale (no ports open to the internet)

### Operations
- [ ] Docker Compose deployment
- [ ] Backups with a tested restore
- [ ] Runbook
- [ ] Capacity note from a load test

### AWS environment
- [ ] Terraform-managed, remote state in S3
- [ ] Images in ECR pushed by GitHub Actions via OIDC (no long-lived keys)
- [ ] Database with pgvector, secrets in Secrets Manager or Parameter Store, CloudWatch logs
- [ ] Bedrock provider in the gateway
- [ ] Budget alarm and a timed destroy-and-rebuild

### Tenant #2
- [ ] Configuration-driven onboarding
- [ ] Deployment playbook
- [ ] Golden set built with the user
- [ ] Written case study

## Architecture

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

More detail in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Evaluation results

| Experiment | recall@5 | MRR | Faithfulness | p95 latency | Cost / 100 queries |
|---|---|---|---|---|---|
| *(first results in week 4)* | | | | | |

Experiment write-ups live in [docs/experiments/](docs/experiments/).

## Key decisions

- [ADR-0001: Record architecture decisions](docs/adr/0001-record-architecture-decisions.md)
- *More as they are made: see [docs/adr/](docs/adr/).*

## Quickstart

Coming in week 3. Until then, for contributors:

```bash
make setup      # install dependencies, create .env, install git hooks
make up         # start Postgres + pgvector
make lint test  # what CI runs
```

## Roadmap

| Week | Focus |
|---|---|
| 1 | Foundations: machine setup, LLMs, embeddings, a naive end-to-end RAG script |
| 2 | Ingestion and storage: parsing, chunking, incremental sync into Postgres + pgvector |
| 3 | The answering service: FastAPI, hybrid search, grounded cited answers, streaming, minimal UI |
| 4 | Evaluation: golden dataset, retrieval and answer metrics, calibrated LLM judge, evals in CI |
| 5 | Model gateway: local and cloud providers, routing policy, auth, rate limits, cost accounting |
| 6 | MCP server, a small agent loop, prompt-injection testing, daily use |
| 7 | Observability and production-readiness: tracing, Langfuse, dashboards, load test, backups, runbook |
| 8 | AWS: Terraform, ECR via OIDC, database, Bedrock provider, destroy-and-rebuild |
| 9 | Tenant #2 onboarding, case study, demo and interview prep |

## Licence

[MIT](LICENSE)
