# Reactive Programming Patterns in Dioxus

## Signal Patterns

### Basic Signal Pattern
The fundamental pattern for reactive state management:

```rust
#[component]
fn Counter() -> Element {
    let mut count = use_signal(|| 0);

    rsx! {
        h1 { "Count: {count}" }
        button { onclick: move |_| count += 1, "Increment" }
        button { onclick: move |_| count -= 1, "Decrement" }
    }
}
```

### Derived State Pattern
Create computed values that automatically update when dependencies change:

```rust
#[component]
fn ShoppingCart() -> Element {
    let mut items = use_signal(|| vec![
        Product { name: "Apple".to_string(), price: 1.0 },
        Product { name: "Banana".to_string(), price: 0.5 },
    ]);

    // Derived state
    let total = use_memo(move || {
        items.read().iter().map(|p| p.price).sum::<f64>()
    });

    let item_count = use_memo(move || {
        items.read().len()
    });

    rsx! {
        div { "Items: {item_count}" }
        div { "Total: ${total}" }
        ul {
            for (index, item) in items.read().iter().enumerate() {
                li {
                    "{item.name}: ${item.price} "
                    button {
                        onclick: move |_| {
                            items.write().remove(index);
                        },
                        "Remove"
                    }
                }
            }
        }
    }
}
```

### State Grouping Pattern
Group related state into a single signal:

```rust
#[derive(Clone, Default)]
struct FormState {
    username: String,
    email: String,
    password: String,
    is_valid: bool,
    errors: Vec<String>,
}

#[component]
fn LoginForm() -> Element {
    let mut form = use_signal(FormState::default);

    // Validate form whenever fields change
    let is_valid = use_memo(move || {
        let form = form.read();
        !form.username.is_empty()
            && form.email.contains('@')
            && form.password.len() >= 8
    });

    rsx! {
        input {
            placeholder: "Username",
            value: "{form.read().username}",
            oninput: move |e| form.write().username = e.value(),
        }
        input {
            placeholder: "Email",
            value: "{form.read().email}",
            oninput: move |e| form.write().email = e.value(),
        }
        input {
            type: "password",
            placeholder: "Password",
            value: "{form.read().password}",
            oninput: move |e| form.write().password = e.value(),
        }
        button {
            disabled: !*is_valid.read(),
            onclick: move |_| submit_form(form),
            "Submit"
        }
    }
}
```

## Async Patterns

### Resource Pattern
Handle async operations with built-in loading and error states:

```rust
#[component]
fn UserProfile(user_id: String) -> Element {
    let user = use_resource(move || async move {
        fetch_user(&user_id).await
    });

    rsx! {
        match user.read().as_ref() {
            Some(Ok(user)) => rsx! {
                div { class: "profile",
                    img { src: "{user.avatar_url}", alt: "{user.name}" }
                    h2 { "{user.name}" }
                    p { "{user.bio}" }
                }
            },
            Some(Err(e)) => rsx! {
                div { class: "error", "Failed to load user: {e}" }
            },
            None => rsx! {
                div { class: "loading", "Loading user profile..." }
            }
        }
    }
}
```

### Polling Pattern
Periodically refresh data:

```rust
#[component]
fn LiveScore() -> Element {
    let mut score = use_signal(|| 0);
    let mut last_update = use_signal(|| SystemTime::now());

    use_effect(move || {
        let mut score = score.clone();
        let mut last_update = last_update.clone();

        spawn(async move {
            let mut interval = tokio::time::interval(Duration::from_secs(5));

            loop {
                interval.tick().await;
                if let Ok(new_score) = fetch_latest_score().await {
                    *score.write() = new_score;
                    *last_update.write() = SystemTime::now();
                }
            }
        })
    });

    rsx! {
        div { class: "score",
            h2 { "Live Score: {score}" }
            p { "Last updated: {last_update}" }
        }
    }
}
```

### Optimistic Updates Pattern
Update UI immediately, then sync with server:

```rust
#[component]
fn TodoList() -> Element {
    let mut todos = use_signal(|| vec![
        Todo { id: 1, text: "Learn Dioxus".to_string(), completed: false },
    ]);

    let toggle_todo = move |id: u32| {
        // Optimistic update
        if let Some(todo) = todos.write().iter_mut().find(|t| t.id == id) {
            todo.completed = !todo.completed;
        }

        // Sync with server
        let todos = todos.clone();
        spawn(async move {
            if let Err(e) = update_todo_on_server(id, !todo.completed).await {
                // Revert on error
                if let Some(todo) = todos.write().iter_mut().find(|t| t.id == id) {
                    todo.completed = !todo.completed;
                }
                // Show error message
            }
        });
    };

    rsx! {
        ul {
            for todo in todos.read().iter() {
                li {
                    input {
                        type: "checkbox",
                        checked: todo.completed,
                        onchange: move |_| toggle_todo(todo.id),
                    }
                    span {
                        style: if todo.completed { "text-decoration: line-through;" } else { "" },
                        "{todo.text}"
                    }
                }
            }
        }
    }
}
```

## Context Patterns

### Theme Context Pattern
Global theme management:

```rust
#[derive(Clone)]
struct Theme {
    primary: String,
    secondary: String,
    background: String,
    text: String,
}

impl Default for Theme {
    fn default() -> Self {
        Theme {
            primary: "#007bff".to_string(),
            secondary: "#6c757d".to_string(),
            background: "#ffffff".to_string(),
            text: "#212529".to_string(),
        }
    }
}

#[component]
fn ThemeProvider(children: Element) -> Element {
    let mut theme = use_signal(Theme::default);

    // Provide theme context to all children
    use_context_provider(|| theme.clone());

    rsx! {
        div {
            style: "background-color: {}; color: {}; min-height: 100vh;",
            theme.read().background,
            theme.read().text,
            {children}
        }
    }
}

#[component]
fn ThemedButton() -> Element {
    let theme: Signal<Theme> = use_context();

    rsx! {
        button {
            style: "background-color: {}; color: {}; border: 2px solid {}; padding: 8px 16px; border-radius: 4px;",
            theme.read().primary,
            theme.read().background,
            theme.read().primary,
            "Themed Button"
        }
    }
}
```

### Authentication Context Pattern
Global authentication state:

```rust
#[derive(Clone, Default)]
struct AuthState {
    user: Option<User>,
    is_loading: bool,
    error: Option<String>,
}

#[component]
fn AuthProvider(children: Element) -> Element {
    let mut auth = use_signal(AuthState::default);

    // Check authentication on mount
    use_effect(move || {
        let mut auth = auth.clone();
        spawn(async move {
            auth.write().is_loading = true;
            match check_current_session().await {
                Ok(user) => {
                    auth.write().user = Some(user);
                    auth.write().error = None;
                }
                Err(e) => {
                    auth.write().error = Some(e.to_string());
                }
                auth.write().is_loading = false;
            }
        });
    });

    use_context_provider(|| auth.clone());

    rsx! { {children} }
}

#[component]
fn ProtectedRoute() -> Element {
    let auth: Signal<AuthState> = use_context();

    rsx! {
        match (auth.read().is_loading, &auth.read().user, &auth.read().error) {
            (true, _, _) => rsx! { div { "Checking authentication..." } },
            (_, Some(user), _) => rsx! {
                div { "Welcome, {user.name}!" }
            },
            (_, _, Some(error)) => rsx! {
                div { "Authentication error: {error}" }
            },
            _ => rsx! {
                div { "Please log in" }
            }
        }
    }
}
```

## Performance Patterns

### Memoization Pattern
Optimize expensive computations:

```rust
#[component]
fn ExpensiveList() -> Element {
    let mut items = use_signal(|| (0..1000).collect::<Vec<_>>());
    let mut filter = use_signal(|| String::new());

    // Memoized expensive computation
    let filtered_items = use_memo(move || {
        let filter = filter.read().to_lowercase();
        items.read()
            .iter()
            .filter(|&&item| item.to_string().contains(&filter))
            .cloned()
            .collect::<Vec<_>>()
    });

    // Memoized chunking for virtual scrolling
    let chunks = use_memo(move || {
        filtered_items.read()
            .chunks(50)
            .map(|chunk| chunk.to_vec())
            .collect::<Vec<_>>()
    });

    rsx! {
        input {
            placeholder: "Filter items...",
            value: "{filter}",
            oninput: move |e| *filter.write() = e.value(),
        }
        div {
            style: "height: 400px; overflow-y: auto;",
            for (index, chunk) in chunks.read().iter().enumerate() {
                div { key: "{index}",
                    for item in chunk {
                        div { "Item: {item}" }
                    }
                }
            }
        }
    }
}
```

### Callback Stabilization Pattern
Prevent unnecessary re-renders in child components:

```rust
#[component]
fn ParentComponent() -> Element {
    let mut count = use_signal(|| 0);

    // Stable callback that doesn't change on re-renders
    let on_increment = use_callback(move |_| {
        count += 1;
    });

    let on_decrement = use_callback(move |_| {
        count -= 1;
    });

    rsx! {
        h1 { "Count: {count}" }
        OptimizedButton {
            text: "Increment",
            onclick: on_increment
        }
        OptimizedButton {
            text: "Decrement",
            onclick: on_decrement
        }
    }
}

#[derive(Props, Clone)]
struct OptimizedButtonProps {
    text: String,
    onclick: Callback<()>,
}

#[component]
fn OptimizedButton(props: OptimizedButtonProps) -> Element {
    rsx! {
        button {
            onclick: move |_| props.onclick.call(()),
            "{props.text}"
        }
    }
}
```

## State Synchronization Patterns

### Two-Way Binding Pattern
Synchronize state between multiple components:

```rust
#[component]
fn SyncedInputs() -> Element {
    let mut value = use_signal(|| String::new());

    rsx! {
        input {
            placeholder: "Type here...",
            value: "{value}",
            oninput: move |e| *value.write() = e.value(),
        }
        input {
            placeholder: "Mirrored here...",
            value: "{value}",
            oninput: move |e| *value.write() = e.value(),
        }
        textarea {
            placeholder: "Also mirrored...",
            value: "{value}",
            oninput: move |e| *value.write() = e.value(),
        }
    }
}
```

### State Lifting Pattern
Share state between sibling components:

```rust
#[component]
fn Parent() -> Element {
    let mut shared_value = use_signal(|| String::new());

    rsx! {
        ChildA { value: shared_value.clone() }
        ChildB { value: shared_value.clone() }
        ChildC { value: shared_value.clone() }
    }
}

#[derive(Props, Clone)]
struct ChildProps {
    value: Signal<String>,
}

#[component]
fn ChildA(props: ChildProps) -> Element {
    rsx! {
        input {
            placeholder: "Child A",
            value: "{props.value}",
            oninput: move |e| *props.value.write() = e.value(),
        }
    }
}

#[component]
fn ChildB(props: ChildProps) -> Element {
    rsx! {
        div { "Child B sees: {props.value}" }
    }
}
```

## Error Handling Patterns

### Error Boundary Pattern
Catch and handle errors in sub-trees:

```rust
#[component]
fn ErrorBoundary(children: Element) -> Element {
    let mut error = use_signal(|| None::<String>);

    rsx! {
        if let Some(err) = error.read() {
            div { class: "error-boundary",
                h2 { "Something went wrong" }
                p { "{err}" }
                button {
                    onclick: move |_| error.set(None),
                    "Try again"
                }
            }
        } else {
            {children}
        }
    }
}

#[component]
fn RiskyComponent() -> Element {
    let mut data = use_signal(|| String::new());

    // Simulate potential error
    let risky_operation = move |_| {
        // This could fail
        if data.read().is_empty() {
            panic!("Data cannot be empty!");
        }
    };

    rsx! {
        input {
            value: "{data}",
            oninput: move |e| *data.write() = e.value(),
        }
        button { onclick: risky_operation, "Risky Operation" }
    }
}
```

## Best Practices

1. **Keep signals close to usage** - Minimize prop drilling
2. **Use appropriate patterns** - Choose the right pattern for the use case
3. **Optimize when necessary** - Profile before optimizing
4. **Handle errors gracefully** - Provide good UX for error states
5. **Consider loading states** - Always show loading indicators for async operations
6. **Use TypeScript-like patterns** - Leverage Rust's type system for safety
7. **Test reactivity** - Ensure updates propagate correctly