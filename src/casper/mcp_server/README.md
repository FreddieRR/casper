# `casper.mcp_server`

**Responsibility:** Expose Casper to AI applications through MCP (Model Context Protocol), so Claude Desktop and Claude Code can search your knowledge base directly. It offers tools such as `search_notes`, `get_note` and `ask`, and calls the Casper API with its own API key rather than touching the database.

**Built in:** Week 6. Day 26 (the server, tested with MCP Inspector) and Day 27 (connected to Claude Desktop/Claude Code, descriptions tuned from real use). See [PLAN.md](../../../docs/PLAN.md).

## Concepts to understand first
- [MCP](../../../docs/GLOSSARY.md#mcp)
- [Tool use](../../../docs/GLOSSARY.md#tool-use)
- [Agent](../../../docs/GLOSSARY.md#agent)
- [Prompt injection](../../../docs/GLOSSARY.md#prompt-injection)
- The official MCP Python SDK README (github.com/modelcontextprotocol/python-sdk)

## Questions to answer before writing code
1. Which capabilities should be MCP **tools** and which, if any, should be **resources**?
2. How will the model decide when to call each tool, and what makes a tool description good or bad?
3. Note content returned by your server enters Claude's context, which is a cloud model. What should happen to `private` notes?
4. Why should the MCP server go through the API with its own key rather than reading the database directly?
5. Which transport (stdio or HTTP) suits Claude Desktop on your machine, and which would suit a remote tenant?

## Definition of done
- MCP Inspector lists your tools and can call each one successfully.
- Claude Desktop or Claude Code answers a real question using your tools.
- The privacy behaviour for `private` notes is decided, implemented, tested and recorded in an ADR.
- MCP-originated requests are visible in logs or traces.
