# KeybrClicker

A native macos keyboard-driven mouse click tool.


https://github.com/user-attachments/assets/cdaeb2cc-6761-42ca-bf39-3e826ca67a42


> i couldn't find an OSS tool like this so i decided to make my own, vibecoded with opencode (glm-5).

## Building

```bash
./build.sh
```

## Running

```bash
./keybrclicker
```

## Usage

> only supports mouse1 at the moment

1. Press the hotkey (default: `Cmd+Option+G`) to show the grid
2. Type 2 letters to select a big cell
3. Type 1 letter to click at that position in the mini grid
4. Press `Escape` to cancel at any time

## Configuration

Program reads config from the same directory its located in. Edit `layout.json` to customize:

### Hotkey

```json
"hotkey": {
  "modifiers": ["cmd", "option"],
  "key": "g"
}
```

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

- `Cmd+Option+G`: `{"modifiers": ["cmd", "option"], "key": "g"}`
- `Ctrl+Shift+Space`: `{"modifiers": ["control", "shift"], "key": "space"}`
- `Cmd+F1`: `{"modifiers": ["cmd"], "key": "f1"}`

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
