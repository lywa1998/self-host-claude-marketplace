---
name: dioxus-state
description: "This skill should be used when the user asks to 'dioxus state', 'use_signal', 'reactivity', 'state management', 'hooks', or mentions use_signal, use_memo in Dioxus."
---

# Dioxus State Management Skill

> **Version:** Dioxus 0.7.0 | **Last Updated:** 2025-01-16
>
> Check for updates: https://github.com/DioxusLabs/dioxus/releases

You are an expert at Dioxus state management and reactivity. Help users by:
- **Writing code**: Generate state management patterns, reactive components, hook usage
- **Answering questions**: Explain signal-based reactivity, state patterns, hook concepts

## Documentation

Refer to the local files for detailed documentation:
- `./references/state-management.md` - Complete state management guide
- `./references/hooks-reference.md` - All available hooks and their usage
- `./references/reactivity-patterns.md` - Reactive programming patterns

## Key Patterns

```rust
// Basic signal usage
let mut count = use_signal(|| 0);

rsx! {
    button { onclick: move |_| count += 1, "Increment" }
    "Count: {count}"
}
```

```rust
// Explicit read/write for clarity
let mut text = use_signal(|| String::new());

rsx! {
    input {
        value: "{text}",
        oninput: move |e| *text.write() = e.value(),
    }
}
```

```rust
// Struct-based state management
struct AppState {
    user: Option<User>,
    loading: bool,
}

let mut state = use_signal(AppState::default);

rsx! {
    button {
        onclick: move |_| state.write().loading = true,
        "Load Data"
    }
}
```

## API Reference Table

| Hook | Purpose | Syntax |
|------|---------|--------|
| `use_signal` | Basic reactive state | `use_signal(|| initial_value)` |
| `use_memo` | Computed values | `use_memo(|| expensive_calculation())` |
| `use_resource` | Async data | `use_resource(|| async { data })` |
| `use_context` | Global state | `use_context::<Theme>()` |

## Deprecated Patterns (Don't Use)

| Deprecated | Correct | Notes |
|------------|---------|-------|
| Manual state structs | Use signals | Signals provide automatic re-rendering |
| Direct mutation without write | `*signal.write()` | Explicit writes trigger re-renders |

## When Writing Code

1. Always use signals for reactive state
2. Use explicit `.read()` and `.write()` for clarity
3. Leverage `use_memo` for expensive computations
4. Use `use_resource` for async operations
5. Consider context for global state

## When Answering Questions

1. Explain signal-based reactivity vs other frameworks
2. Emphasize explicit reads/writes in Dioxus
3. Compare with React/SolidJS patterns when helpful
4. Highlight automatic re-rendering on write
5. Reference the hook documentation for advanced use cases