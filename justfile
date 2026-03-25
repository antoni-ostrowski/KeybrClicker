default:
  just --list

build:
	echo "Compiling keybrclicker..."
	mkdir -p bin
	swiftc -o ./bin/keybrclicker ./src/main.swift -framework Cocoa && echo "Build successful!" && echo "Run with: ./bin/keybrclicker"

start:
	./bin/keybrclicker

install-service:
	./scripts/install-service.sh

uninstall-service:
	./scripts/uninstall-service.sh

restart-service:
	launchctl kickstart -k gui/$(id -u)/com.keybrclicker 2>/dev/null || echo "Service not running, use 'just install-service' first"

status:
	@launchctl print gui/$(id -u)/com.keybrclicker 2>/dev/null && echo "Status: running" || echo "Status: not installed"

logs:
	tail -f ~/.local/state/keybrclicker/keybrclicker.log

