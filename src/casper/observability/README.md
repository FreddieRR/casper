# `casper.observability`

**Responsibility:** Make every request explainable after the fact. It sets up structured JSON logs with a request ID that flows through every stage, OpenTelemetry spans for each step (embed, search, generate), LLM generation records sent to Langfuse, and Prometheus metrics (request count, errors, latency histograms, time-to-first-token, route mix, tokens, cost). It never records note content in attributes or logs.

**Built in:** Week 7. Day 31 (structured logs and tracing), Day 32 (Langfuse), Day 33 (metrics and dashboards). See [PLAN.md](../../../docs/PLAN.md).

## Concepts to understand first
- [OpenTelemetry](../../../docs/GLOSSARY.md#opentelemetry)
- [Trace](../../../docs/GLOSSARY.md#trace) and [span](../../../docs/GLOSSARY.md#span)
- [p50 and p95 latency](../../../docs/GLOSSARY.md#p50-and-p95-latency)
- [Structured logging](../../../docs/GLOSSARY.md#structured-logging)
- Google SRE book, "Monitoring Distributed Systems" (the four golden signals)

## Questions to answer before writing code
1. What must **never** appear in a log line, span attribute or Langfuse trace for this system?
2. How does one request ID follow a request from the API through retrieval, the gateway and the provider?
3. What is the difference between what Langfuse shows you and what Prometheus/Grafana shows you?
4. What does a trace store for a `private` request? (ADR.)
5. Which one alert would actually wake you up for a real problem, and what threshold?

## Definition of done
- Any answer can be traced end to end, showing time spent in each stage, the route taken and the model used.
- A failing eval question links to its full trace in Langfuse.
- A Grafana dashboard shows the four golden signals, GPU utilisation/VRAM/temperature and cost per day, exported as JSON to `infra/grafana/`.
- A test or check confirms that no note content appears in logs or span attributes.
