# RSX Syntax Reference

## Overview

RSX (Rust Syntax Extension) is Dioxus's markup language that combines HTML-like syntax with Rust code. It's designed to look and feel like a blend between HTML and SwiftUI.

## Basic Structure

### The rsx! Macro
All RSX code must be wrapped in the `rsx!` macro:

```rust
rsx! {
    // RSX content goes here
}
```

### Elements and Tags
RSX uses HTML-like element syntax:

```rust
rsx! {
    div { "Hello, World!" }
    h1 { "Title" }
    p { "Paragraph text" }
}
```

### Text Content
Static text is enclosed in quotes:

```rust
rsx! {
    "Static text"
    h1 { "Heading text" }
}
```

### Dynamic Content
Use curly braces for Rust expressions:

```rust
rsx! {
    "Hello, {name}!"
    h1 { "Count: {count}" }
    p { "Result: {2 + 2}" }
}
```

## Attributes

### Basic Attributes
```rust
rsx! {
    div { class: "container", id: "main" }
    input { type: "text", placeholder: "Enter name" }
}
```

### Dynamic Attributes
```rust
rsx! {
    div { class: if is_active { "active" } else { "inactive" } }
    button { disabled: is_disabled, "Submit" }
}
```

### Style Attribute
```rust
rsx! {
    div { style: "color: red; font-size: 16px;", "Styled text" }
}
```

### Boolean Attributes
```rust
rsx! {
    input { type: "checkbox", checked: true }
    button { disabled: false, "Enabled button" }
}
```

## Event Handlers

### Basic Events
```rust
rsx! {
    button { onclick: move |_| count += 1, "Click me" }
    input { oninput: move |e| text = e.value(), "Type here" }
}
```

### Common Events
- `onclick` - Click events
- `oninput` - Input field changes
- `onsubmit` - Form submission
- `onmouseover` - Mouse hover
- `onkeydown` - Keyboard events

## Children and Nesting

### Single Child
```rust
rsx! {
    div {
        "Only child"
    }
}
```

### Multiple Children
```rust
rsx! {
    div {
        h1 { "Title" }
        p { "Paragraph" }
        "Text node"
    }
}
```

### Fragments (Multiple Roots)
```rust
rsx! {
    h1 { "Title" }
    p { "Content" }
    // No wrapper element needed
}
```

## Components

### Using Components
```rust
rsx! {
    Header { title: "My App" }
    Counter { initial: 10 }
    CustomButton { text: "Click me", onclick: handler }
}
```

### Component Props
Props are passed as attributes:

```rust
rsx! {
    MyComponent {
        string_prop: "value",
        number_prop: 42,
        optional_prop: some_value,
        children: Children::new(rsx! { "Child content" })
    }
}
```

## Special Syntax

### If-Else Rendering
```rust
rsx! {
    if is_logged_in {
        div { "Welcome back!" }
    } else {
        div { "Please log in" }
    }
}
```

### Loop Rendering
```rust
rsx! {
    ul {
        for item in items {
            li { "{item}" }
        }
    }
}
```

### Match Expressions
```rust
rsx! {
    div {
        match status {
            Status::Loading => "Loading...",
            Status::Success => "Complete!",
            Status::Error => "Something went wrong"
        }
    }
}
```

## Comments

RSX supports Rust-style comments:

```rust
rsx! {
    // This is a comment
    div {
        "Content" /* inline comment */
    }
}
```

## Whitespace and Formatting

### Automatic Whitespace Handling
RSX automatically handles whitespace between elements:

```rust
rsx! {
    "Hello"  // These will have proper spacing
    "World"
}
```

### Manual Whitespace
Use `{" "}` for explicit spaces:

```rust
rsx! {
    "Hello"
    {" "}
    "World"
}
```

## Advanced Patterns

### Conditional Attributes
```rust
rsx! {
    div {
        class: "base-class",
        class: if condition { "conditional-class" },
        "Content"
    }
}
```

### Dynamic Tag Names
```rust
rsx! {
    // Tag names must be static at compile time
    div { "Content" }
}
```

### Key for Lists
When rendering lists, provide keys for efficient updates:

```rust
rsx! {
    for (index, item) in items.iter().enumerate() {
        div { key: "{index}", "{item}" }
    }
}
```

## RSX Compilation

RSX is compiled to efficient Rust code at compile time:

```rust
// This RSX:
rsx! { div { "Hello {name}" } }

// Becomes something like:
static TEMPLATE: Template = Template {
    nodes: [ElementNode { tag: div, children: [TextNode { contents: DynamicText(0) }] }]
};
TEMPLATE.render([format!("Hello {}", name)])
```

## Best Practices

1. **Keep components small** - Split complex UI into smaller components
2. **Use descriptive class names** - Helps with styling and debugging
3. **Leverage Rust's type system** - Use proper types for props
4. **Minimize complex logic in RSX** - Move calculations outside when possible
5. **Use fragments** - Avoid unnecessary wrapper elements

## Common Pitfalls

1. **Missing quotes** - Text content must be in quotes
2. **Incorrect event handlers** - Events expect closures
3. **Capitalization** - Tag names must be lowercase
4. **Missing commas** - Attributes must be separated by commas