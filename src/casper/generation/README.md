# `casper.generation`

**Responsibility:** Turn retrieved chunks and a question into a grounded answer. It builds the prompt (numbered sources, instructions to answer only from them), calls a model through the gateway, streams the answer back, and maps citation markers like `[1]` to file and heading. When the context does not support an answer, it says so instead of guessing.

**Built in:** Week 3. Day 13 (grounded answers and citations) and Day 14 (streaming). Prompts are measured in week 4. See [PLAN.md](../../../docs/PLAN.md).

## Concepts to understand first
- [RAG](../../../docs/GLOSSARY.md#rag)
- [Grounding](../../../docs/GLOSSARY.md#grounding)
- [Hallucination](../../../docs/GLOSSARY.md#hallucination)
- [Citation](../../../docs/GLOSSARY.md#citation)
- [Prompt injection](../../../docs/GLOSSARY.md#prompt-injection)
- [SSE](../../../docs/GLOSSARY.md#sse)

## Questions to answer before writing code
1. How will you separate your instructions from retrieved document text in the prompt, given that documents may contain hostile instructions?
2. What happens when retrieval returns nothing relevant: do you call the model at all?
3. How will you detect a citation that points at a source that doesn't exist (e.g. `[3]` when there were two)?
4. Where do prompts live, and how will an eval run record which prompt version it used?
5. What does the client receive while streaming, and when does it receive the citations?

## Definition of done
- A question with a supported answer returns a short answer with valid citations that map to file and heading.
- A question with no support in the notes returns an explicit "I couldn't find that in your notes" style answer.
- Tokens stream to the CLI and web UI as they are generated; time-to-first-token is measured.
- Prompts live in versioned files, not inline strings.
