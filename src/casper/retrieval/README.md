# `casper.retrieval`

**Responsibility:** Given a question, a tenant and the caller's permissions, return the most relevant chunks with their scores and sources. It runs vector search and keyword search, merges them with reciprocal rank fusion, and applies tenant and sensitivity filters *inside the database query*, never after fetching results.

**Built in:** Week 3, Day 12 (hybrid search and the `/search` endpoint). Tuned with evals in week 4. See [PLAN.md](../../../docs/PLAN.md).

## Concepts to understand first
- [Cosine similarity](../../../docs/GLOSSARY.md#cosine-similarity)
- [Hybrid search](../../../docs/GLOSSARY.md#hybrid-search)
- [Reciprocal rank fusion](../../../docs/GLOSSARY.md#reciprocal-rank-fusion)
- [Reranker](../../../docs/GLOSSARY.md#reranker) (stretch)
- [recall@k](../../../docs/GLOSSARY.md#recallk) and [MRR](../../../docs/GLOSSARY.md#mrr)

## Questions to answer before writing code
1. Why must the tenant and sensitivity filters live in the SQL rather than being applied in Python afterwards?
2. How many results should each search method return before fusion, and how many after?
3. What should retrieval return so that generation can cite precisely and evals can score it?
4. How will you switch between vector-only, keyword-only and hybrid so you can compare them in an experiment?
5. What happens when nothing relevant is found? How would you even know?

## Definition of done
- `/search` returns ranked chunks with scores and sources for a question.
- A test proves that one tenant can never receive another tenant's chunks, and that `private` chunks are excluded when the caller is not allowed them.
- You have compared vector-only, keyword-only and hybrid on your Day 10 questions and written down what you saw.
