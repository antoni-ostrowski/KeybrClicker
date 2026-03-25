#!/bin/bash
set -e

APP_NAME="KeybrClicker.app"
INSTALL_DIR="$HOME/Applications"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_NAME="com.keybrclicker.plist"
LOG_DIR="$HOME/.local/state/keybrclicker"
CONFIG_DIR="$HOME/.config/keybrclicker"

echo "=== KeybrClicker Uninstaller ==="
echo ""

PLIST_PATH="$LAUNCH_AGENTS_DIR/$PLIST_NAME"
APP_PATH="$INSTALL_DIR/$APP_NAME"

echo "Stopping service..."
if launchctl print gui/$(id -u)/com.keybrclicker &>/dev/null; then
    launchctl bootout gui/$(id -u)/com.keybrclicker
    echo "Service stopped."
else
    echo "Service not running."
fi

echo "Removing LaunchAgent..."
if [ -f "$PLIST_PATH" ]; then
    rm "$PLIST_PATH"
    echo "Removed: $PLIST_PATH"
else
    echo "LaunchAgent not found."
fi

echo "Removing app bundle..."
if [ -d "$APP_PATH" ]; then
    rm -rf "$APP_PATH"
    echo "Removed: $APP_PATH"
else
    echo "App not found."
fi

echo ""
echo "=== Uninstall Complete ==="
echo ""
read -p "Also remove config (~/.config/keybrclicker/) and logs (~/.local/state/keybrclicker/)? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$CONFIG_DIR" 2>/dev/null && echo "Removed: $CONFIG_DIR" || echo "Config dir not found."
    rm -rf "$LOG_DIR" 2>/dev/null && echo "Removed: $LOG_DIR" || echo "Log dir not found."
fi
echo ""
echo "Accessibility permission may still be listed in System Settings."
echo "You can remove it manually: System Settings → Privacy & Security → Accessibility"