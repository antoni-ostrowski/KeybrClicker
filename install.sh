#!/bin/bash
set -e

REPO="antoni-ostrowski/keybrclicker"
BINARY_NAME="keybrclicker"
APP_NAME="KeybrClicker.app"
INSTALL_DIR="$HOME/Applications"
LOG_DIR="$HOME/.local/state/keybrclicker"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_NAME="com.keybrclicker.plist"
DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/${BINARY_NAME}"

echo "=== KeybrClicker Installer ==="
echo ""

ARCH=$(uname -m)
if [ "$ARCH" != "arm64" ]; then
    echo "Warning: This tool is designed for Apple Silicon (arm64)."
    echo "Your architecture: $ARCH"
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Downloading latest release..."
mkdir -p /tmp/keybrclicker-install
BINARY_PATH="/tmp/keybrclicker-install/$BINARY_NAME"

if command -v curl &>/dev/null; then
    curl -sSL -o "$BINARY_PATH" "$DOWNLOAD_URL"
elif command -v wget &>/dev/null; then
    wget -q -O "$BINARY_PATH" "$DOWNLOAD_URL"
else
    echo "Error: curl or wget required"
    exit 1
fi

chmod +x "$BINARY_PATH"
echo "Downloaded binary successfully."

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

cp "$BINARY_PATH" "$MACOS_DIR/$BINARY_NAME"
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
codesign --force --deep --sign - "$APP_PATH" 2>/dev/null || echo "Note: Ad-hoc signing completed"

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

rm -rf /tmp/keybrclicker-install

echo ""
echo "=== Installation Complete ==="
echo ""
echo "The service is now running and will start automatically at login."
echo ""
echo "App:      $APP_PATH"
echo "Log:      $LOG_DIR/keybrclicker.log"
echo ""
echo "IMPORTANT: Grant Accessibility permissions to complete setup."
echo ""
echo "1. Open: System Settings → Privacy & Security → Accessibility"
echo "2. Click the + button"
echo "3. Add: $APP_PATH"
echo "4. Ensure KeybrClicker is enabled in the list"
echo ""
echo "If the app was already added before, toggle it off and on."
echo ""
echo "Manage the service:"
echo "  just uninstall-service   - Stop and remove service"
echo "  just restart-service     - Restart the service"
echo "  just status              - Check service status"
echo "  just logs                - View logs"
echo ""
echo "To uninstall completely:"
echo "  curl -sSL https://raw.githubusercontent.com/${REPO}/main/uninstall.sh | bash"