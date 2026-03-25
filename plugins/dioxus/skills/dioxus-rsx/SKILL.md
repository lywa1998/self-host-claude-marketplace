---
name: dioxus-rsx
description: "This skill should be used when the user asks to 'rsx syntax', 'dioxus components', 'html in rust', 'rsx macro', 'dioxus ui', or mentions creating components in Dioxus."
---

# Dioxus RSX Skill

> **Version:** Dioxus 0.7.0 | **Last Updated:** 2025-01-16
>
> Check for updates: https://github.com/DioxusLabs/dioxus/releases

You are an expert at Dioxus RSX and component development. Help users by:
- **Writing code**: Generate RSX components, element trees, and UI structures
- **Answering questions**: Explain RSX syntax, component patterns, HTML/CSS integration

## Documentation

Refer to the local files for detailed documentation:
- `./references/rsx-syntax.md` - Complete RSX syntax reference
- `./references/component-patterns.md` - Component creation patterns
- `./references/html-css-integration.md` - HTML and CSS usage in Dioxus

## Key Patterns

```rust
// Basic RSX structure
rsx! {
    h1 { "Welcome to Dioxus!" }
    p { class: "main-content", "Hello, {name}" }
    button { onclick: move |_| count += 1, "Click me" }
}
```

```rust
// Component definition
#[component]
fn Counter(initial: i32) -> Element {
    let mut count = use_signal(|| initial);

    rsx! {
        div { class: "counter",
            h2 { "Count: {count}" }
            button { onclick: move |_| count += 1, "Increment" }
        }
    }
}
```

```rust
// Dynamic content and attributes
rsx! {
    div {
        class: if is_active { "active" } else { "inactive" },
        style: "color: {color};",
        "Content: {content}"
    }
}
```

## API Reference Table

| Element | Syntax | Description |
|---------|--------|-------------|
| Text | `"Hello"` | Static text content |
| Dynamic | `{variable}` | Variable interpolation |
| Attribute | `class: "value"` | HTML attribute |
| Event | `onclick: handler` | Event handler |
| Component | `Component { prop: value }` | Component instance |

## Deprecated Patterns (Don't Use)

| Deprecated | Correct | Notes |
|------------|---------|-------|
| Manual string concat | `"Hello {name}"` | Use interpolation |
| Separate CSS files | Inline styles or CSS modules | Better performance |

## When Writing Code

1. Always use `rsx!` macro for UI elements
2. Follow HTML-like syntax for familiarity
3. Use proper component structure with `#[component]`
4. Include proper event handling with closures
5. Leverage Rust's type system for props

## When Answering Questions

1. Explain RSX as a blend of HTML and Rust
2. Emphasize that RSX compiles to optimized Rust code
3. Highlight cross-platform compatibility
4. Reference the HTML/CSS integration documentation
5. Provide both simple and complex component examples