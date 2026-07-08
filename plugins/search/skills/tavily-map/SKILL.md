---
description: Discover and list all URLs on a website — map site structure without extracting content
---

# tavily-map

Discover and list all URLs on a website without extracting content. Faster than crawling — useful for finding the right page before extracting, or for understanding site structure.

## CLI Usage (tavily CLI)

**Discover all URLs**
```bash
tvly map "https://docs.example.com" --json
```

**Natural language filtering**
```bash
tvly map "https://docs.example.com" --instructions "Find API docs and guides" --json
```

**Filter by path pattern**
```bash
tvly map "https://example.com" --select-paths "/blog/.*" --limit 500 --json
```

**Key options:**
- `--max-depth`: maximum crawl depth (default: 1)
- `--limit`: maximum number of URLs to return
- `--instructions`: natural language instructions for semantic filtering
- `--select-paths`: regex pattern for URL paths to include
- `--exclude-paths`: regex pattern for URL paths to exclude

## Use Cases

- **Site exploration**: Discover the structure of a documentation site or blog
- **Pre-extraction mapping**: Map a site to find the right pages, then extract their content
- **Change monitoring**: Compare maps of the same site over time to detect new pages
- **SEO analysis**: List all URLs on a site for auditing

## Authentication

Requires `TAVILY_API_KEY` for CLI usage.

## Tips

- Use `--instructions` for semantic filtering: "Find API docs" or "Find pricing pages"
- Combine with `tavily-extract` for efficient content gathering: map first, then extract
- Use `--select-paths` to focus on specific URL patterns
