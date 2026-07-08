---
description: Tavily web search — real-time LLM-optimized search results with content snippets and relevance scores
---

# tavily-search

Search the web using Tavily's AI-optimized search engine. Returns structured results with content snippets, relevance scores, and metadata.

## MCP Tool (tavily-search)

The Tavily MCP server provides the `tavily-search` tool, accessible via the tavily-remote-mcp server.

**Usage patterns:**

- Web search: "Search for latest AI regulations"
- Research: "Find recent papers on multimodal learning"
- News: "Search for today's tech news"

**Default parameters** (can be overridden):
- `include_favicon`: true
- `include_images`: false
- `include_raw_content`: false

## CLI Usage (tavily CLI)

Install Tavily CLI for advanced search options:

```bash
curl -fsSL https://cli.tavily.com/install.sh | bash
```

**Basic search**
```bash
tvly search "your query" --json
```

**Advanced search with depth**
```bash
tvly search "quantum computing" --depth advanced --max-results 10 --json
```

**Recent news**
```bash
tvly search "AI news" --time-range week --topic news --json
```

**Domain-filtered**
```bash
tvly search "SEC filings" --include-domains sec.gov,reuters.com --json
```

**Key options:**
- `--depth`: ultra-fast | fast | basic | advanced
- `--max-results`: number of results to return
- `--topic`: general | news
- `--time-range`: day | week | month | year
- `--include-domains`: comma-separated list of domains to include
- `--exclude-domains`: comma-separated list of domains to exclude
- `--include-raw-content`: include raw HTML content

## Authentication

The tavily-remote-mcp server uses **OAuth 2.0** authentication with Claude Code. When you first use the server, Claude Code will open a browser for you to complete the OAuth flow and authorize access to your Tavily account. No API key needed in the URL — authentication is handled automatically via OAuth.

For CLI usage, you need a Tavily API key (get one from tavily.com):
```bash
export TAVILY_API_KEY="your-api-key"
```

## Search Tips

- Use `--depth advanced` for comprehensive results with more content snippets
- Combine with `--topic news` and `--time-range week` for recent news
- Use domain filters to limit to authoritative sources
- For deep research, pipe results into other tools:
  ```bash
  tvly search "quantum computing" --json | jq -r '.results[].content' | head -100
  ```
