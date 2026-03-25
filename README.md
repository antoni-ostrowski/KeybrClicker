# KeybrClicker

A native macOS keyboard-driven mouse click utility.

https://github.com/user-attachments/assets/c980febb-5f5d-4e62-ba2e-fa71afcf87b9

> I couldn't find an OSS tool like this so I decided to make my own.

## Installation

```bash
curl -sSL https://raw.githubusercontent.com/antoni-ostrowski/keybrclicker/main/install.sh | bash
```

**After installation, grant Accessibility permissions:**

1. Open **System Settings → Privacy & Security → Accessibility**
2. Click the **+** button
3. Add `~/Applications/KeybrClicker.app`
4. Ensure KeybrClicker is enabled in the list

The service starts automatically at login.

## Uninstall

```bash
curl -sSL https://raw.githubusercontent.com/antoni-ostrowski/keybrclicker/main/uninstall.sh | bash
```

## Managing the Service

| Command                                                | Description      |
| ------------------------------------------------------ | ---------------- |
| `launchctl print gui/$(id -u)/com.keybrclicker`        | Check if running |
| `launchctl kickstart -k gui/$(id -u)/com.keybrclicker` | Restart service  |
| `tail -f ~/.local/state/keybrclicker/keybrclicker.log` | View logs        |
| `launchctl bootout gui/$(id -u)/com.keybrclicker`      | Stop service     |

To start again after stopping:

```bash
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.keybrclicker.plist
```

## Usage

1. Press a hotkey to show the grid
2. Type 2 letters to select a big cell
3. Type 1 letter to click at that position in the mini grid
4. Press `Escape` to cancel/exit at any time

## Configuration

Config: `~/.config/keybrclicker/config.json` (created automatically)

### Hotkeys

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

- `modifiers`: Array of `cmd`, `option`, `control`, `shift`
- `key`: Single character or special key (`f1`-`f12`, `space`, `return`, `tab`, `escape`, etc.)
- `mouseButton`: `left`, `right`, or `middle`

### Scroll Mode

```json
{
  "scrollHotkeys": [{ "modifiers": ["cmd", "option"], "key": "s" }],
  "scrollKeys": {
    "up": "k",
    "down": "j",
    "left": "h",
    "right": "l",
    "amount": 3
  }
}
```

1. Press scroll hotkey to enter scroll mode
2. Use H/J/K/L (vim-style) to scroll at cursor position
3. Press `Escape` to exit

### Keyboard Layout

Grid matches your keyboard for easy memorization:

```json
"layout": [
  ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
  ["A", "S", "D", "F", "G", "H", "J", "K", "L", ";"],
  ["Z", "X", "C", "V", "B", "N", "M", ",", ".", "/"]
]
```

## Permissions

Required for hotkey detection, mouse clicks, and scroll events.

If clicks don't work, ensure KeybrClicker is enabled in **System Settings → Privacy & Security → Accessibility**.

---

## Building from Source

Requires [just](https://github.com/casey/just) (build tool) and Swift compiler (Xcode Command Line Tools).

```bash
brew install just
git clone https://github.com/antoni-ostrowski/keybrclicker.git
cd keybrclicker
just build
just install-service
```

For development commands, see `justfile` or run `just --list`.

