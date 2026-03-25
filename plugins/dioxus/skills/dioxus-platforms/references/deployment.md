# Dioxus Platform Deployment Guide

## Overview

Deploying Dioxus applications varies significantly by platform. Each platform has its own build process, distribution methods, and requirements.

## Web Deployment

### Build Process
```bash
# Build for web platform
dx build --platform web --release

# Output directory: dist/web/
```

### Build Configuration
```toml
# dx.toml
[application]
name = "my-dioxus-app"
default_platform = "web"

[web.app]
title = "My Dioxus App"

[web.watcher]
reload_html = true
watch_path = ["src"]

[web.resource]
style = ["style.css"]
script = ["app.js"]

[web.resource.dev]
style = ["dev/style.css"]
```

### Static Site Hosting
Deploy to any static hosting service:

#### Netlify
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
netlify deploy --prod --dir=dist/web
```

#### Vercel
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel --prod dist/web
```

#### GitHub Pages
```yaml
# .github/workflows/deploy.yml
name: Deploy to GitHub Pages
on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: actions-rs/toolchain@v1
      with:
        toolchain: stable
        target: wasm32-unknown-unknown
    - name: Build
      run: |
        curl -sSL https://dioxus.dev/install.sh | bash
        dx build --platform web --release
    - name: Deploy
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./dist/web
```

### PWA Configuration
```toml
# dx.toml
[web.pwa]
enabled = true
background_color = "#ffffff"
theme_color = "#000000"
display = "standalone"

[web.pwa.icons]
192 = "icons/icon-192.png"
512 = "icons/icon-512.png"
```

### Environment Variables
```bash
# Production
export RUST_LOG=info
export API_URL=https://api.example.com

# Development
export RUST_LOG=debug
export API_URL=http://localhost:3000
```

### CDN Optimization
```html
<!-- dist/web/index.html -->
<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="https://cdn.example.com/styles.css">
</head>
<body>
    <div id="app"></div>
    <script src="https://cdn.example.com/wasm.js"></script>
</body>
</html>
```

## Desktop Deployment

### Build Process
```bash
# Build for desktop
dx build --platform desktop --release

# Output directory: dist/desktop/
```

### Platform-Specific Builds

#### Windows
```bash
# Build Windows executable
dx build --platform desktop --release

# Create installer (requires additional tools)
# Using makensis (NSIS)
makensis installer.nsi

# Using WiX (for MSI)
candle.exe product.wxs
light.exe product.wixobj
```

#### macOS
```bash
# Build macOS app
dx build --platform desktop --release

# Create DMG
create-dmg \
  --volname "My Dioxus App" \
  --window-pos 200 120 \
  --window-size 600 300 \
  --icon-size 100 \
  --icon "dist/desktop/MyApp.app/Contents/Resources/icon.icns" \
  --hide-extension "MyApp.app" \
  --app-drop-link 425 120 \
  "dist/desktop/MyApp.app"
```

#### Linux
```bash
# Build Linux executable
dx build --platform desktop --release

# Create AppImage
appimagetool-x86_64.AppImage dist/desktop/

# Create .deb package
dpkg-deb --build dist/desktop/ my-dioxus-app.deb

# Create .rpm package
rpmbuild -bb my-dioxus-app.spec
```

### Code Signing (Windows)
```bash
# Sign the executable
signtool sign \
  /f certificate.pfx \
  /p password \
  /t http://timestamp.digicert.com \
  dist/desktop/my-app.exe
```

### Code Signing (macOS)
```bash
# Sign the app
codesign --force --verify --verbose --sign "Developer ID Application: Name" dist/desktop/MyApp.app

# Notarize
xcrun altool --notarize-app \
  --primary-bundle-id "com.example.myapp" \
  --username "developer@example.com" \
  --password "@keychain:AC_PASSWORD" \
  --file dist/desktop/MyApp.app.zip

# Staple the ticket
xcrun stapler staple dist/desktop/MyApp.app
```

### Auto-Updates Implementation
```rust
// Auto-updater for desktop
#[cfg(not(target_arch = "wasm32"))]
mod updater {
    use std::process::Command;

    pub fn check_for_updates() {
        // Check version against server
        if needs_update() {
            download_and_install_update();
        }
    }

    fn download_and_install_update() {
        // Download new version
        // Restart application with new binary
    }
}
```

### Windows Installer Script (NSIS)
```nsis
; installer.nsi
!define APPNAME "My Dioxus App"
!define VERSION "1.0.0"

Name "${APPNAME}"
OutFile "${APPNAME}-${VERSION}-setup.exe"
InstallDir "$PROGRAMFILES\${APPNAME}"

Section "MainSection" SEC01
    SetOutPath "$INSTDIR"
    File "dist\desktop\my-app.exe"
    CreateShortCut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\my-app.exe"
SectionEnd

Section "Uninstall"
    Delete "$DESKTOP\${APPNAME}.lnk"
    Delete "$INSTDIR\my-app.exe"
    RMDir "$INSTDIR"
SectionEnd
```

## Mobile Deployment

### iOS Deployment

#### Prerequisites
- macOS with XCode
- Apple Developer account
- iOS device or simulator

#### Build Process
```bash
# Build iOS app
dx build --platform ios --release

# Output directory: dist/ios/
```

#### XCode Integration
```bash
# Generate XCode project
dx generate-xcode-project

# Open in XCode
open MyDioxusApp.xcodeproj

# Build and run from XCode
# or use command line:
xcodebuild -project MyDioxusApp.xcodeproj -scheme MyDioxusApp -configuration Release
```

#### Info.plist Configuration
```xml
<!-- ios/Info.plist -->
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>My Dioxus App</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>armv7</string>
    </array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
</dict>
</plist>
```

#### App Store Submission
1. Archive the app in XCode
2. Upload to App Store Connect
3. Complete metadata and screenshots
4. Submit for review

### Android Deployment

#### Prerequisites
- Android Studio
- Android SDK and NDK
- Java Development Kit

#### Build Process
```bash
# Build Android app
dx build --platform android --release

# Output directory: dist/android/
```

#### Gradle Configuration
```gradle
// android/app/build.gradle
android {
    compileSdkVersion 33

    defaultConfig {
        applicationId "com.example.mydioxusapp"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0.0"
    }

    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

#### AndroidManifest.xml
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.mydioxusapp">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />

    <application
        android:label="My Dioxus App"
        android:icon="@mipmap/ic_launcher"
        android:theme="@android:style/Theme.Material.Light.NoActionBar">

        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

#### Play Store Submission
1. Generate signed APK or AAB
2. Create Google Play Console listing
3. Upload app bundle
4. Complete store listing and screenshots
5. Submit for review

### Continuous Integration

#### GitHub Actions (Multi-Platform)
```yaml
# .github/workflows/build-all.yml
name: Build All Platforms

on:
  push:
    tags: ['v*']

jobs:
  build-web:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Setup Rust
      uses: actions-rs/toolchain@v1
      with:
        toolchain: stable
        target: wasm32-unknown-unknown
    - name: Build Web
      run: |
        curl -sSL https://dioxus.dev/install.sh | bash
        dx build --platform web --release
    - name: Deploy Web
      run: # Deploy to your web hosting

  build-desktop:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
    runs-on: ${{ matrix.os }}
    steps:
    - uses: actions/checkout@v2
    - name: Setup Rust
      uses: actions-rs/toolchain@v1
      with:
        toolchain: stable
    - name: Build Desktop
      run: |
        curl -sSL https://dioxus.dev/install.sh | bash
        dx build --platform desktop --release
    - name: Upload Artifact
      uses: actions/upload-artifact@v2
      with:
        name: desktop-${{ matrix.os }}
        path: dist/desktop/

  build-mobile:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v2
    - name: Setup Rust
      uses: actions-rs/toolchain@v1
      with:
        toolchain: stable
    - name: Build iOS
      run: dx build --platform ios --release
    - name: Build Android
      run: dx build --platform android --release
    - name: Upload Artifacts
      uses: actions/upload-artifact@v2
      with:
        name: mobile-builds
        path: dist/
```

## Environment Management

### Development vs Production
```rust
// Environment configuration
#[derive(Clone)]
struct Config {
    api_url: String,
    debug: bool,
    log_level: String,
}

impl Config {
    fn from_env() -> Self {
        Config {
            api_url: std::env::var("API_URL")
                .unwrap_or_else(|_| "http://localhost:3000".to_string()),
            debug: std::env::var("DEBUG")
                .unwrap_or_else(|_| "false".to_string()) == "true",
            log_level: std::env::var("LOG_LEVEL")
                .unwrap_or_else(|_| "info".to_string()),
        }
    }
}
```

### Feature Flags
```toml
# Cargo.toml
[features]
default = ["web"]
web = ["dioxus-web"]
desktop = ["dioxus-desktop"]
mobile = ["dioxus-mobile"]
```

### Platform-Specific Configuration
```rust
// config/mod.rs
#[cfg(target_arch = "wasm32")]
pub mod web_config {
    pub fn init() {
        // Web-specific initialization
    }
}

#[cfg(not(target_arch = "wasm32"))]
pub mod desktop_config {
    pub fn init() {
        // Desktop-specific initialization
    }
}
```

## Monitoring and Analytics

### Error Tracking
```rust
// Error tracking integration
#[cfg(target_arch = "wasm32")]
fn init_error_tracking() {
    // Web error tracking (e.g., Sentry)
}

#[cfg(not(target_arch = "wasm32"))]
fn init_error_tracking() {
    // Desktop error tracking
}
```

### Analytics
```rust
// Analytics integration
fn track_event(name: &str, properties: &[(&str, &str)]) {
    #[cfg(target_arch = "wasm32")]
    {
        // Web analytics (e.g., Google Analytics)
    }

    #[cfg(not(target_arch = "wasm32"))]
    {
        // Desktop analytics
    }
}
```

## Best Practices

1. **Platform-specific builds**: Create separate build pipelines for each platform
2. **Automated testing**: Test on all target platforms before deployment
3. **Version management**: Use semantic versioning across all platforms
4. **Rollback strategies**: Have plans for quick rollbacks if issues arise
5. **Security considerations**: Platform-specific security measures
6. **Performance monitoring**: Monitor performance on each platform
7. **User feedback**: Collect platform-specific user feedback