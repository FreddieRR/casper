# `casper.api`

**Responsibility:** The FastAPI service that every interface (web UI, CLI, MCP server) talks to. It loads configuration, holds the database connection, checks health, and exposes endpoints for searching and asking. It wires the other modules together but contains no retrieval or generation logic of its own.

**Built in:** Week 3. Day 11 (skeleton, `/health`, config, Dockerfile, Compose service), Day 12 (`/search`), Days 13-14 (`/ask` with streaming). Auth arrives in week 5 and `/metrics` in week 7. See [PLAN.md](../../../docs/PLAN.md).

## Concepts to understand first
- [SSE](../../../docs/GLOSSARY.md#sse)
- [Tenant](../../../docs/GLOSSARY.md#tenant)
- [Container image](../../../docs/GLOSSARY.md#container-image)
- The Twelve-Factor App, "Config" and "Logs" (12factor.net)

## Questions to answer before writing code
1. What should `/health` check, and what should it return when the database is up but Ollama is not?
2. How is a database connection shared across requests, and what happens when it drops?
3. How does a container reach Ollama running on the host?
4. How does a request carry its tenant and permissions, and where are they checked?
5. Which errors should a client see, and which should only appear in logs?

## Definition of done
- `docker compose up` starts the API alongside the database, and `/health` reports both the database and Ollama status.
- `/search` and `/ask` work from `curl`, the CLI and the web UI.
- `/health` has a test using FastAPI's test client.
- All configuration comes from environment variables.
