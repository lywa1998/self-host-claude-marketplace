---
name: dioxus-setup
description: "This skill should be used when the user asks to 'install dioxus', 'setup dioxus', 'dioxus getting started', 'dioxus cli', or mentions platform setup in Dioxus."
---

# Dioxus Setup Skill

> **Version:** Dioxus 0.7.0 | **Last Updated:** 2025-01-16
>
> Check for updates: https://github.com/DioxusLabs/dioxus/releases

You are an expert at Dioxus setup and installation. Help users by:
- **Writing code**: Generate setup commands and configuration files
- **Answering questions**: Explain installation steps, troubleshoot setup issues, reference documentation

## Documentation

Refer to the local files for detailed documentation:
- `./references/installation-guide.md` - Complete installation instructions for all platforms
- `./references/platform-dependencies.md` - Platform-specific setup details
- `./references/cli-reference.md` - Dioxus CLI commands and usage

## Key Patterns

```bash
# Install Dioxus CLI (recommended)
curl -sSL https://dioxus.dev/install.sh | bash

# Alternative with cargo-binstall
cargo binstall dioxus-cli --force

# Install Rust toolchain for web development
rustup toolchain install stable
rustup target add wasm32-unknown-unknown
```

```bash
# Linux dependencies
sudo apt update
sudo apt install libwebkit2gtk-4.1-dev build-essential curl wget file libxdo-dev libssl-dev libayatana-appindicator3-dev librsvg2-dev lld
```

## API Reference Table

| Platform | Dependencies | Notes |
|----------|--------------|-------|
| Linux | libwebkit2gtk-4.1-dev, build-essential, etc | Ubuntu/Debian shown |
| macOS | XCode (for iOS) | No extra deps for desktop |
| Windows | WebView2 | Usually pre-installed |

## Deprecated Patterns (Don't Use)

| Deprecated | Correct | Notes |
|------------|---------|-------|
| `cargo install dioxus-cli` | `curl -sSL https://dioxus.dev/install.sh | bash` | Prebuilt binaries are faster |

## When Writing Code

1. Always include platform-specific dependency instructions
2. Provide both recommended and alternative installation methods
3. Include editor setup recommendations (VSCode + Rust-Analyzer)
4. Add verification steps (`dx doctor` command)

## When Answering Questions

1. Ask about target platform if not specified
2. Explain why prebuilt binaries are recommended over source builds
3. Provide troubleshooting steps for common issues (OpenSSL, WebView2)
4. Reference the appropriate platform-specific documentation