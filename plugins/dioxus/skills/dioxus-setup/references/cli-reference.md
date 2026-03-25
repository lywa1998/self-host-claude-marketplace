# Dioxus CLI Reference

## Installation Verification

```bash
# Check CLI version
dx --version

# Comprehensive system check
dx doctor

# Get help
dx --help
```

## Project Management

### Create New Project
```bash
# Create new project with default template
dx new my-app

# Create with specific template
dx new my-app --template vanilla

# Create in current directory
dx new .

# Interactive project creation
dx new my-app --interactive
```

### Project Templates
- `vanilla` - Basic Dioxus application
- `fullstack` - Fullstack application with server functions
- `tailwind` - Application with Tailwind CSS
- `router` - Application with routing setup

## Development Commands

### Serve Development Server
```bash
# Start development server
dx serve

# Serve on specific port
dx serve --port 8080

# Open browser automatically
dx serve --open

# Serve for specific platform
dx serve --platform web
dx serve --platform desktop
```

### Build for Production
```bash
# Build for default platform
dx build

# Build for specific platform
dx build --platform web
dx build --platform desktop
dx build --platform mobile

# Build with release optimizations
dx build --release

# Custom build output directory
dx build --output dist
```

## Platform-Specific Commands

### Web Development
```bash
# Build for web
dx build --platform web

# Serve web version
dx serve --platform web

# Bundle for web deployment
dx bundle --platform web
```

### Desktop Development
```bash
# Build desktop application
dx build --platform desktop

# Run desktop application
dx run --platform desktop

# Package for distribution
dx package --platform desktop
```

### Mobile Development
```bash
# Build for iOS
dx build --platform ios

# Build for Android
dx build --platform android

# Run on device/simulator
dx run --platform ios
dx run --platform android
```

## Configuration

### Configuration File
Create `dx.toml` in project root:

```toml
[application]
name = "My App"
default_platform = "web"

[web.app]
title = "My Dioxus App"

[web.watcher]
reload_html = true
watch_path = ["src"]

[application.tools]
# Enable/disable specific tools
```

### Environment Variables
```bash
# Set default platform
export DIOXUS_PLATFORM=web

# Enable verbose logging
export RUST_LOG=debug

# Custom cargo target directory
export CARGO_TARGET_DIR=target
```

## Advanced Commands

### Clean Project
```bash
# Clean build artifacts
dx clean

# Clean specific platform
dx clean --platform web
```

### Check and Update
```bash
# Check for CLI updates
dx check-update

# Update CLI
dx update
```

### Generate Project Files
```bash
# Generate IDE configuration
dx generate ide-config

# Generate documentation
dx doc
```

## Troubleshooting Commands

```bash
# Comprehensive system diagnosis
dx doctor

# Verbose output for debugging
dx serve --verbose

# Check project configuration
dx check-config

# List available templates
dx list-templates
```

## Hot Reloading

The CLI provides automatic hot reloading for:
- Rust source files
- RSX components
- CSS stylesheets
- Asset files

Hot reload is enabled by default in development mode with `dx serve`.

## Integration with Cargo

All `dx` commands wrap Cargo commands. You can also use Cargo directly:

```bash
# Equivalent to dx serve
cargo run

# Equivalent to dx build
cargo build --release

# Add dependencies
cargo add dioxus
cargo add dioxus-web
```

## Plugin System

Dioxus CLI supports plugins for extended functionality:

```bash
# List installed plugins
dx plugin list

# Install plugin
dx plugin install dx-tailwind

# Remove plugin
dx plugin uninstall dx-tailwind
```