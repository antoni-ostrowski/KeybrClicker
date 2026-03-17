# KeybrClicker

A native macos keyboard-driven mouse click utility. (single file)

https://github.com/user-attachments/assets/cdaeb2cc-6761-42ca-bf39-3e826ca67a42

> i couldn't find an OSS tool like this so i decided to make my own, vibecoded with opencode (glm-5).

## Building

```bash
./scripts/build.sh
```

## Running

```bash
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

Define multiple hotkeys, each with its own mouse button and persistence setting:

```json
"hotkeys": [
  {
    "modifiers": ["cmd", "option"],
    "key": "g",
    "mouseButton": "left",
    "persistent": false
  },
  {
    "modifiers": ["cmd", "option", "shift"],
    "key": "g",
    "mouseButton": "right",
    "persistent": true
  }
]
```

**Fields:**

- `modifiers`: Array of modifier keys (see below)
- `key`: Single key to trigger the hotkey (see below)
- `mouseButton`: `"left"`, `"right"`, or `"middle"`
- `persistent`: If `true`, grid stays active after each click for rapid chaining. Press `Escape` to exit.

**Persistent Mode:** When enabled, the grid reappears immediately after each click, allowing fast consecutive clicks without re-triggering the hotkey.

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

- Left click, normal: `{"modifiers": ["cmd", "option"], "key": "g", "mouseButton": "left", "persistent": false}`
- Right click, persistent: `{"modifiers": ["cmd", "option", "shift"], "key": "g", "mouseButton": "right", "persistent": true}`
- Middle click: `{"modifiers": ["cmd", "option"], "key": "m", "mouseButton": "middle", "persistent": false}`

### Keyboard Layout

The grid is based on your keyboard layout for easy memorization.

**`home_row`**: Keys used for big grid column names (typically your home row keys, left to right)

**`all_keys`**: 2D array representing your keyboard rows (top to bottom, left to right). Used for:

1. Big grid row names (flattened order)
2. Mini grid layout inside selected big cells

**Example (QWERTY):**

```json
{
  "home_row": ["A", "S", "D", "F", "G", "H", "J", "K", "L", ";"],
  "all_keys": [
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

If clicks don't work, check **System Settings → Privacy & Security → Accessibility** and ensure `keybrclicker` is enabled.

## Quitting

Since the app doesn't appear in the dock or menu bar, quit it via:

```bash
pkill keybrclicker
```

Or use Activity Monitor or kill process via raycast.
