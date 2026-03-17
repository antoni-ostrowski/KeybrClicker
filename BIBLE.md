# Project overview

Swift/AppKit macOS tool for keyboard-driven mouse clicks. Single-file app (`main.swift`).

**How it works:**

1. User presses hotkey → full-screen grid overlay appears
2. User types 2 letters to select a big cell (e.g., "AS")
3. Mini-grid appears inside selected cell with keyboard-like layout
4. User types 1 letter → simulates click at that position
5. Press Escape to cancel

**Multi-monitor support:** Grid appears on the screen where mouse cursor is located.

# Architecture

- `AppDelegate`: Hotkey registration, config loading
- `GridWindow`: Full-screen transparent overlay window
- `GridView`: Grid rendering, input handling, click execution
- `LayoutConfig`: Codable struct for config (hotkey + keyboard layout)

# Config

Location: `~/.config/keybrclicker/config.json`
Created automatically on first run with defaults.
