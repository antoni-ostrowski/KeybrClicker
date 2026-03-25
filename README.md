# KeybrClicker

A native macos keyboard-driven mouse click utility. (single file)

https://github.com/user-attachments/assets/c980febb-5f5d-4e62-ba2e-fa71afcf87b9

> i couldn't find an OSS tool like this so i decided to make my own, vibecoded with opencode (glm-5).

# Getting Started

Download binary from [latest release](https://github.com/antoni-ostrowski/keybrclicker/releases).

## Building

```bash
just build
```

## Running

```bash
just start
# OR
./bin/keybrclicker
```

## Usage

1. Press a hotkey to show the grid
2. Type 2 letters to select a big cell
3. Type 1 letter to click at that position in the mini grid
4. Press `Escape` to cancel/exit at any time

## Configuration

Config is stored at `~/.config/keybrclicker/config.json`. A default config is created automatically on first run if it doesn't exist.

### Hotkeys

Define multiple hotkeys, each with its own mouse button:

```json
"hotkeys": [
  {
    "modifiers": ["cmd", "option"],
    "key": "g",
    "mouseButton": "left"
  },
  {
    "modifiers": ["cmd", "option", "shift"],
    "key": "g",
    "mouseButton": "right"
  }
]
```

**Fields:**

- `modifiers`: Array of modifier keys (see below)
- `key`: Single key to trigger the hotkey (see below)
- `mouseButton`: `"left"`, `"right"`, or `"middle"`

**Available modifiers:**

- `cmd` (or `command`)
- `option` (or `alt`)
- `control` (or `ctrl`)
- `shift`

**Available keys:**

- Any single character: `"g"`, `"a"`, `"1"`, etc.
- Special keys: `"space"`, `"return"`, `"enter"`, `"tab"`, `"escape"`, `"esc"`
- Function keys: `"f1"` through `"f12"`
- Arrow keys: `"up"`, `"down"`, `"left"`, `"right"`
- Other: `"delete"`, `"backspace"`

**Examples:**

- Left click: `{"modifiers": ["cmd", "option"], "key": "g", "mouseButton": "left"}`
- Right click: `{"modifiers": ["cmd", "option", "shift"], "key": "g", "mouseButton": "right"}`
- Middle click: `{"modifiers": ["cmd", "option"], "key": "m", "mouseButton": "middle"}`

### Scroll Mode

Scroll mode allows you to scroll anywhere using keyboard keys. When activated:

1. Press the configured scroll hotkey to enter scroll mode
2. Use scroll keys (default: H/J/K/L for left/down/up/right) to scroll at the current mouse position
3. Hold the key to scroll continuously
4. Press `Escape` to exit scroll mode

**`scrollHotkeys`**: Array of hotkey configurations to activate scroll mode (no mouse button needed).

**`scrollKeys`**: Configuration for scroll direction keys and scroll amount.

```json
{
  "scrollHotkeys": [
    { "modifiers": ["cmd", "option"], "key": "s" }
  ],
  "scrollKeys": {
    "up": "k",
    "down": "j",
    "left": "h",
    "right": "l",
    "amount": 3
  }
}
```

**Fields:**

- `up`, `down`, `left`, `right`: Keys for each scroll direction
- `amount`: Number of scroll units per keypress (default: 3)

**Note**: If `scrollHotkeys` or `scrollKeys` are not specified in config, defaults are used:
- Scroll hotkey: `Cmd+Option+S`
- Scroll keys: H/J/K/L (vim-style)
- Scroll amount: 3

### Keyboard Layout

The grid is based on your keyboard layout for easy memorization.

**`layout`**: 2D array representing your keyboard rows (top to bottom, left to right). The middle row is automatically used as the home row for column labels.

**Example (QWERTY):**

```json
{
  "hotkeys": [...],
  "layout": [
    ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
    ["A", "S", "D", "F", "G", "H", "J", "K", "L", ";"],
    ["Z", "X", "C", "V", "B", "N", "M", ",", ".", "/"]
  ]
}
```

## Permissions

On first run, the app will request Accessibility permissions. This is required for:

- Global hotkey detection
- Simulating mouse clicks
- Simulating scroll events

If clicks or scrolling don't work, check **System Settings → Privacy & Security → Accessibility** and ensure `keybrclicker` is enabled.

## Quitting

Since the app doesn't appear in the dock or menu bar, quit it via:

```bash
pkill keybrclicker
```

Or use Activity Monitor or kill process via raycast.
