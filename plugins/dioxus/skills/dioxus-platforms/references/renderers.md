# Dioxus Renderers Reference

## Overview

Dioxus provides multiple renderers that allow the same codebase to run on different platforms. Each renderer has specific capabilities, performance characteristics, and use cases.

## Dioxus-Web

### Description
Renders directly to the browser's Document Object Model (DOM) using WebAssembly. This is the most mature and feature-complete renderer.

### Features
- **Native DOM Rendering**: Direct manipulation of browser DOM
- **WebAssembly Performance**: Near-native performance in browsers
- **Full Browser API Access**: Complete access to web APIs
- **SEO Friendly**: Server-side rendering support
- **Progressive Web App (PWA)**: PWA capabilities
- **Hot Reloading**: Fast development cycle

### Architecture
```
RSX → Virtual DOM → DOM Nodes → Browser
```

### Performance Characteristics
- **Initial Load**: Fast with WebAssembly
- **Runtime Performance**: Excellent, near-native
- **Memory Usage**: Low to moderate
- **Bundle Size**: Small (~50KB compressed)

### Supported Features
- All HTML5 elements
- CSS3 styling and animations
- JavaScript interop via web-sys
- WebGL and Canvas
- WebRTC and WebSockets
- LocalStorage, IndexedDB
- Service Workers

### Limitations
- Browser-only platform
- No native file system access
- Limited by browser security policies

### Usage
```rust
// Cargo.toml
[dependencies]
dioxus = "0.7"
dioxus-web = "0.7"

// main.rs
#[cfg(target_arch = "wasm32")]
fn main() {
    dioxus_web::launch(App);
}

#[component]
fn App() -> Element {
    rsx! {
        h1 { "Web Application" }
        p { "Running in browser with native DOM" }
    }
}
```

### Configuration Options
```rust
dioxus_web::launch_cfg(
    App,
    dioxus_web::Config::new()
        .rootname("app")                    // Root element ID
        .stylesheet("styles.css")           // External CSS
        .replace_default_styles(false)      // Keep default styles
);
```

## Dioxus-Desktop

### Description
Uses system webviews to render applications as native desktop applications. Provides a native window with web-based UI.

### Features
- **Native Window Management**: Window controls, menus, title bar
- **System Integration**: File dialogs, notifications, system tray
- **Cross-Platform**: Windows, macOS, Linux support
- **Web Technology**: Leverages web technologies for UI
- **Native APIs**: Access to native system APIs
- **Offline Capable**: No internet dependency

### Architecture
```
RSX → Virtual DOM → HTML/CSS → WebView → Native Window
```

### Platform-Specific WebViews
- **Windows**: Microsoft Edge WebView2
- **macOS**: WKWebView (WebKit)
- **Linux**: WebKitGTK

### Performance Characteristics
- **Startup Time**: Moderate (WebView initialization)
- **Runtime Performance**: Very good
- **Memory Usage**: Moderate (WebView overhead)
- **Bundle Size**: Medium (includes WebView dependencies)

### Supported Features
- Native window controls
- System menus and menu bars
- File system access
- Native dialogs
- System notifications
- Custom window chrome
- Multiple windows
- Fullscreen mode

### Limitations
- WebView dependency
- Larger bundle size
- Platform-specific quirks
- Limited native UI components

### Usage
```rust
// Cargo.toml
[dependencies]
dioxus = "0.7"
dioxus-desktop = "0.7"

// main.rs
#[cfg(not(target_arch = "wasm32"))]
fn main() {
    dioxus_desktop::launch_cfg(
        App,
        dioxus_desktop::Config::default()
            .with_window(
                WindowBuilder::new()
                    .with_title("My Desktop App")
                    .with_inner_size(LogicalSize::new(800, 600))
            )
    );
}
```

### Configuration Options
```rust
dioxus_desktop::Config::default()
    .with_window(
        WindowBuilder::new()
            .with_title("App Title")
            .with_inner_size(LogicalSize::new(800, 600))
            .with_min_inner_size(LogicalSize::new(400, 300))
            .with_resizable(true)
            .with_decorations(true)          // Window decorations
            .with_transparent(false)         // Window transparency
            .with_always_on_top(false)       // Always on top
            .with_fullscreen(false)          // Fullscreen mode
    )
    .with_menu(Some(custom_menu()))        // Custom menu
    .with_disable_context_menu(false)      // Right-click menu
    .with_invisible(false)                 // Start invisible
```

## Dioxus-Mobile

### Description
Native mobile applications with hybrid rendering approach, combining native performance with web development productivity.

### Features
- **Native Mobile UI**: Platform-native components
- **Touch Gestures**: Multi-touch and gesture support
- **Device APIs**: Camera, GPS, accelerometer, etc.
- **App Store Distribution**: Ready for app store deployment
- **Push Notifications**: Native push notification support
- **Background Processing**: Background tasks and services

### Architecture
```
RSX → Virtual DOM → Native Components → Platform UI
```

### Platform Support
- **iOS**: Native iOS components and APIs
- **Android**: Native Android components and APIs

### Performance Characteristics
- **Startup Time**: Fast native startup
- **Runtime Performance**: Excellent native performance
- **Memory Usage**: Optimized for mobile devices
- **Bundle Size**: Optimized for app store distribution

### Supported Features
- Native navigation patterns
- Touch and gesture handling
- Device hardware integration
- Native permissions system
- Background processing
- Push notifications
- App lifecycle management

### Limitations
- Platform-specific build requirements
- More complex development setup
- Separate app store review processes
- Platform-specific testing needed

### Usage
```rust
// Cargo.toml
[dependencies]
dioxus = "0.7"
dioxus-mobile = "0.7"

// Platform-specific main functions
#[cfg(target_os = "ios")]
fn main() {
    dioxus_mobile::launch(App);
}

#[cfg(target_os = "android")]
fn main() {
    dioxus_mobile::launch(App);
}
```

## Third-Party Renderers

### Freya
**Description**: Skia-based renderer for CPU-only rendering and advanced graphics capabilities.

**Features**:
- Skia graphics engine
- CPU-only rendering (no GPU required)
- Advanced graphics effects
- Custom drawing capabilities

**Use Cases**:
- Applications requiring custom graphics
- Environments without GPU support
- Advanced visual effects

### LiveView
**Description**: Server-side rendering with real-time updates over WebSocket connections.

**Features**:
- Server-side rendering
- Real-time updates
- Low client requirements
- Centralized state management

**Use Cases**:
- Collaborative applications
- Real-time dashboards
- Low-powered client devices

## Renderer Selection Guide

### Choose Dioxus-Web when:
- Building web applications
- Need SEO and search engine visibility
- Targeting browsers primarily
- Want fastest web performance
- Need PWA capabilities

### Choose Dioxus-Desktop when:
- Building desktop applications
- Need native system integration
- Want cross-platform desktop support
- Require file system access
- Need native menus and dialogs

### Choose Dioxus-Mobile when:
- Building mobile applications
- Need app store distribution
- Require device hardware integration
- Want native mobile performance
- Need push notifications

## Performance Comparison

| Renderer | Startup | Runtime | Memory | Bundle Size | Platform |
|----------|---------|---------|---------|-------------|----------|
| Web | Fast | Excellent | Low | Small | Browser |
| Desktop | Moderate | Very Good | Medium | Medium | Desktop |
| Mobile | Fast | Excellent | Optimized | Optimized | Mobile |

## Migration Between Renderers

### Code Compatibility
Most Dioxus code is renderer-agnostic. The main differences are:

1. **Platform-specific APIs**: Use conditional compilation
2. **Build configuration**: Different dependencies and settings
3. **Deployment**: Different packaging and distribution

### Example: Cross-Platform Main
```rust
fn main() {
    #[cfg(target_arch = "wasm32")]
    dioxus_web::launch(App);

    #[cfg(target_os = "ios")]
    dioxus_mobile::launch(App);

    #[cfg(target_os = "android")]
    dioxus_mobile::launch(App);

    #[cfg(not(any(target_arch = "wasm32", target_os = "ios", target_os = "android")))]
    dioxus_desktop::launch(App);
}
```

### Platform-Specific Features
```rust
#[component]
fn CrossPlatformApp() -> Element {
    rsx! {
        h1 { "Cross-Platform App" }

        // Web-specific features
        #[cfg(target_arch = "wasm32")]
        WebFeatures {}

        // Desktop-specific features
        #[cfg(not(target_arch = "wasm32"))]
        DesktopFeatures {}

        // Mobile-specific features
        #[cfg(any(target_os = "ios", target_os = "android"))]
        MobileFeatures {}
    }
}
```

## Best Practices

1. **Write renderer-agnostic code** when possible
2. **Use conditional compilation** for platform-specific features
3. **Test on all target platforms** early and often
4. **Consider platform conventions** for UI/UX
5. **Optimize for each platform's constraints**
6. **Handle platform-specific errors gracefully**
7. **Use appropriate APIs for each platform**

## Future Renderer Development

The Dioxus team is actively working on:

- **Dioxus-Native**: Pure native rendering without webviews
- **TUI Renderer**: Terminal user interface support
- **Game Console Renderers**: Support for gaming platforms
- **Embedded Systems**: Renderer for IoT and embedded devices