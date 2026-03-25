# Platform-Specific Development Guide

## Overview

Dioxus supports three main platforms with different renderers:
- **Web**: Runs directly in browsers using WebAssembly
- **Desktop**: Uses system webviews for native desktop applications
- **Mobile**: Native mobile apps with hybrid rendering

## Web Platform

### Features
- Native DOM rendering
- WebAssembly performance
- Full browser API access
- SEO-friendly
- Progressive Web App (PWA) support

### Setup
```bash
# Add wasm target
rustup target add wasm32-unknown-unknown

# Install web dependencies
cargo add dioxus-web
```

### Configuration
```toml
# Cargo.toml
[dependencies]
dioxus = "0.7"
dioxus-web = "0.7"

[target.'cfg(target_arch = "wasm32")'.dependencies]
web-sys = "0.3"
wasm-bindgen = "0.2"
```

### Web-Specific Code
```rust
#[cfg(target_arch = "wasm32")]
use web_sys::{window, console};

#[cfg(target_arch = "wasm32")]
fn web_specific_setup() {
    console::log_1(&"Web app started".into());

    if let Some(window) = window() {
        let _ = window.document().set_title("My Dioxus Web App");
    }
}

#[component]
fn WebFeatures() -> Element {
    rsx! {
        div {
            h1 { "Web Features" }
            button {
                onclick: move |_| {
                    #[cfg(target_arch = "wasm32")]
                    web_sys::console::log_1(&"Button clicked".into());
                },
                "Log to Console"
            }
            // Web-specific elements
            input { type: "date" }
            input { type: "color" }
            video { controls: true, "Video content" }
        }
    }
}
```

### Browser API Integration
```rust
#[cfg(target_arch = "wasm32")]
use web_sys::{HtmlDocument, Navigator};

#[cfg(target_arch = "wasm32")]
fn browser_api_example() {
    let window = web_sys::window().unwrap();
    let document = window.document().unwrap();
    let navigator = window.navigator();

    // Local storage
    if let Ok(storage) = window.local_storage() {
        if let Some(storage) = storage {
            let _ = storage.set_item("key", "value");
        }
    }

    // Geolocation
    if let Ok(geo) = navigator.geolocation() {
        let _ = geo.get_current_position();
    }
}
```

### PWA Configuration
```rust
// main.rs for web
#[cfg(target_arch = "wasm32")]
fn main() {
    dioxus_web::launch_cfg(
        App,
        dioxus_web::Config::new().rootname("app")
    );
}
```

## Desktop Platform

### Features
- Native window management
- System tray integration
- File system access
- Native menus
- Cross-platform (Windows, macOS, Linux)

### Setup
```bash
# Desktop dependencies are handled automatically
# Platform-specific dependencies:
# Linux: libwebkit2gtk-4.1-dev, etc.
# macOS: No additional deps
# Windows: WebView2 (usually pre-installed)
```

### Configuration
```toml
# Cargo.toml
[dependencies]
dioxus = "0.7"
dioxus-desktop = "0.7"

[target.'cfg(not(target_arch = "wasm32"))'.dependencies]
tokio = { version = "1.0", features = ["full"] }
```

### Desktop-Specific Code
```rust
#[cfg(not(target_arch = "wasm32"))]
use dioxus_desktop::{
    Config, WindowBuilder, tao::window::WindowBuilder as TaoWindowBuilder
};

#[cfg(not(target_arch = "wasm32"))]
fn desktop_config() -> Config {
    Config::default()
        .with_window(
            WindowBuilder::new()
                .with_title("My Desktop App")
                .with_inner_size(dioxus_desktop::LogicalSize::new(800.0, 600.0))
                .with_min_inner_size(dioxus_desktop::LogicalSize::new(400.0, 300.0))
                .with_resizable(true)
        )
}

#[component]
fn DesktopFeatures() -> Element {
    rsx! {
        div {
            h1 { "Desktop Features" }
            button {
                onclick: move |_| {
                    #[cfg(not(target_arch = "wasm32"))]
                    if let Some(window) = dioxus_desktop::current_window() {
                        let _ = window.set_title("New Title");
                    }
                },
                "Change Window Title"
            }
        }
    }
}
```

### Native Menus
```rust
#[cfg(not(target_arch = "wasm32"))]
fn create_menu() {
    use dioxus_desktop::tao::menu::{Menu, MenuItem, MenuType};

    let menu = Menu::new();

    let file_menu = Menu::new();
    file_menu.add_item(MenuItem::new("Open", Some("CmdOrCtrl+O"), true, || {
        println!("Open file");
    }));

    menu.add_submenu("File", file_menu);

    if let Some(window) = dioxus_desktop::current_window() {
        window.set_menu(Some(menu));
    }
}
```

### System Integration
```rust
#[cfg(not(target_arch = "wasm32"))]
fn system_integration() {
    // File dialogs
    if let Some(window) = dioxus_desktop::current_window() {
        use dioxus_desktop::tao::file_dialog::FileDialogBuilder;

        let dialog = FileDialogBuilder::new()
            .add_filter("Text Files", &["txt"])
            .set_title("Open File");

        // Show dialog (implementation varies by platform)
    }

    // Notifications (platform-specific)
    #[cfg(target_os = "windows")]
    {
        // Windows notification code
    }

    #[cfg(target_os = "macos")]
    {
        // macOS notification code
    }
}
```

## Mobile Platform

### Features
- Native mobile UI components
- Touch gestures
- Device APIs (camera, GPS, etc.)
- App store distribution
- Push notifications

### Setup
```bash
# iOS: Requires macOS with XCode
# Android: Requires Android SDK and NDK

# Install mobile dependencies
cargo add dioxus-mobile
```

### Configuration
```toml
# Cargo.toml
[dependencies]
dioxus = "0.7"

[target.'cfg(target_os = "ios")'.dependencies]
dioxus-mobile = { version = "0.7", features = ["ios"] }

[target.'cfg(target_os = "android")'.dependencies]
dioxus-mobile = { version = "0.7", features = ["android"] }
```

### Mobile-Specific Code
```rust
#[cfg(target_os = "ios")]
fn ios_specific() {
    // iOS-specific code
    println!("Running on iOS");
}

#[cfg(target_os = "android")]
fn android_specific() {
    // Android-specific code
    println!("Running on Android");
}

#[component]
fn MobileFeatures() -> Element {
    rsx! {
        div {
            h1 { "Mobile Features" }
            button {
                onclick: move |_| {
                    request_camera_permission();
                },
                "Request Camera"
            }
            // Touch-friendly UI
            button {
                style: "padding: 20px; font-size: 18px;",
                "Large Touch Target"
            }
        }
    }
}

#[cfg(any(target_os = "ios", target_os = "android"))]
fn request_camera_permission() {
    // Platform-specific permission request
    #[cfg(target_os = "ios")]
    {
        // iOS camera permission
    }

    #[cfg(target_os = "android")]
    {
        // Android camera permission
    }
}
```

### Device API Integration
```rust
#[cfg(any(target_os = "ios", target_os = "android"))]
mod device_apis {
    pub fn get_location() {
        // GPS/location services
    }

    pub fn take_picture() {
        // Camera access
    }

    pub fn send_notification(title: &str, body: &str) {
        // Push notifications
    }

    pub fn vibrate() {
        // Haptic feedback
    }
}
```

## Cross-Platform Patterns

### Platform Detection
```rust
fn platform_info() -> &'static str {
    if cfg!(target_arch = "wasm32") {
        "Web"
    } else if cfg!(target_os = "windows") {
        "Windows"
    } else if cfg!(target_os = "macos") {
        "macOS"
    } else if cfg!(target_os = "linux") {
        "Linux"
    } else if cfg!(target_os = "ios") {
        "iOS"
    } else if cfg!(target_os = "android") {
        "Android"
    } else {
        "Unknown"
    }
}

#[component]
fn PlatformInfo() -> Element {
    rsx! {
        div {
            h1 { "Platform: {platform_info()}" }
            p { "Current platform detected at compile time" }
        }
    }
}
```

### Conditional Features
```rust
#[component]
fn AdaptiveUI() -> Element {
    rsx! {
        if cfg!(target_arch = "wasm32") {
            // Web-specific UI
            div {
                style: "max-width: 800px; margin: 0 auto;",
                "Web-optimized layout"
            }
        } else if cfg!(any(target_os = "ios", target_os = "android")) {
            // Mobile-specific UI
            div {
                style: "padding: 20px; font-size: 16px;",
                "Mobile-optimized layout"
            }
        } else {
            // Desktop-specific UI
            div {
                style: "min-width: 1024px;",
                "Desktop-optimized layout"
            }
        }
    }
}
```

### Shared Business Logic
```rust
// Business logic that works across platforms
mod shared {
    pub struct User {
        pub name: String,
        pub email: String,
    }

    pub fn validate_email(email: &str) -> bool {
        email.contains('@')
    }

    pub async fn fetch_user(id: u32) -> Result<User, String> {
        // Platform-agnostic async operation
        Ok(User {
            name: "John Doe".to_string(),
            email: "john@example.com".to_string(),
        })
    }
}

// Platform-specific UI using shared logic
#[component]
fn UserProfile(user_id: u32) -> Element {
    let user = use_resource(move || shared::fetch_user(user_id));

    rsx! {
        match user.read().as_ref() {
            Some(Ok(user)) => rsx! {
                div {
                    h2 { "{user.name}" }
                    p { "{user.email}" }
                    // Platform-specific actions
                    if cfg!(target_arch = "wasm32") {
                        a { href: "/profile/{user_id}", "View Full Profile" }
                    } else {
                        button {
                            onclick: move |_| open_native_profile(user_id),
                            "View Profile"
                        }
                    }
                }
            },
            Some(Err(e)) => rsx! { div { "Error: {e}" } },
            None => rsx! { div { "Loading..." } }
        }
    }
}

#[cfg(not(target_arch = "wasm32"))]
fn open_native_profile(user_id: u32) {
    // Native profile opening logic
}
```

## Platform-Specific Testing

```rust
#[cfg(test)]
mod tests {
    #[test]
    fn test_shared_logic() {
        // Test platform-agnostic logic
        assert!(shared::validate_email("test@example.com"));
    }

    #[cfg(target_arch = "wasm32")]
    #[wasm_bindgen_test::wasm_bindgen_test]
    fn web_specific_test() {
        // Web-only tests
    }

    #[cfg(not(target_arch = "wasm32"))]
    #[test]
    fn desktop_specific_test() {
        // Desktop-only tests
    }
}
```

## Best Practices

1. **Maximize code sharing** - Keep platform-specific code minimal
2. **Use feature flags** - Enable platform-specific dependencies
3. **Abstract platform differences** - Create shared interfaces
4. **Test on all platforms** - Ensure consistent behavior
5. **Consider platform conventions** - Follow UI/UX patterns for each platform
6. **Handle platform limitations** - Gracefully degrade features when needed
7. **Use conditional compilation** - Leverage Rust's cfg system effectively