# Platform-Specific Dependencies

## Linux

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install \
    libwebkit2gtk-4.1-dev \
    build-essential \
    curl \
    wget \
    file \
    libxdo-dev \
    libssl-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev \
    lld
```

### Arch Linux
```bash
sudo pacman -Syu
sudo pacman -S --needed \
    webkit2gtk-4.1 \
    base-devel \
    curl \
    wget \
    file \
    openssl \
    appmenu-gtk-module \
    libappindicator-gtk3 \
    librsvg \
    xdotool
```

### Fedora
```bash
sudo dnf install libxdo-devel
# Also install the equivalent of Ubuntu packages
```

### Other Linux Distributions
Check the Tauri prerequisites documentation for your specific distribution.

## macOS

### Desktop Development
No additional dependencies required!

### iOS Development
1. Install XCode from Mac App Store or Apple Developer website
2. Install iOS SDK and simulators
3. Configure XCode command line tools:
   ```bash
   xcode-select --install
   ```

## Windows

### WebView2 Requirements
Windows apps depend on WebView2, which should be installed in modern Windows distributions.

#### Verification
If you have Microsoft Edge installed, WebView2 should already be available.

#### Installation Options
1. **Bootstrapper (Recommended)**: Tiny installer that fetches from Microsoft CDN
2. **Installer**: Small installer that downloads WebView2
3. **Statically Linked**: Bundle WebView2 in your final binary

### Development Tools
- Visual Studio Build Tools (for C++ compilation)
- Git
- Windows Terminal (recommended)

## WSL (Windows Subsystem for Linux)

While possible, WSL development for Dioxus desktop can be tricky.

### Setup Steps
1. Update WSL to version 2
2. Update kernel to latest version
3. Add `export DISPLAY=:0` to `~/.zshrc`
4. Install Tauri Linux dependencies
5. Install `zenity` for file dialogs

### Known Issues
- `libEGL` warnings (can be ignored, app should still render)
- Some UI elements may not display correctly

## Mobile Development

### iOS Requirements
- macOS with XCode installed
- iOS SDK
- iOS Simulator (for testing)

### Android Requirements
- Android SDK
- Android NDK
- Android Studio (recommended)

## Verification Commands

```bash
# Check Dioxus CLI installation
dx doctor

# Check Rust toolchain
rustup show

# Check wasm target (for web development)
rustup target list --installed | grep wasm32
```

## Common Issues and Solutions

### Missing libwebkit2gtk
```bash
# Ubuntu/Debian
sudo apt install libwebkit2gtk-4.1-dev

# Or try different version based on your system
sudo apt install libwebkit2gtk-4.0-dev
```

### Build Issues on Linux
Ensure all build tools are installed:
```bash
sudo apt install build-essential
```

### Permission Denied
Check that cargo bin directory is in PATH:
```bash
echo $PATH | grep cargo
```

If not present, add to shell profile:
```bash
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
```