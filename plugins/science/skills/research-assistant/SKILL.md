---
description: alphaXiv MCP research assistant — search papers, read content, query PDFs, explore GitHub code, and manage library
---

# alphaXiv Research Assistant

This skill integrates with the **alphaXiv MCP server** to provide AI-powered research capabilities. Use it to discover papers, analyze PDFs, read arXiv content, explore code repositories, and manage your paper library.

## Authentication

The MCP server uses **OAuth 2.0** authentication. You will need an alphaXiv API key. Set it in your environment:

```bash
export ALPHAXIV_API_KEY="your-api-key-here"
```

Or configure it in your Claude Code settings.

## Available Tools

The server exposes **11 tools** across two categories:

### Research Tools (AI-powered, count against quota)

#### 1. `discover_papers`
**Discover and rank papers for a research topic**

Performs agentic retrieval combining keyword search, embedding search, and multi-round follow-up searches.

**Parameters:**
- `keywords` (string[], required) — 3-4 concise terms for exact matching (acronyms, methods, authors, titles)
- `question` (string, required) — Detailed semantic description of desired papers
- `difficulty` (number 1-10, required) — Retrieval effort (higher = more follow-up rounds)

**Returns:** Ranked list of 5-15 papers with title, date, organizations, abstract, and arXiv ID.

**Example:**
```json
{
  "keywords": ["hallucination", "LLM", "factuality"],
  "question": "Recent approaches to reducing hallucination in large language models, covering retrieval grounding, decoding-time interventions, and post-hoc verification.",
  "difficulty": 5
}
```

---

#### 2. `get_paper_content`
**Get paper content as text**

Returns AI-generated intermediate reports optimized for LLM consumption, or raw text if no report exists.

**Parameters:**
- `url` (string, required) — arXiv/alphaXiv URL (e.g., `https://arxiv.org/abs/2307.12307`)
- `fullText` (boolean, optional) — If true, return raw extracted text instead of the report (default: false)

**Returns:** AI-generated report or full extracted text of the paper.

**Example:**
```json
{
  "url": "https://arxiv.org/abs/2307.12307"
}
```

---

#### 3. `answer_pdf_queries`
**Query a single PDF and get relevant page-level content**

Returns XML-structured output (`<paper id="..."><page num="N">...</page></paper>`) with pages relevant to your queries. Batch multiple questions into one call — they're nearly free.

**Parameters:**
- `url` (string, required) — PDF URL (arXiv, alphaXiv, Semantic Scholar, or direct PDF URL)
- `queries` (string[], required) — One or more questions about the paper

**Returns:** XML with only relevant pages, suitable for constructing citations.

**Example:**
```json
{
  "url": "https://www.alphaxiv.org/abs/2512.16649",
  "queries": [
    "Main hyperparameters used in experiments",
    "Evaluation metrics and benchmark datasets",
    "Limitations discussed by the authors"
  ]
}
```

---

#### 4. `read_files_from_github_repository`
**Read files from a paper's codebase repository**

Special behaviors:
- Reading `/` returns the complete file tree and all top-level files
- Reading a directory fetches all files in parallel
- Reading a file returns its contents

**Parameters:**
- `githubUrl` (string, required) — Repository URL (e.g., `https://github.com/owner/repo`)
- `path` (string, required) — Path to file/directory; use `/` for overview

**Returns:** File contents (text) or directory listing with contents fetched in parallel.

**Example:**
```json
{
  "githubUrl": "https://github.com/openai/gpt-2",
  "path": "/"
}
```

---

### Library Tools (Paper organization)

#### 5. `list_library`
**List all folders (bookmark collections) with paper counts**

**Parameters:**
- `include_papers` (boolean, optional) — Also list papers inside each folder
- `paper_ids_or_urls` (string[], optional) — Check which folders contain specific papers

**Returns:** Folder list with IDs, names, types, sharing status, and paper counts.

**Example:**
```json
{
  "paper_ids_or_urls": ["2307.12307", "https://arxiv.org/abs/1706.03762"]
}
```

---

#### 6. `save_papers_to_folder`
**Save papers to a folder (idempotent, never removes from other folders)**

**Parameters:**
- `paper_ids_or_urls` (string[1-50], required) — arXiv IDs or URLs
- `folder_id` (string, optional) — Target folder; defaults to "Want to read"

**Returns:** Target folder_id and status per paper (added/already existed/not found).

---

#### 7. `remove_papers_from_folder`
**Remove papers from a single folder**

**Parameters:**
- `paper_ids_or_urls` (string[1-50], required) — arXiv IDs or URLs
- `folder_id` (string, required) — Folder to remove from

**Returns:** Which papers were removed, which were not in the folder, which were not found.

---

#### 8. `move_papers_between_folders`
**Move papers from one folder to another**

**Parameters:**
- `paper_ids_or_urls` (string[1-50], required) — arXiv IDs or URLs
- `from_folder_id` (string, required) — Source folder
- `to_folder_id` (string, required) — Target folder

**Returns:** Movement results per paper.

---

#### 9. `create_folder`
**Create a new folder in your library**

**Parameters:**
- `name` (string, required) — Folder name
- `parent_id` (string, optional) — Parent folder ID for nesting

**Returns:** The new folder's ID.

---

#### 10. `rename_folder`
**Rename an existing folder**

**Parameters:**
- `folder_id` (string, required) — Folder to rename
- `name` (string, required) — New name

---

#### 11. `delete_folder`
**Delete a folder**

**Parameters:**
- `folder_id` (string, required) — Folder to delete

**Returns:** Deletion confirmation.

---

## Common Workflows

### Literature Review
1. Use `discover_papers` with broad question and high difficulty (8+)
2. For each interesting paper, use `get_paper_content` to read the report
3. Use `save_papers_to_folder` to organize into reading lists

### Code Analysis
1. Find paper with `discover_papers`
2. Get paper content with `get_paper_content`
3. Extract GitHub URL from paper content
4. Use `read_files_from_github_repository` to explore the codebase

### Deep Research
1. Use `answer_pdf_queries` to batch multiple questions about a single paper
2. Cross-reference with GitHub code using `read_files_from_github_repository`
3. Build a detailed understanding page by page

### Library Management
1. Use `list_library` to see current organization
2. Use `create_folder` to make new collections
3. Use `save_papers_to_folder` / `remove_papers_from_folder` / `move_papers_between_folders` to manage papers

## Tips

- **Batch queries:** `answer_pdf_queries` can handle multiple questions per paper efficiently
- **Use difficulty wisely:** Higher difficulty (7-10) triggers more rounds but takes longer
- **Reports vs full text:** `get_paper_content` returns a structured AI report by default — use `fullText: true` for raw text
- **Library defaults:** `save_papers_to_folder` defaults to "Want to read" if no `folder_id` is specified
- **GitHub exploration:** Reading `/` gives you the complete repo structure quickly
