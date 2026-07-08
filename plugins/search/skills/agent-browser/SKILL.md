---
description: Fast browser automation CLI for AI agents — navigate, click, fill, screenshot, extract data, automate web tasks
---

# agent-browser

Fast browser automation CLI for AI agents. Chrome/Chromium via CDP with accessibility-tree snapshots and compact `@eN` element refs.

## Installation

```bash
npm i -g agent-browser
agent-browser install           # downloads Chrome for Testing
```

Homebrew: `brew install agent-browser && agent-browser install`
Cargo: `cargo install agent-browser && agent-browser install`

## Core Loop

```bash
agent-browser open <url>         # 1. Open/navigate
agent-browser snapshot -i        # 2. See interactive elements with refs (@e1, @e2,...)
agent-browser click @e3          # 3. Act on refs
agent-browser snapshot -i        # 4. Re-snapshot after page change (refs go stale!)
```

## Reading a Page

```bash
agent-browser snapshot                    # full accessibility tree
agent-browser snapshot -i                 # interactive elements only (preferred)
agent-browser snapshot -i -u              # include href URLs on links
agent-browser snapshot -c                 # compact (skip empty structural nodes)
agent-browser snapshot -i --json          # machine-readable
agent-browser read                        # rendered DOM of active tab
agent-browser read https://docs.example.com  # fetch as markdown
```

## Interacting

```bash
agent-browser click @e1                   # click
agent-browser click @e1 --new-tab         # open link in new tab
agent-browser dblclick @e1                # double-click
agent-browser hover @e1                   # hover
agent-browser focus @e1                   # focus
agent-browser fill @e2 "text"             # clear + type
agent-browser type @e2 "more"             # type without clear
agent-browser press Enter                 # key at current focus
agent-browser check/uncheck @e3           # checkbox
agent-browser select @e4 "option-value"   # dropdown
agent-browser upload @e5 file.pdf         # file upload
agent-browser scroll down 500             # scroll
agent-browser scrollintoview @e1          # scroll element into view
agent-browser drag @e1 @e2                # drag and drop
```

## Semantic Locators

```bash
agent-browser find role button click --name "Submit"
agent-browser find text "Sign In" click
agent-browser find label "Email" fill "user@test.com"
agent-browser find placeholder "Search" type "query"
agent-browser find testid "submit-btn" click
agent-browser find first ".card" click
agent-browser find nth 2 ".item" hover
```

## Common Workflows

### Login
```bash
agent-browser open https://app.example.com/login
agent-browser snapshot -i
agent-browser fill @e3 "user@example.com"
agent-browser fill @e4 "password"
agent-browser click @e5
agent-browser wait --url "**/dashboard"
```

### Extract Data
```bash
agent-browser snapshot -i --json > page.json
agent-browser get text @e5
agent-browser get attr @e10 href
cat <<'EOF' | agent-browser eval --stdin
document.querySelectorAll("table tr").map(r => r.innerText)
EOF
```

### Screenshot
```bash
agent-browser screenshot page.png
agent-browser screenshot --full full.png
agent-browser screenshot --annotate map.png
```

## Global Flags

| Flag | Description |
|------|-------------|
| `--session <name>` | Isolated browser session |
| `--restore [name]` | Auto-save/restore session state |
| `--headed` | Show browser window |
| `--json` | JSON output |
| `--no-sandbox` | Run without sandbox (containers/VMs) |
| `--auto-connect` | Connect to running Chrome |

## MCP Integration

```bash
agent-browser mcp                          # start MCP stdio server
agent-browser mcp --tools all              # full tool parity
agent-browser mcp --tools core,network,react
```

## Troubleshooting

- **Ref not found**: re-snapshot (page changed)
- **Click does nothing**: overlay blocking — dismiss covering element
- **Install issues**: run `agent-browser doctor` first
