# Project overview

Swift/AppKit macOS tool for keyboard-driven mouse clicks and scrolling. Single-file app (`main.swift`).

**Click Mode:**

1. User presses hotkey → full-screen grid overlay appears
2. User types 2 letters to select a big cell (e.g., "AS")
3. Mini-grid appears inside selected cell with keyboard-like layout
4. User types 1 letter → simulates click at that position
5. Press Escape to cancel

**Scroll Mode:**

1. User presses scroll hotkey → transparent scroll mode activates
2. User presses direction keys (default H/J/K/L) to scroll at current mouse position
3. Hold keys to scroll continuously
4. Press Escape to exit

**Multi-monitor support:** Grid appears on the screen where mouse cursor is located.

# Architecture

- `AppDelegate`: Hotkey registration, config loading
- `GridWindow`: Full-screen transparent overlay window for clicks
- `GridView`: Grid rendering, input handling, click execution
- `ScrollWindow`: Transparent window for scroll mode
- `ScrollView`: Scroll input handling, scroll event generation
- `LayoutConfig`: Codable struct for config (hotkeys + scroll config + keyboard layout)

# Config

Location: `~/.config/keybrclicker/config.json`
Created automatically on first run with defaults.
