# Evaluations

Evals are how Casper proves a change helps instead of guessing. A fixed set of questions with known answers and sources is run through the system, and the results are scored. Run them before and after every change you believe is an improvement, and let CI (continuous integration) fail the build when retrieval quality drops.

Built in week 4 (Days 16–20). Read Hamel Husain, "Your AI Product Needs Evals", first.

## What gets measured

**Retrieval** (plain code, no model needed):
- **recall@k:** did a correct source appear in the top k results? Reported at k = 1, 3, 5, 10.
- **MRR (mean reciprocal rank):** how high did the first correct source rank?

**Answers** (some checks in code, some with an LLM-as-judge):
- **Faithfulness:** is every claim supported by the cited sources?
- **Correctness:** does the answer match the expected answer?
- **Citation validity:** do citations exist and point at the right sources?
- **Abstention:** does it say "not found" when the notes don't contain the answer?

The LLM judge is only trusted after it has been calibrated against your own hand labels, with the agreement rate recorded.

## Layout

```
evals/
├── datasets/
│   ├── README.md      # the golden-item schema
│   ├── private/       # built from your real notes: git-ignored, never leaves your machine
│   └── public/        # synthetic or public-domain corpus + questions: used by CI
├── runners/           # the eval runner code (you write this in week 4)
└── results/           # run outputs, tagged with git commit, config and dataset version
```

## Privacy rules

- **Private datasets never leave the machine.** `datasets/private/` is git-ignored and must never be copied into `public/`, pasted into an issue, or sent to a cloud judge if it contains private content.
- **CI runs only against `datasets/public/`**, using a small synthetic corpus ingested into a throwaway database.
- **Results from private runs** should be saved with `.local.` in the filename (e.g. `2026-10-20-baseline.local.json`); those files are git-ignored. Only aggregate numbers go into the README and experiment write-ups.

## Running

`make eval` (prints "not implemented yet: week 4" until then).
