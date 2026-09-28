# Experiment NNNN: <title>

- **Date:** YYYY-MM-DD
- **Plan day:** Day NN
- **Git commit:** `<sha>`

## Hypothesis

If we change <variable> from <A> to <B>, then <metric> will <rise/fall> because <reason>.

## Setup

- **Dataset:** <name and version, number of questions>
- **Corpus:** <which documents, how many chunks>
- **Models:** <embedding model, generation model, judge model, with versions/quantisation>
- **Prompt version:** <file and version>
- **Config:** <chunk size, overlap, top-k, anything else relevant>
- **Hardware:** <machine, GPU>

## Variables changed

| Setting | Value |
|---|---|
| Baseline | |
| Variant 1 | |
| Variant 2 | |

## Results

| Setting | recall@5 | MRR | Faithfulness | p95 latency | Cost / 100 queries |
|---|---|---|---|---|---|
| Baseline | | | | | |
| Variant 1 | | | | | |

Link to raw results in `evals/results/`.

## Interpretation

What do the numbers say? Is the difference larger than the noise you'd expect with this many questions? Which questions changed, and why? Any surprises?

## Decision / next step

What we're changing (or not) as a result, and any ADR that follows.
