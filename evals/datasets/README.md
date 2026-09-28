# Golden datasets

A golden dataset is a hand-written set of questions with known correct answers and sources. Write them **by hand**: generated questions tend to be easy and phrased like the source text, while real users ask vaguer, messier questions.

## Folders

- **`private/`**: questions about your real notes. **Git-ignored; never leaves your machine.** Only `.gitkeep` is committed.
- **`public/`**: a small synthetic or public-domain corpus plus about 15 questions about it. Committed, and used by CI.

## Format: JSONL

Each dataset is a JSONL (JSON Lines) file: one JSON object per line, one line per golden item. JSONL is easy to append to, diff line by line and stream.

### Proposed schema for a golden item

| Field | Type | Required | Meaning |
|---|---|---|---|
| `id` | string | yes | Stable unique identifier, e.g. `"q-001"`. Never reuse an ID, so results stay comparable across runs. |
| `question` | string | yes | The question exactly as a user would ask it. |
| `expected_answer` | string or null | yes | A short reference answer. `null` for questions that have **no answer** in the corpus (Casper should abstain). |
| `expected_sources` | list of strings | yes | Sources that support the answer, as `"path/to/file.md#Heading > Subheading"`. Empty list for no-answer questions. |
| `tags` | list of strings | no | Categories for slicing results, e.g. `"lookup"`, `"multi-note"`, `"exact-term"`, `"no-answer"`, `"friction-log"`. |
| `difficulty` | string | no | `"easy"`, `"medium"` or `"hard"`. |
| `notes` | string | no | Why this question exists, or anything a reviewer should know. |

### Example lines (synthetic)

```jsonl
{"id": "q-001", "question": "How long is the warranty on the kettle?", "expected_answer": "Two years from the date of purchase.", "expected_sources": ["manuals/kettle.md#Warranty"], "tags": ["lookup"], "difficulty": "easy", "notes": ""}
{"id": "q-002", "question": "What's invoice INV-20931 for?", "expected_answer": "Replacement bike brake pads.", "expected_sources": ["finance/invoices.md#2026 > March"], "tags": ["exact-term"], "difficulty": "medium", "notes": "Tests keyword search: embeddings struggle with codes."}
{"id": "q-003", "question": "What's my passport number?", "expected_answer": null, "expected_sources": [], "tags": ["no-answer"], "difficulty": "easy", "notes": "Not in the corpus; Casper should say it couldn't find it."}
```

This schema is a proposal. Change it when you build the runner in week 4 if you find you need something else, and record why in the week 4 evaluation ADR.

## A good mix (Day 16)

Aim for 40–60 private questions covering: easy lookups, questions needing two notes, exact-term questions (codes, names, numbers), questions with no answer, and questions from your week 3 friction log.
