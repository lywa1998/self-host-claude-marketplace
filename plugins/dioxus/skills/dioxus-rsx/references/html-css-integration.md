# HTML and CSS Integration in Dioxus

## HTML Support

### Standard HTML Elements
Dioxus supports all standard HTML5 elements:

```rust
rsx! {
    // Semantic HTML
    header { "Header" }
    nav { "Navigation" }
    main { "Main content" }
    section { "Section" }
    article { "Article" }
    aside { "Sidebar" }
    footer { "Footer" }

    // Text elements
    h1 { "Heading 1" }
    p { "Paragraph" }
    span { "Span" }
    strong { "Bold text" }
    em { "Italic text" }

    // Form elements
    form {
        input { type: "text", placeholder: "Enter text" }
        textarea { placeholder: "Enter message" }
        select {
            option { "Option 1" }
            option { "Option 2" }
        }
        button { type: "submit", "Submit" }
    }

    // Media elements
    img { src: "/image.jpg", alt: "Description" }
    video { controls: true, "Video content" }
    audio { controls: true, "Audio content" }
}
```

### HTML Attributes
All standard HTML attributes are supported:

```rust
rsx! {
    a {
        href: "https://example.com",
        target: "_blank",
        rel: "noopener noreferrer",
        "Link text"
    }

    input {
        type: "email",
        placeholder: "Enter email",
        required: true,
        disabled: false
    }

    div {
        id: "main-content",
        class: "container main",
        role: "main",
        "Content"
    }
}
```

### HTML5 Semantic Elements
```rust
rsx! {
    header {
        nav {
            ul {
                li { a { href: "#home", "Home" } }
                li { a { href: "#about", "About" } }
                li { a { href: "#contact", "Contact" } }
            }
        }
    }

    main {
        article {
            header { h1 { "Article Title" } }
            section { "Article content" }
            footer { "Article footer" }
        }
    }
}
```

## CSS Integration

### Inline Styles
```rust
rsx! {
    div {
        style: "color: red; font-size: 16px; padding: 10px;",
        "Styled text"
    }

    button {
        style: "background-color: blue; color: white; border: none; padding: 8px 16px;",
        "Click me"
    }
}
```

### CSS Classes
```rust
rsx! {
    div { class: "container", "Container content" }
    button { class: "btn btn-primary", "Primary button" }
    div { class: "card shadow-lg", "Card content" }
}
```

### Dynamic Classes
```rust
rsx! {
    div {
        class: if is_active { "active" } else { "inactive" },
        "Conditional class"
    }

    button {
        class: "btn {variant} {size}",
        "Dynamic classes"
    }
}
```

### CSS Modules Approach
```rust
// Define CSS classes as constants
const CSS: &str = r#"
.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
}

.btn {
    padding: 8px 16px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
}

.btn-primary {
    background-color: #007bff;
    color: white;
}
"#;

#[component]
fn StyledComponent() -> Element {
    rsx! {
        style { "{CSS}" }
        div { class: "container",
            button { class: "btn btn-primary", "Styled button" }
        }
    }
}
```

## Responsive Design

### Media Queries in CSS
```rust
const RESPONSIVE_CSS: &str = r#"
.container {
    width: 100%;
    padding: 1rem;
}

@media (min-width: 768px) {
    .container {
        max-width: 750px;
        margin: 0 auto;
    }
}

@media (min-width: 1024px) {
    .container {
        max-width: 1200px;
    }
}
"#;
```

### Responsive Components
```rust
#[component]
fn ResponsiveLayout() -> Element {
    rsx! {
        style { "{RESPONSIVE_CSS}" }
        div { class: "container",
            header { "Header" }
            main { "Main content" }
            footer { "Footer" }
        }
    }
}
```

## CSS Frameworks

### Tailwind CSS Integration
```rust
// Install tailwindcss in your project
// Add to your CSS file or style component

const TAILWIND: &str = r#"
@tailwind base;
@tailwind components;
@tailwind utilities;
"#;

#[component]
fn TailwindComponent() -> Element {
    rsx! {
        style { "{TAILWIND}" }
        div { class: "bg-gray-100 p-4 rounded-lg shadow-md",
            h1 { class: "text-2xl font-bold text-gray-800", "Title" }
            p { class: "text-gray-600 mt-2", "Content" }
            button { class: "bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded",
                "Button"
            }
        }
    }
}
```

### Bootstrap Integration
```rust
const BOOTSTRAP_CSS: &str = r#"
/* Include Bootstrap CSS */
.container {
    @apply container mx-auto px-4;
}

.btn {
    @apply px-4 py-2 rounded;
}

.btn-primary {
    @apply bg-blue-500 text-white;
}
"#;

#[component]
fn BootstrapComponent() -> Element {
    rsx! {
        link {
            rel: "stylesheet",
            href: "https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css"
        }
        div { class: "container",
            div { class: "row",
                div { class: "col-md-6", "Column 1" }
                div { class: "col-md-6", "Column 2" }
            }
        }
    }
}
```

## CSS-in-JS Patterns

### Styled Components Pattern
```rust
#[component]
fn StyledButton(text: String, color: String) -> Element {
    let button_style = format!(
        "background-color: {}; color: white; padding: 8px 16px; border: none; border-radius: 4px;",
        color
    );

    rsx! {
        button { style: "{button_style}", "{text}" }
    }
}
```

### Theme Provider Pattern
```rust
#[derive(Clone)]
struct Theme {
    primary_color: String,
    secondary_color: String,
    background_color: String,
}

impl Default for Theme {
    fn default() -> Self {
        Theme {
            primary_color: "#007bff".to_string(),
            secondary_color: "#6c757d".to_string(),
            background_color: "#ffffff".to_string(),
        }
    }
}

#[component]
fn ThemedButton(text: String, variant: String, theme: Theme) -> Element {
    let (bg_color, text_color) = match variant.as_str() {
        "primary" => (theme.primary_color.clone(), "#ffffff".to_string()),
        "secondary" => (theme.secondary_color.clone(), "#ffffff".to_string()),
        _ => (theme.background_color.clone(), "#000000".to_string()),
    };

    let style = format!(
        "background-color: {}; color: {}; padding: 8px 16px; border: none; border-radius: 4px;",
        bg_color, text_color
    );

    rsx! {
        button { style: "{style}", "{text}" }
    }
}
```

## Animation and Transitions

### CSS Animations
```rust
const ANIMATION_CSS: &str = r#"
@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

@keyframes slideIn {
    from { transform: translateX(-100%); }
    to { transform: translateX(0); }
}

.fade-in {
    animation: fadeIn 0.3s ease-in-out;
}

.slide-in {
    animation: slideIn 0.3s ease-in-out;
}

.transition {
    transition: all 0.2s ease-in-out;
}

.transition:hover {
    transform: scale(1.05);
}
"#;

#[component]
fn AnimatedComponent() -> Element {
    rsx! {
        style { "{ANIMATION_CSS}" }
        div { class: "fade-in",
            "Fade in content"
        }
        div { class: "slide-in transition",
            "Slide in content"
        }
    }
}
```

## Accessibility

### ARIA Attributes
```rust
rsx! {
    button {
        aria_label: "Close dialog",
        aria_pressed: false,
        "×"
    }

    div {
        role: "alert",
        aria_live: "polite",
        "Important message"
    }

    input {
        aria_describedby: "help-text",
        aria_required: true,
    }
    div { id: "help-text", "This field is required" }
}
```

### Semantic HTML for Accessibility
```rust
rsx! {
    header {
        nav { aria_label: "Main navigation",
            ul {
                li { a { href: "#home", "Home" } }
                li { a { href: "#about", "About" } }
            }
        }
    }

    main {
        article {
            header { h1 { "Article Title" } }
            p { "Article content" }
        }
        aside { aria_label: "Sidebar",
            "Sidebar content"
        }
    }
}
```

## Best Practices

1. **Use Semantic HTML** - Choose appropriate HTML elements for meaning
2. **Separate Concerns** - Keep styling separate from logic when possible
3. **Responsive Design** - Design for all screen sizes
4. **Accessibility First** - Include proper ARIA attributes and semantic markup
5. **Performance** - Minimize inline styles, use CSS classes
6. **Consistency** - Use design systems or CSS frameworks for consistency
7. **Maintainability** - Organize CSS logically, use meaningful class names