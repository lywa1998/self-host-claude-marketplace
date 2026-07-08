---
description: AI-powered deep research — gather sources, analyze, and produce a cited report (30-120 seconds)
---

# tavily-research

AI-powered deep research that gathers sources, analyzes them, and produces a cited report. Takes 30–120 seconds. Perfect for competitive analysis, market research, and deep dives.

## CLI Usage (tavily CLI)

**Basic research**
```bash
tvly research "competitive landscape of AI code assistants"
```

**Pro model for comprehensive analysis**
```bash
tvly research "electric vehicle market analysis" --model pro
```

**Stream results in real-time**
```bash
tvly research "AI agent frameworks comparison" --stream
```

**Save report to file**
```bash
tvly research "fintech trends 2025" --model pro -o report.md
```

**Key options:**
- `--model`: mini | pro | auto (pro gives most thorough analysis)
- `--stream`: stream output as it's generated
- `--citation-format`: citation format (e.g., "markdown")
- `--output-schema`: custom output schema (JSON schema)
- `-o, --output`: save report to a file

## Use Cases

- **Market research**: Analyze competitive landscape, market trends
- **Technical analysis**: Deep dive into emerging technologies, compare approaches
- **Investment research**: Gather and synthesize information from multiple sources
- **Report generation**: Produce a cited, well-structured report on any topic

## Authentication

Requires `TAVILY_API_KEY` for CLI usage.

## Tips

- Use `--model pro` for comprehensive analysis (takes longer, more thorough)
- Use `--stream` to see results as they're generated
- Save reports to markdown files with `-o` for easy reference
- Combine with `tavily-crawl` to gather more detailed information on specific sources
