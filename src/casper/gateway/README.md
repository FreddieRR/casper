# `casper.gateway`

**Responsibility:** Be the single front door for every model call. It exposes an OpenAI-compatible chat completions API, forwards requests to a provider (Ollama locally, Anthropic in the cloud, Amazon Bedrock from week 8), and applies policy on the way: API-key authentication, rate limiting, token and cost accounting, and routing (private content goes to the local model only; non-private requests fall back to the cloud when the GPU node is offline).

**Built in:** Week 5. Day 21 (design + Ollama provider), Day 22 (Anthropic provider, cost accounting), Day 23 (routing and resilience), Day 24 (auth and rate limiting), Day 25 (local vs cloud measured, LiteLLM comparison). Bedrock provider on Day 39. See [PLAN.md](../../../docs/PLAN.md).

## Concepts to understand first
- [Gateway](../../../docs/GLOSSARY.md#gateway)
- [Token](../../../docs/GLOSSARY.md#token)
- [Rate limiting](../../../docs/GLOSSARY.md#rate-limiting) and [token bucket](../../../docs/GLOSSARY.md#token-bucket)
- [Circuit breaker](../../../docs/GLOSSARY.md#circuit-breaker)
- [Amazon Bedrock](../../../docs/GLOSSARY.md#amazon-bedrock)

## Questions to answer before writing code
1. What is the smallest provider abstraction that fits Ollama, Anthropic *and* Bedrock without leaking any one of them into the rest of the code?
2. How does the gateway know a request contains private content, and who is trusted to say so?
3. Why must a private request **fail** when the local model is down instead of falling back to the cloud? How will the error look to the user?
4. Where could an API key leak (logs, errors, traces, Git), and how do you prevent each?
5. Build it by hand or adopt LiteLLM? What would you choose in production, and why? (ADR.)

## Definition of done
- The answering service makes every model call through the gateway; nothing calls Ollama or Anthropic directly.
- With Ollama switched off, a private question refuses cleanly and a normal one falls back to the cloud; the route taken is logged for every request.
- Tests cover a missing key, a bad key and an exceeded rate limit.
- Tokens and estimated cost are recorded per request.
- An experiment write-up compares local and cloud on quality, p50/p95 latency and cost per 100 questions.
