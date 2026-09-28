# Experiments

Every change you believe is an improvement gets measured before and after, and written up here with numbers. This is where claims like "hybrid search improved recall@5 from 0.62 to 0.81" come from.

## How to run an experiment

1. **State a hypothesis** before you run anything ("Smaller chunks will raise recall@5 because…").
2. **Change one variable.** Keep the dataset, models, prompts and everything else fixed.
3. **Record the setup** precisely enough that you could reproduce it: git commit, dataset version, model versions, config.
4. **Run the eval suite** for each setting and put the numbers in a table.
5. **Interpret honestly.** With ~50 questions, small differences may be noise; say so.
6. **Decide** what happens next, and write an ADR if a decision follows.

## Naming

`NNNN-short-description.md`, numbered sequentially, e.g. `0001-chunk-size.md`, `0002-local-vs-cloud.md`. Copy [0000-template.md](0000-template.md) to start.

## Index

| # | Title | Headline result |
|---|---|---|
| | *(first experiment on Day 19)* | |
