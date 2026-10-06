# Architecture

This document describes what each component is *responsible for*, not how it is implemented. Implementation choices are recorded as ADRs (architecture decision records) in [adr/](adr/) as they are made.

## Overview

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

## Components

**Interfaces (MCP server, web UI, CLI).** The ways a person or an AI application asks Casper something. They hold no business logic: each one authenticates with its own API key and calls the API service. The MCP (Model Context Protocol) server lets Claude Desktop and Claude Code use Casper as a set of tools.

**API service.** The single entry point for every interface. It authenticates the caller, works out their tenant and permissions, and orchestrates retrieval and answer generation. It is where streaming responses are served from.

**Retrieval.** Finds the chunks most relevant to a question using vector search and keyword search, merged with reciprocal rank fusion. Tenant and sensitivity filters are applied inside the database query so that data a caller may not see is never fetched in the first place.

**Generation.** Turns a question and retrieved chunks into a grounded answer with citations to file and heading, or an explicit "not found" when the sources don't support one.

**Model gateway.** The only component that talks to models. It presents one OpenAI-compatible interface, chooses a provider according to the routing policy (private content goes to the local model only; non-private requests can fall back to the cloud), and enforces API-key authentication, rate limits and token/cost accounting.

**Model providers.** Ollama runs local models on the GPU laptop and can be switched off. The Anthropic API provides Claude in the cloud. From week 8, Amazon Bedrock provides Claude inside an AWS account.

**Postgres + pgvector.** One database holding tenants, documents, chunks, embeddings, a full-text index, API keys and usage records. It is the system of record; everything else can be rebuilt from it and the source documents.

**Ingestion worker.** Keeps the database in step with the source documents. It parses, chunks, embeds and upserts only what has changed, and removes what has been deleted.

**Observability.** Every service emits structured logs, OpenTelemetry traces (sent to Langfuse, which understands LLM calls) and Prometheus metrics (shown in Grafana). Note content never goes into logs or trace attributes.

**Evaluation runner.** Runs golden datasets against the API, scores retrieval and answers, writes results to `evals/results/`, and gates changes in CI (continuous integration).

## Data flow: ingestion

1. The ingestion worker scans the configured sources (vault path, PDF folder) for a tenant.
2. For each file it computes a content hash and compares it with the stored one: new, changed, deleted or unchanged.
3. New and changed files are parsed (metadata, heading structure, sensitivity label), split into chunks, and embedded. (Whether embedding calls go through the model gateway is a design question for week 5.)
4. Each document's chunks and embeddings are written in a single transaction, replacing the old ones. Deleted files have their chunks removed.
5. A summary (added / updated / deleted / skipped, time taken) is reported.

## Data flow: a query

1. An interface sends the question to the API with its API key.
2. The API authenticates the key, resolves the tenant and whether the caller may see `private` content.
3. Retrieval embeds the question, runs vector and keyword search filtered by tenant and sensitivity, and fuses the results.
4. If nothing relevant is found, the API returns a "not found" answer without calling a model.
5. Generation builds the prompt with numbered sources and sends it to the gateway, marking whether any source is `private`.
6. The gateway applies rate limits, picks a provider according to the routing policy, streams the response back and records tokens and cost.
7. The API streams tokens to the client over SSE (server-sent events) and finishes with the citations mapped to file and heading.
8. Each stage emits spans and metrics; the full trace is visible in Langfuse.

## Deployment topologies

**Home (weeks 1–7).** Everything runs on the GPU laptop at first. Optionally, from week 7, an always-on mini PC runs Postgres, the API, the gateway, Langfuse, Prometheus and Grafana, and the laptop becomes a GPU node that can be switched off. Access is only over Tailscale; no ports are open to the internet.

**AWS (week 8+).** A separate environment in a personal AWS account, standing in for "a customer's cloud", built entirely with Terraform. Models are provided by Amazon Bedrock. Tenant #2 is hosted here.

## Decisions pending

| ADR | Decision | Plan day |
|---|---|---|
| 0002 | OS on the laptop: Windows + WSL2 (Windows Subsystem for Linux), kept for gaming, rather than Ubuntu | Day 1 / Day 5 |
| 0003 | Database schema; ORM (object-relational mapper) vs raw SQL | Day 6 / Day 10 |
| 0004 | Postgres + pgvector vs a dedicated vector database | Day 6 |
| 0005 | Chunking strategy and sizes | Day 8 / Day 10 |
| 0006 | Embedding model and local generation model | Days 2–4, revisited week 4 |
| 0007 | Web UI approach (plain HTML + HTMX vs Angular) | Day 15 |
| 0008 | Prompt design and versioning | Day 15 |
| 0009 | Evaluation approach | Day 20 |
| 0010 | Routing policy | Day 25 |
| 0011 | Hand-built gateway vs LiteLLM | Day 25 |
| 0012 | MCP server design and handling of `private` notes | Day 30 |
| 0013 | Security posture | Day 30 |
| 0014 | What traces store for `private` requests | Day 32 |
| 0015 | AWS compute: EC2 + Compose vs ECS Fargate + RDS | Day 38 |
| 0016 | Secrets Manager vs SSM Parameter Store | Day 39 |
| 0017 | How tenant #2 reaches the AWS environment | Day 39 |

Numbers are a suggestion; use the next free number when you write each one.
