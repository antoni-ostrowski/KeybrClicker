#!/bin/bash
set -e

APP_NAME="KeybrClicker.app"
INSTALL_DIR="$HOME/Applications"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_NAME="com.keybrclicker.plist"

echo "=== KeybrClicker Service Uninstaller ==="

PLIST_PATH="$LAUNCH_AGENTS_DIR/$PLIST_NAME"

echo "Stopping service..."
if launchctl print gui/$(id -u)/com.keybrclicker &>/dev/null; then
    launchctl bootout gui/$(id -u)/com.keybrclicker
    echo "Service stopped."
else
    echo "Service not running."
fi

echo "Removing LaunchAgent plist..."
if [ -f "$PLIST_PATH" ]; then
    rm "$PLIST_PATH"
    echo "Removed: $PLIST_PATH"
else
    echo "Plist not found."
fi

APP_PATH="$INSTALL_DIR/$APP_NAME"
read -p "Remove app bundle from $INSTALL_DIR? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "$APP_PATH" ]; then
        rm -rf "$APP_PATH"
        echo "Removed: $APP_PATH"
    else
        echo "App bundle not found."
    fi
fi

echo ""
echo "=== Uninstall Complete ==="
echo "Config preserved at: ~/.config/keybrclicker/"
echo "Logs preserved at: ~/.local/state/keybrclicker/"