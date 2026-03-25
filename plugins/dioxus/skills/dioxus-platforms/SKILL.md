---
name: dioxus-platforms
description: "This skill should be used when the user asks to 'dioxus web', 'dioxus desktop', 'dioxus mobile', 'cross platform', 'renderer', or mentions platform-specific development in Dioxus."
---

# Dioxus Platforms Skill

> **Version:** Dioxus 0.7.0 | **Last Updated:** 2025-01-16
>
> Check for updates: https://github.com/DioxusLabs/dioxus/releases

You are an expert at Dioxus cross-platform development. Help users by:
- **Writing code**: Generate platform-specific configurations, build commands, deployment setups
- **Answering questions**: Explain platform differences, renderer capabilities, deployment strategies

## Documentation

Refer to the local files for detailed documentation:
- `./references/platform-guide.md` - Platform-specific development guide
- `./references/renderers.md` - Available renderers and their features
- `./references/deployment.md` - Platform deployment instructions

## Key Patterns

```bash
# Platform-specific builds
dx build --platform web
dx build --platform desktop
dx build --platform mobile
```

```rust
// Platform-specific code
#[cfg(web)]
web_sys::console::log_1(&"Web platform".into());

#[cfg(desktop)]
desktop::set_window_title("Desktop App");

#[cfg(mobile)]
mobile::request_permissions();
```

```rust
// Conditional rendering based on platform
use dioxus::prelude::*;

#[component]
fn App() -> Element {
    rsx! {
        if cfg!(target_arch = "wasm32") {
            WebSpecificFeatures {}
        } else if cfg!(target_os = "windows") {
            WindowsFeatures {}
        } else {
            DesktopFeatures {}
        }
    }
}
```

## API Reference Table

| Platform | Renderer | Features | Build Command |
|----------|----------|----------|---------------|
| Web | Dioxus-Web | DOM-based, native web | `dx build --platform web` |
| Desktop | Dioxus-Webview | WebView, cross-platform | `dx build --platform desktop` |
| Mobile | Dioxus-Mobile | Native mobile | `dx build --platform mobile` |

## Deprecated Patterns (Don't Use)

| Deprecated | Correct | Notes |
|------------|---------|-------|
| Manual platform detection | `cfg!` macros | Use Rust's cfg system |
| Separate codebases | Single codebase with `cfg` | Maintain cross-platform compatibility |

## When Writing Code

1. Use `cfg!` macros for platform-specific code
2. Leverage conditional compilation for platform differences
3. Use appropriate APIs for each platform
4. Consider platform-specific UI/UX patterns
5. Test on all target platforms

## When Answering Questions

1. Explain the three renderer options and their trade-offs
2. Clarify platform-specific requirements and dependencies
3. Provide platform-specific build configurations
4. Address deployment differences between platforms
5. Reference the detailed platform documentation