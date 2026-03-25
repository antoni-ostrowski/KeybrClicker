#!/bin/bash
set -e

BINARY_NAME="keybrclicker"
APP_NAME="KeybrClicker.app"
INSTALL_DIR="$HOME/Applications"
LOG_DIR="$HOME/.local/state/keybrclicker"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_NAME="com.keybrclicker.plist"

echo "=== KeybrClicker Service Installer ==="

if ! command -v just &>/dev/null; then
    echo "Error: 'just' not found. Please install just first."
    echo "  brew install just"
    exit 1
fi

echo "Building binary..."
just build

echo "Creating directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$LOG_DIR"
mkdir -p "$LAUNCH_AGENTS_DIR"

APP_PATH="$INSTALL_DIR/$APP_NAME"
CONTENTS_DIR="$APP_PATH/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "Creating app bundle..."
rm -rf "$APP_PATH"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

cp ./bin/$BINARY_NAME "$MACOS_DIR/$BINARY_NAME"
chmod +x "$MACOS_DIR/$BINARY_NAME"

cat > "$CONTENTS_DIR/Info.plist" << 'PLISTEOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.keybrclicker</string>
    <key>CFBundleName</key>
    <string>KeybrClicker</string>
    <key>CFBundleDisplayName</key>
    <string>KeybrClicker</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleExecutable</key>
    <string>keybrclicker</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLISTEOF

echo "Signing app bundle..."
codesign --force --deep --sign - "$APP_PATH" 2>/dev/null || echo "Note: Codesign failed (may need manual signing)"

PLIST_PATH="$LAUNCH_AGENTS_DIR/$PLIST_NAME"

echo "Creating LaunchAgent..."
cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.keybrclicker</string>
    <key>ProgramArguments</key>
    <array>
        <string>$MACOS_DIR/$BINARY_NAME</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$LOG_DIR/keybrclicker.log</string>
    <key>StandardErrorPath</key>
    <string>$LOG_DIR/keybrclicker.log</string>
    <key>ProcessType</key>
    <string>Interactive</string>
</dict>
</plist>
EOF

if launchctl print gui/$(id -u)/com.keybrclicker &>/dev/null; then
    echo "Service already running, stopping..."
    launchctl bootout gui/$(id -u)/com.keybrclicker 2>/dev/null || true
fi

echo "Loading LaunchAgent..."
launchctl bootstrap gui/$(id -u) "$PLIST_PATH"

echo ""
echo "=== Installation Complete ==="
echo "App: $APP_PATH"
echo "Log: $LOG_DIR/keybrclicker.log"
echo "Plist: $PLIST_PATH"
echo ""
echo "The service is now running and will start automatically at login."
echo ""
echo "IMPORTANT: Grant Accessibility permissions when prompted."
echo "If not prompted, go to: System Settings → Privacy & Security → Accessibility"
echo "Add: $APP_PATH"
echo ""
echo "Commands:"
echo "  just status            - Check if service is running"
echo "  just restart-service   - Restart the service"
echo "  just logs              - Tail the log file"
echo "  just uninstall-service - Remove the service"