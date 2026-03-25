# Dioxus Hooks Reference

## Core Hooks

### use_signal
Creates a reactive signal that triggers re-renders when updated.

```rust
let mut signal = use_signal(|| initial_value);

// Read value
let value = *signal.read();

// Write value
*signal.write() = new_value;

// In RSX, reads are implicit
rsx! { "Value: {signal}" }
```

**Parameters:**
- `initial_fn: Fn() -> T` - Function that returns initial value

**Returns:**
- `Signal<T>` - Reactive signal

**Use Cases:**
- Component state
- Form inputs
- UI state (toggles, selections)

---

### use_memo
Creates a memoized value that only re-computes when dependencies change.

```rust
let memoized = use_memo(|| {
    // Expensive computation
    expensive_calculation(dep1, dep2)
});

// Use the memoized value
rsx! { "Result: {memoized}" }
```

**Parameters:**
- `fn: Fn() -> T` - Function that computes the value

**Returns:**
- `Memo<T>` - Memoized value

**Use Cases:**
- Expensive calculations
- Filtered/transformed data
- Derived state

---

### use_resource
Manages asynchronous operations with loading, error, and success states.

```rust
let resource = use_resource(|| async {
    fetch_data().await
});

match resource.read().as_ref() {
    Some(Ok(data)) => rsx! { "Data: {data}" },
    Some(Err(e)) => rsx! { "Error: {e}" },
    None => rsx! { "Loading..." }
}
```

**Parameters:**
- `fn: Fn() -> Future<Output = T>` - Async function to execute

**Returns:**
- `Resource<T>` - Resource with current state

**Use Cases:**
- API calls
- File I/O operations
- Any async data fetching

---

### use_effect
Runs side effects when dependencies change.

```rust
use_effect(move || {
    // This runs when component mounts and when dependencies change
    println!("Value changed: {}", *signal.read());

    // Cleanup function (optional)
    || {
        println!("Cleaning up...");
    }
});
```

**Parameters:**
- `fn: Fn() -> Option<Fn()>` - Effect function, optionally returns cleanup

**Use Cases:**
- DOM manipulation
- Subscriptions
- Logging
- External integrations

---

### use_context
Accesses context values from parent components.

```rust
let theme: Signal<Theme> = use_context();

// Use the context value
rsx! {
    div { style: "color: {theme.read().primary_color}", "Themed text" }
}
```

**Type Parameters:**
- `T: Clone + 'static` - Context type

**Returns:**
- `T` - Context value

**Use Cases:**
- Global state
- Theme configuration
- User authentication
- Application settings

---

### use_context_provider
Provides context to child components.

```rust
use_context_provider(|| Theme::default());

// Child components can now use use_context::<Theme>()
```

**Parameters:**
- `fn: Fn() -> T` - Function that creates context value

**Use Cases:**
- Theme providers
- State management
- Configuration providers

---

## Advanced Hooks

### use_coroutine
Manages long-running coroutines that can send and receive messages.

```rust
let mut send = use_coroutine(|mut rx| async move {
    while let Some(message) = rx.next().await {
        // Handle message
        process_message(message).await;
    }
});

// Send messages to coroutine
send.send("Hello".to_string());
```

**Parameters:**
- `fn: Fn(UnboundedReceiver<T>) -> Future<Output =()>` - Coroutine handler

**Returns:**
- `UnboundedSender<T>` - Channel to send messages

**Use Cases:**
- WebSockets
- Background processing
- Event streams

---

### use_callback
Returns a stable callback reference that doesn't change on re-renders.

```rust
let callback = use_callback(move |value: i32| {
    println!("Callback called with: {value}");
});

// Use in event handlers
rsx! {
    button { onclick: move |_| callback(42), "Click me" }
}
```

**Parameters:**
- `fn: Fn(T) -> R` - Callback function

**Returns:**
- `Callback<T, R>` - Stable callback reference

**Use Cases:**
- Event handlers
- Optimized child components
- Stable function references

---

## State Management Hooks

### use_reducer
Redux-style state management with actions and reducers.

```rust
#[derive(Clone)]
enum Action {
    Increment,
    Decrement,
    Set(i32),
}

fn reducer(state: i32, action: Action) -> i32 {
    match action {
        Action::Increment => state + 1,
        Action::Decrement => state - 1,
        Action::Set(value) => value,
    }
}

let (state, dispatch) = use_reducer(|| 0, reducer);

// Usage
rsx! {
    button { onclick: move |_| dispatch(Action::Increment), "+" }
    div { "Count: {state}" }
}
```

**Parameters:**
- `initial_fn: Fn() -> T` - Initial state function
- `reducer: Fn(T, A) -> T` - Reducer function

**Returns:**
- `(ReadOnlySignal<T>, Callback<A>)` - State and dispatch function

---

## Lifecycle Hooks

### use_on_mount
Runs code when component mounts.

```rust
use_on_mount(|| {
    println!("Component mounted");
    // One-time setup
});
```

**Parameters:**
- `fn: Fn()` - Mount callback

---

### use_on_unmount
Runs cleanup code when component unmounts.

```rust
use_on_unmount(|| {
    println!("Component unmounting");
    // Cleanup resources
});
```

**Parameters:**
- `fn: Fn()` - Unmount callback

---

## Utility Hooks

### use_root_context
Accesses root-level context that persists across route changes.

```rust
let global_state = use_root_context::<GlobalState>();
```

**Use Cases:**
- Authentication state
- Global user preferences
- Application-wide state

---

### use_atom
Optimized signal for primitive values that minimizes re-renders.

```rust
let count = use_atom(|| 0);

// More efficient than use_signal for primitive values
```

**Use Cases:**
- Counters
- Flags
- Primitive state values

---

## Hook Rules and Best Practices

### Rules of Hooks
1. **Only call hooks at the top level** - Don't call hooks inside loops, conditions, or nested functions
2. **Only call hooks from React functions** - Don't call hooks from regular JavaScript functions
3. **Custom hooks should start with "use_"** - Convention for clarity

### Custom Hooks

```rust
// Custom hook for counter logic
fn use_counter(initial: i32) -> (Signal<i32>, Callback<()>, Callback<()>) {
    let mut count = use_signal(|| initial);

    let increment = use_callback(move |_| {
        count += 1;
    });

    let decrement = use_callback(move |_| {
        count -= 1;
    });

    (count, increment, decrement)
}

// Usage
#[component]
fn Counter() -> Element {
    let (count, increment, decrement) = use_counter(0);

    rsx! {
        button { onclick: decrement, "-" }
        span { "{count}" }
        button { onclick: increment, "+" }
    }
}
```

### Performance Considerations

1. **Use use_memo for expensive computations**
2. **Use use_callback for stable function references**
3. **Minimize dependencies in use_effect**
4. **Use appropriate state management patterns**

### Common Patterns

```rust
// Form state management
fn use_form<T: Default + Clone>() -> (Signal<T>, Callback<T>) {
    let mut form = use_signal(T::default);

    let set_form = use_callback(move |value: T| {
        *form.write() = value;
    });

    (form, set_form)
}

// Toggle state
fn use_toggle(initial: bool) -> (Signal<bool>, Callback<()>) {
    let mut is_toggled = use_signal(|| initial);

    let toggle = use_callback(move |_| {
        is_toggled.toggle();
    });

    (is_toggled, toggle)
}

// Local storage persistence
fn use_persistent_signal<T: Clone + serde::Serialize + serde::de::DeserializeOwned>(
    key: &str,
    initial: T,
) -> Signal<T> {
    let mut signal = use_signal(|| {
        // Load from localStorage
        localStorage()
            .get_item(key)
            .ok()
            .and_then(|s| serde_json::from_str(&s).ok())
            .unwrap_or(initial)
    });

    use_effect(move || {
        let value = signal.read().clone();
        let key = key.to_string();
        spawn(async move {
            if let Ok(s) = serde_json::to_string(&value) {
                let _ = localStorage().set_item(&key, &s);
            }
        });
    });

    signal
}
```

## Hook Dependencies

Hooks automatically track their dependencies. When you use a signal inside a hook, the hook will re-run when that signal changes:

```rust
// This effect will re-run when `count` changes
use_effect(move || {
    println!("Count is now: {}", *count.read());
});

// This memo will re-compute when `data` or `filter` change
let filtered_data = use_memo(move || {
    data.read()
        .iter()
        .filter(|item| item.contains(&*filter.read()))
        .cloned()
        .collect::<Vec<_>>()
});
```