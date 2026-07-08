---
description: Extract clean markdown/text content from URLs using Tavily — handles JavaScript-rendered pages. Requires Tavily MCP server setup (see tavily-search skill).
---

# tavily-extract

Extract clean markdown or text content from one or more URLs. Handles JavaScript-rendered pages, extracts only relevant content, and filters out navigation, ads, and other clutter.

## MCP Tool (tavily-extract)

The Tavily MCP server provides the `tavily-extract` tool for extracting content from URLs via the tavily-remote-mcp server.

**Example prompts:**
- "Extract the content from this article URL"
- "Extract content from these three documentation pages"

## CLI Usage (tavily CLI)

**Single URL**
```bash
tvly extract "https://example.com/article" --json
```

**Multiple URLs**
```bash
tvly extract "https://example.com/page1" "https://example.com/page2" --json
```

**Query-focused extraction** (returns relevant chunks only)
```bash
tvly extract "https://example.com/docs" --query "authentication API" --chunks-per-source 3 --json
```

**Key options:**
- `--query`: natural language query for extraction focus
- `--chunks-per-source`: number of relevant chunks to return per source
- `--extract-depth`: basic | advanced (advanced includes more details)
- `--format`: markdown | text

## Use Cases

- **Read article content**: Extract the main text from a blog post, news article, or documentation page
- **Multi-page scraping**: Batch extract from multiple URLs and analyze together
- **Focused extraction**: Use `--query` to extract only sections relevant to a specific topic
- **RAG pipelines**: Feed extracted content into vector stores or LLM prompts

## Authentication

Same as tavily-search — uses tavily-remote-mcp with OAuth (for MCP) or requires `TAVILY_API_KEY` for CLI.

## Tips

- Use `--format markdown` for structured output with headings and links
- Use `--query` with `--chunks-per-source 1-5` for efficient targeted extraction
- Extract + LLM combine well: extract raw content, then use `answer_pdf_queries` (from science plugin) for PDFs
