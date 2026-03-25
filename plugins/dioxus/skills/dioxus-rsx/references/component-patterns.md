# Component Patterns in Dioxus

## Component Definition

### Basic Component
```rust
#[component]
fn HelloWorld() -> Element {
    rsx! {
        h1 { "Hello, World!" }
    }
}
```

### Component with Props
```rust
#[component]
fn Greeting(name: String) -> Element {
    rsx! {
        h1 { "Hello, {name}!" }
    }
}
```

### Component with Optional Props
```rust
#[component]
fn UserCard(name: String, email: Option<String>) -> Element {
    rsx! {
        div { class: "user-card",
            h2 { "{name}" }
            if let Some(email) = email {
                p { "{email}" }
            }
        }
    }
}
```

## Component Props Patterns

### Using Structs for Props
```rust
#[derive(Props, Clone)]
struct ButtonProps {
    text: String,
    onclick: EventHandler<MouseEvent>,
    #[props(default)]
    disabled: bool,
    #[props(optional)]
    variant: Option<String>,
}

#[component]
fn Button(props: ButtonProps) -> Element {
    rsx! {
        button {
            class: props.variant.unwrap_or("default".to_string()),
            onclick: props.onclick,
            disabled: props.disabled,
            "{props.text}"
        }
    }
}
```

### Children Prop
```rust
#[component]
fn Card(children: Element) -> Element {
    rsx! {
        div { class: "card",
            {children}
        }
    }
}

// Usage
rsx! {
    Card {
        h2 { "Card Title" }
        p { "Card content" }
    }
}
```

## Composition Patterns

### Wrapper Components
```rust
#[component]
fn Container(children: Element, class: String) -> Element {
    rsx! {
        div { class: "container {class}",
            {children}
        }
    }
}
```

### Layout Components
```rust
#[component]
fn FlexBox(children: Element, direction: String) -> Element {
    rsx! {
        div {
            style: "display: flex; flex-direction: {direction};",
            {children}
        }
    }
}
```

### List Components
```rust
#[component]
fn List<T: Clone + PartialEq>(items: Vec<T>) -> Element
where
    T: std::fmt::Display,
{
    rsx! {
        ul {
            for (index, item) in items.iter().enumerate() {
                li { key: "{index}", "{item}" }
            }
        }
    }
}
```

## Stateful Components

### Counter Component
```rust
#[component]
fn Counter(initial: i32) -> Element {
    let mut count = use_signal(|| initial);

    rsx! {
        div { class: "counter",
            h2 { "Count: {count}" }
            button { onclick: move |_| count += 1, "Increment" }
            button { onclick: move |_| count -= 1, "Decrement" }
            button { onclick: move |_| count.set(initial), "Reset" }
        }
    }
}
```

### Toggle Component
```rust
#[component]
fn Toggle(initial: bool) -> Element {
    let mut is_on = use_signal(|| initial);

    rsx! {
        button {
            class: if *is_on.read() { "toggle-on" } else { "toggle-off" },
            onclick: move |_| is_on.toggle(),
            if *is_on.read() { "ON" } else { "OFF" }
        }
    }
}
```

## Form Components

### Input Field
```rust
#[component]
fn TextField(label: String, value: Signal<String>) -> Element {
    rsx! {
        div { class: "field",
            label { "{label}" }
            input {
                type: "text",
                value: "{value}",
                oninput: move |e| value.set(e.value()),
            }
        }
    }
}
```

### Checkbox
```rust
#[component]
fn Checkbox(label: String, checked: Signal<bool>) -> Element {
    rsx! {
        label {
            input {
                type: "checkbox",
                checked: *checked.read(),
                oninput: move |e| checked.set(e.checked()),
            }
            "{label}"
        }
    }
}
```

## Conditional Rendering Patterns

### Loading States
```rust
#[component]
fn DataLoader() -> Element {
    let data = use_resource(|| async {
        // Simulate API call
        tokio::time::sleep(std::time::Duration::from_secs(1)).await;
        "Loaded data".to_string()
    });

    rsx! {
        match data.read().as_ref() {
            Some(Ok(content)) => div { "Success: {content}" },
            Some(Err(_)) => div { "Error loading data" },
            None => div { "Loading..." }
        }
    }
}
```

### Error Boundaries
```rust
#[component]
fn ErrorBoundary(children: Element) -> Element {
    let mut error = use_signal(|| None::<String>);

    rsx! {
        if let Some(err) = error.read() {
            div { class: "error",
                h2 { "Something went wrong" }
                p { "{err}" }
                button { onclick: move |_| error.set(None), "Try again" }
            }
        } else {
            {children}
        }
    }
}
```

## Higher-Order Components

### With Loading State
```rust
#[component]
fn WithLoading<T: 'static>(
    loading: bool,
    children: Element,
) -> Element {
    rsx! {
        if loading {
            div { class: "loading", "Loading..." }
        } else {
            {children}
        }
    }
}
```

### Conditional Wrapper
```rust
#[component]
fn ConditionalWrap(
    condition: bool,
    wrapper: fn(Element) -> Element,
    children: Element,
) -> Element {
    rsx! {
        if condition {
            wrapper(children)
        } else {
            children
        }
    }
}
```

## Performance Patterns

### Memoized Components
```rust
#[component]
fn ExpensiveComponent(input: String) -> Element {
    let expensive_result = use_memo(|| {
        // Expensive computation
        input.to_uppercase()
    });

    rsx! {
        div { "Result: {expensive_result}" }
    }
}
```

### Lazy Loading
```rust
#[component]
fn LazyComponent() -> Element {
    let mut should_load = use_signal(|| false);

    rsx! {
        button {
            onclick: move |_| should_load.set(true),
            "Load Component"
        }
        if *should_load.read() {
            HeavyComponent {}
        }
    }
}
```

## Reusable Component Library

### Button Variants
```rust
#[derive(Props, Clone)]
struct ButtonProps {
    text: String,
    onclick: EventHandler<MouseEvent>,
    #[props(default)]
    variant: ButtonVariant,
    #[props(default)]
    size: ButtonSize,
}

#[derive(Clone)]
enum ButtonVariant {
    Primary,
    Secondary,
    Danger,
}

impl Default for ButtonVariant {
    fn default() -> Self { ButtonVariant::Primary }
}

#[derive(Clone)]
enum ButtonSize {
    Small,
    Medium,
    Large,
}

impl Default for ButtonSize {
    fn default() -> Self { ButtonSize::Medium }
}

#[component]
fn Button(props: ButtonProps) -> Element {
    let base_classes = "btn";
    let variant_class = match props.variant {
        ButtonVariant::Primary => "btn-primary",
        ButtonVariant::Secondary => "btn-secondary",
        ButtonVariant::Danger => "btn-danger",
    };
    let size_class = match props.size {
        ButtonSize::Small => "btn-small",
        ButtonSize::Medium => "btn-medium",
        ButtonSize::Large => "btn-large",
    };

    rsx! {
        button {
            class: "{base_classes} {variant_class} {size_class}",
            onclick: props.onclick,
            "{props.text}"
        }
    }
}
```

## Best Practices

1. **Single Responsibility** - Each component should have one clear purpose
2. **Composition over Inheritance** - Prefer composing smaller components
3. **Prop Drilling** - Avoid passing props through many levels, use context when needed
4. **Default Props** - Provide sensible defaults for optional props
5. **Type Safety** - Use Rust's type system for prop validation
6. **Documentation** - Document component props and usage patterns
7. **Testing** - Test components independently and in composition