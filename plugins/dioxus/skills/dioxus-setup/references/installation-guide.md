# Dioxus Installation Guide

## System Requirements

- Rust 1.70+ (installed via rustup)
- Platform-specific dependencies (see below)
- Code editor (VSCode recommended)

## Step 1: Install Rust

```bash
# Install Rust via rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Add wasm32 target for web development
rustup target add wasm32-unknown-unknown
```

## Step 2: Install Dioxus CLI

### Recommended Method (Prebuilt Binaries)
```bash
curl -sSL https://dioxus.dev/install.sh | bash
```

### Alternative Methods

#### Using cargo-binstall
```bash
cargo install cargo-binstall
cargo binstall dioxus-cli --force
```

#### From Source (Not Recommended)
```bash
cargo install dioxus-cli
```
*Note: This can take 10+ minutes and requires many dependencies*

## Step 3: Editor Setup

### VSCode (Recommended)
1. Install VSCode
2. Install Rust-Analyzer extension
3. Install Dioxus extension (optional but recommended)

### Other Editors
All editors supporting Rust-Analyzer LSP will work:
- Zed
- Emacs
- Vim/Neovim

## Step 4: Verify Installation

```bash
# Check Dioxus CLI
dx --version

# Check system setup
dx doctor
```

## Step 5: Create First Project

```bash
# Create new project
dx new my-app

# Navigate to project
cd my-app

# Start development server
dx serve
```

## Troubleshooting

### OpenSSL Issues
Install OpenSSL development libraries:
- Ubuntu: `sudo apt install libssl-dev`
- macOS: Usually included with XCode
- Windows: Use vcpkg or chocolatey

### Permission Issues
Make sure the installation directory is in your PATH and has execute permissions.

### WebView2 Issues (Windows)
Download and install WebView2 from Microsoft's website if Edge is not installed.