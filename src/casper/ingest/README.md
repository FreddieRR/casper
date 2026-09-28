# `casper.ingest`

**Responsibility:** Turn raw documents (Obsidian markdown and PDFs) into searchable chunks in the store. It parses each file (frontmatter, heading hierarchy, tags, wikilinks, PDF page numbers), splits it into heading-aware chunks, embeds them, and syncs them with the database incrementally: new files are added, changed files are re-processed, deleted files are removed and unchanged files are skipped. Every document carries a sensitivity label (e.g. `private` / `normal`) and a tenant.

**Built in:** Week 2. Day 7 (parsing), Day 8 (chunking), Day 9 (incremental, idempotent sync and the `casper ingest` command). See [PLAN.md](../../../docs/PLAN.md).

## Concepts to understand first
- [Chunk](../../../docs/GLOSSARY.md#chunk)
- [Embedding](../../../docs/GLOSSARY.md#embedding)
- [Content hash](../../../docs/GLOSSARY.md#content-hash)
- [Idempotency](../../../docs/GLOSSARY.md#idempotency)
- [Tenant](../../../docs/GLOSSARY.md#tenant)

## Questions to answer before writing code
1. What does a *parsed document* look like, independent of whether it came from markdown or a PDF? What must it keep so you can cite and filter by it later?
2. How will you know a file changed, and what happens when a note is **renamed** rather than edited?
3. How big should a chunk be, what happens to a section that is too long, and what text (title, heading path) goes in front of it before embedding?
4. If ingestion crashes halfway through a document, what state is the database in? How do you make re-running safe?
5. Where does a document's sensitivity label come from, and what is the default when a note has none?

## Definition of done
- `casper ingest` on your whole vault finishes and prints added / updated / deleted / skipped counts and the time taken.
- Running it again with no changes skips every file and is much faster.
- Editing one note re-processes only that note; deleting a note removes its chunks.
- Every chunk in the database has a heading path, a source path, a sensitivity label and a tenant.
- Tests cover a long section splitting, a tiny note staying whole, and correct heading paths, using synthetic fixtures in `tests/fixtures/`.
