# `casper.store`

**Responsibility:** Own the database. It defines the schema (tenants, documents, chunks, embeddings, full-text index and, later, API keys and usage records) as SQL migrations, and it is the only place in the codebase that talks to Postgres. Other modules ask the store for data; they never write SQL themselves.

**Built in:** Week 2. Day 6 (schema, pgvector, first nearest-neighbour query) and Day 10 (full-text index). Extended in week 5 (API keys, token and cost records). See [PLAN.md](../../../docs/PLAN.md).

## Concepts to understand first
- [Vector](../../../docs/GLOSSARY.md#vector)
- [Vector database](../../../docs/GLOSSARY.md#vector-database)
- [HNSW](../../../docs/GLOSSARY.md#hnsw)
- [BM25 and full-text search](../../../docs/GLOSSARY.md#bm25-and-full-text-search)
- [Tenant](../../../docs/GLOSSARY.md#tenant)

## Questions to answer before writing code
1. What tables do you need, and where does each piece of metadata (path, heading path, tags, sensitivity, tenant, content hash) live?
2. What happens to chunks and embeddings when their document is deleted?
3. ORM (object-relational mapper) or raw SQL? What do you gain and lose either way? (ADR candidate.)
4. How will you apply schema changes over time, both on your laptop and later on AWS?
5. Why store a tenant ID on every chunk rather than giving each tenant a separate database?

## Definition of done
- `make up` then running your migrations produces the full schema on an empty database.
- A nearest-neighbour query and a full-text query both run in SQL against real rows and return sensible results.
- Deleting a document leaves no orphaned chunks or embeddings.
- There is an ADR recording the schema and ORM-vs-raw-SQL decision.
