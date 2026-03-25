# State Management in Dioxus

## Understanding State Management

State management in Dioxus refers to the act of:
1. **Initializing data** for the UI
2. **Handling events** from the user
3. **Updating the data** and re-rendering the UI

## Signal-Based Reactivity

Dioxus uses signal-based reactivity inspired by React, SolidJS, and Svelte. Unlike SolidJS, reads and writes of values are explicit in Dioxus.

### Core Concepts

- **Signals**: Reactive containers for values
- **Explicit reads**: Access values with `.read()` or implicit in templates
- **Explicit writes**: Update values with `.write()` or `*signal.write() = value`
- **Automatic re-rendering**: Component re-renders when signals are written to

## Basic Signal Usage

### Creating Signals
```rust
use dioxus::prelude::*;

#[component]
fn Counter() -> Element {
    // Create a signal with initial value
    let mut count = use_signal(|| 0);

    rsx! {
        h1 { "Count: {count}" }
        button { onclick: move |_| count += 1, "Increment" }
        button { onclick: move |_| count -= 1, "Decrement" }
    }
}
```

### Reading and Writing Signals
```rust
#[component]
fn TextEditor() -> Element {
    let mut text = use_signal(|| "Hello, World!".to_string());

    rsx! {
        input {
            value: "{text}",
            oninput: move |e| {
                // Explicit write
                *text.write() = e.value();
            },
        }
        p { "You typed: {text}" }
    }
}
```

### Signal Methods
```rust
let mut signal = use_signal(|| 42);

// Read value
let value = *signal.read();

// Write value
*signal.write() = 100;

// Set value (alternative)
signal.set(100);

// Modify value in place
*signal.write() += 1;

// Take value (replace with default)
let old_value = signal.take();

// Replace with new value, return old
let old_value = signal.replace(200);
```

## Advanced State Patterns

### Struct-Based State
```rust
#[derive(Clone, Default)]
struct AppState {
    user: Option<User>,
    loading: bool,
    error: Option<String>,
}

#[component]
fn UserProfile() -> Element {
    let mut state = use_signal(AppState::default);

    rsx! {
        if state.read().loading {
            div { "Loading..." }
        } else if let Some(user) = &state.read().user {
            div { "Welcome, {user.name}!" }
        } else {
            button {
                onclick: move |_| load_user(state),
                "Load User"
            }
        }
    }
}

fn load_user(mut state: Signal<AppState>) {
    state.write().loading = true;

    // Simulate async operation
    spawn(async move {
        // In real app, this would be an API call
        tokio::time::sleep(std::time::Duration::from_secs(1)).await;

        state.write().loading = false;
        state.write().user = Some(User {
            name: "John Doe".to_string(),
        });
    });
}
```

### Multiple Related Signals
```rust
#[component]
fn Form() -> Element {
    let mut name = use_signal(|| String::new());
    let mut email = use_signal(|| String::new());
    let mut is_valid = use_signal(|| false);

    // Validate form whenever inputs change
    use_effect(move || {
        let name_valid = !name.read().is_empty();
        let email_valid = email.read().contains('@');
        is_valid.set(name_valid && email_valid);
    });

    rsx! {
        input {
            placeholder: "Name",
            value: "{name}",
            oninput: move |e| *name.write() = e.value(),
        }
        input {
            placeholder: "Email",
            value: "{email}",
            oninput: move |e| *email.write() = e.value(),
        }
        button {
            disabled: !*is_valid.read(),
            onclick: move |_| submit_form(name, email),
            "Submit"
        }
    }
}
```

## Computed Values with Memo

### Basic Memo Usage
```rust
#[component]
fn ShoppingCart() -> Element {
    let mut items = use_signal(|| vec![
        Product { name: "Apple".to_string(), price: 1.0 },
        Product { name: "Banana".to_string(), price: 0.5 },
    ]);

    // Computed total that updates when items change
    let total = use_memo(move || {
        items.read().iter().map(|p| p.price).sum::<f64>()
    });

    rsx! {
        ul {
            for (index, item) in items.read().iter().enumerate() {
                li { "{item.name}: ${item.price}" }
            }
        }
        h3 { "Total: ${total}" }
    }
}
```

### Expensive Computations
```rust
#[component]
fn DataProcessor() -> Element {
    let mut raw_data = use_signal(|| vec![1, 2, 3, 4, 5]);

    // Expensive computation that only re-runs when raw_data changes
    let processed_data = use_memo(move || {
        println!("Running expensive computation...");
        raw_data.read()
            .iter()
            .map(|x| x * x)
            .filter(|x| x % 2 == 0)
            .collect::<Vec<_>>()
    });

    rsx! {
        button {
            onclick: move |_| raw_data.write().push(6),
            "Add Number"
        }
        div { "Processed: {processed_data:?}" }
    }
}
```

## Async State with Resources

### Basic Resource Usage
```rust
#[component]
fn DataLoader() -> Element {
    let data = use_resource(|| async {
        // Simulate API call
        tokio::time::sleep(std::time::Duration::from_secs(2)).await;
        Ok("Loaded data!".to_string())
    });

    rsx! {
        match data.read().as_ref() {
            Some(Ok(content)) => div { "Success: {content}" },
            Some(Err(e)) => div { "Error: {e}" },
            None => div { "Loading..." }
        }
    }
}
```

### Resource with Dependencies
```rust
#[component]
fn UserLoader(user_id: String) -> Element {
    let user = use_resource(move || async move {
        fetch_user(&user_id).await
    });

    rsx! {
        match user.read().as_ref() {
            Some(Ok(user)) => div { "User: {user.name}" },
            Some(Err(e)) => div { "Failed to load user: {e}" },
            None => div { "Loading user..." }
        }
    }
}
```

### Manual Resource Management
```rust
#[component]
fn RefreshableData() -> Element {
    let mut refresh_count = use_signal(|| 0);

    let data = use_resource(move || async move {
        let count = *refresh_count.read();
        fetch_data_with_version(count).await
    });

    rsx! {
        button {
            onclick: move |_| refresh_count += 1,
            "Refresh"
        }
        // Render data...
    }
}
```

## Global State with Context

### Providing Context
```rust
#[derive(Clone, Default)]
struct Theme {
    primary_color: String,
    secondary_color: String,
}

#[component]
fn App() -> Element {
    let theme = Theme::default();

    rsx! {
        ThemeProvider { theme: theme,
            Header {}
            Main {}
            Footer {}
        }
    }
}

#[component]
fn ThemeProvider(theme: Theme, children: Element) -> Element {
    use_context_provider(|| theme);

    rsx! {
        {children}
    }
}
```

### Using Context
```rust
#[component]
fn Header() -> Element {
    let theme: Signal<Theme> = use_context();

    rsx! {
        header {
            style: "background-color: {}; color: white;",
            theme.read().primary_color,
            "Header"
        }
    }
}
```

### Context with Updates
```rust
#[component]
fn ThemeToggle() -> Element {
    let mut theme: Signal<Theme> = use_context();
    let mut is_dark = use_signal(|| false);

    rsx! {
        button {
            onclick: move |_| {
                *is_dark.write() = !*is_dark.read();
                if *is_dark.read() {
                    theme.write().primary_color = "#1a1a1a".to_string();
                } else {
                    theme.write().primary_color = "#ffffff".to_string();
                }
            },
            "Toggle Theme"
        }
    }
}
```

## State Persistence

### Local Storage Integration
```rust
#[component]
fn PersistentCounter() -> Element {
    let mut count = use_signal(|| {
        // Load from localStorage on initialization
        localStorage()
            .get_item("counter")
            .ok()
            .and_then(|s| s.parse().ok())
            .unwrap_or(0)
    });

    // Save to localStorage whenever count changes
    use_effect(move || {
        let count = *count.read();
        spawn(async move {
            let _ = localStorage().set_item("counter", &count.to_string());
        });
    });

    rsx! {
        h1 { "Count: {count}" }
        button { onclick: move |_| count += 1, "Increment" }
    }
}
```

## Error Handling in State

### Error State Management
```rust
#[derive(Clone)]
struct State<T> {
    data: Option<T>,
    loading: bool,
    error: Option<String>,
}

impl<T> Default for State<T> {
    fn default() -> Self {
        State {
            data: None,
            loading: false,
            error: None,
        }
    }
}

#[component]
fn RobustDataLoader() -> Element {
    let mut state = use_signal(State::<String>::default);

    let load_data = move |_| {
        state.write().loading = true;
        state.write().error = None;

        spawn(async move {
            match fetch_data().await {
                Ok(data) => {
                    state.write().data = Some(data);
                    state.write().loading = false;
                }
                Err(e) => {
                    state.write().error = Some(e.to_string());
                    state.write().loading = false;
                }
            }
        });
    };

    rsx! {
        button { onclick: load_data, "Load Data" }

        match (state.read().loading, &state.read().error, &state.read().data) {
            (true, _, _) => div { "Loading..." },
            (_, Some(error), _) => div { "Error: {error}" },
            (_, _, Some(data)) => div { "Data: {data}" },
            _ => div { "Click to load data" }
        }
    }
}
```

## Best Practices

1. **Keep state close to where it's used** - Avoid unnecessary prop drilling
2. **Use appropriate state tools** - Signals for local state, context for global state
3. **Minimize re-renders** - Use `use_memo` for expensive computations
4. **Handle loading and error states** - Provide good UX for async operations
5. **Type safety** - Leverage Rust's type system for state validation
6. **Immutable patterns** - Prefer immutable updates when possible
7. **Separate concerns** - Keep UI logic separate from business logic