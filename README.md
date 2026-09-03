# IHateShorts

A lightweight, distraction-free Safari Web Extension that removes YouTube Shorts from your feed and sidebar navigation, while keeping the content you care about accessible.

---

## Features

- **Hide Feed Shelves**: Completely removes Shorts shelves, carousels, and standalone cards from your Home and Subscription feeds with zero layout flicker.
- **Hide Sidebar Navigation**: Strips the "Shorts" tab from both the expanded sidebar drawer and the mini-guide.
- **Auto-Convert to Regular Player**: Opening a shared Shorts link (`youtube.com/shorts/<id>`) instantly redirects to YouTube's standard desktop player (`youtube.com/watch?v=<id>`) with:
  - Full scrubber timeline & playback speed controls
  - Standard comments & description layout
  - No infinite vertical doomscroll trap
- **Search Results Preserved**: Shorts remain visible in search results so intentional searches for tutorials, recipes, or quick fixes still work.
- **Popup Controls**: Easily toggle shelf hiding, sidebar hiding, or player redirection anytime via the Safari toolbar icon.
- **Lightweight & Private**: Zero external dependencies, no analytics, no background tracking.

---

## Quick Start (Safari on macOS)

### Prerequisites
- macOS 14+
- [Bun](https://bun.sh)
- Xcode Command Line Tools (`xcode-select --install`)

### Build & Install

1. Clone or navigate to the repository:
   ```bash
   cd IHateShorts
   ```

2. Build and register the extension bundle:
   ```bash
   bun run build
   ```
   *This compiles the native Swift wrapper, packages the extension into `~/Applications/IHateShorts.app`, signs it, and registers it with macOS PluginKit.*

3. Enable the extension in Safari (one-time setup):
   - Open **Safari** → **Settings** (`Cmd + ,`) → **Advanced** tab.
   - Check **Show features for web developers** (or *Show Develop menu in menu bar*).
   - In the macOS menu bar, click **Develop** → **Allow Unsigned Extensions** *(authenticate with Touch ID / password)*.
   - Go to **Safari Settings** → **Extensions** tab.
   - Check the box next to **IHateShorts** and grant access to `youtube.com`.

4. Refresh any open YouTube tab to enjoy a clutter-free feed.

---

## Cross-Browser Support (Chrome, Brave, Arc, Firefox)

The `extension/` directory is written to standard cross-browser **Manifest V3**:

- **Chrome / Chromium (Brave, Arc, Edge)**:
  1. Open `chrome://extensions`.
  2. Toggle **Developer mode** on (top right).
  3. Click **Load unpacked** and select the `extension/` directory.

- **Firefox**:
  1. Open `about:debugging#/runtime/this-firefox`.
  2. Click **Load Temporary Add-on…** and select `extension/manifest.json`.

---

## Project Structure

```
IHateShorts/
├── extension/             # Core Manifest V3 WebExtension
│   ├── manifest.json      # Extension manifest
│   ├── content.css        # Zero-flicker CSS selectors
│   ├── content.js         # Navigation interceptor & DOM purifier
│   ├── popup/             # Extension settings popup UI
│   └── icons/             # Multi-resolution icons
├── macos/                 # Native macOS Safari wrapper & App Extension
│   ├── AppMain.swift      # Host AppKit interface
│   ├── Handler.swift      # Safari WebExtension handler
│   ├── Info-App.plist     # Host app metadata
│   └── Info-Extension.plist # Appex bundle configuration
├── scripts/
│   ├── build.sh           # Bundling, compiling, signing & registration
│   └── generate_icons.swift # Native icon generator
└── package.json           # Bun project scripts
```

---

## License

MIT
