---
description: Crawl websites and extract content from multiple pages — save as local markdown files or structured JSON
---

# tavily-crawl

Crawl websites and extract content from multiple pages. Save each page as a local markdown file or get structured JSON output. Useful for documentation crawling, competitor analysis, and content gathering.

## CLI Usage (tavily CLI)

**Save each page as a markdown file**
```bash
tvly crawl "https://docs.example.com" --output-dir ./docs/
```

**Semantic focus** (returns relevant chunks, not full pages)
```bash
tvly crawl "https://docs.example.com" --instructions "Find authentication docs" --chunks-per-source 3 --json
```

**Filter to specific paths**
```bash
tvly crawl "https://example.com" --select-paths "/api/.*,/guides/.*" --exclude-paths "/blog/.*" --json
```

**Key options:**
- `--max-depth`: maximum crawl depth (default: 1)
- `--limit`: maximum number of pages to crawl
- `--instructions`: natural language instructions for semantic filtering
- `--chunks-per-source`: number of relevant chunks per page
- `--output-dir`: directory to save markdown files
- `--select-paths`: regex pattern for URL paths to include
- `--exclude-paths`: regex pattern for URL paths to exclude

## Authentication

Requires `TAVILY_API_KEY` for CLI usage.

## Use Cases

- **Documentation archiving**: Crawl and save entire documentation sites locally
- **Competitive analysis**: Crawl competitor docs, pricing pages, and blogs
- **Content aggregation**: Gather content from multiple sources for analysis
- **Research collection**: Crawl research papers, news sites, or blogs

## Authentication

Requires `TAVILY_API_KEY` for CLI usage.

## Tips

- Use `--select-paths` and `--exclude-paths` to precisely control what gets crawled
- `--instructions` for semantic filtering is powerful — "Find pricing pages" or "Extract API examples"
- Combine with `--output-dir` to build a local documentation reference
- For very large sites, set `--max-depth` and `--limit` to manage crawl scope
