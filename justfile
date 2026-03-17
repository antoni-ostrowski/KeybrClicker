default:
  just --list

build:
	echo "Compiling keybrclicker..."
	mkdir -p bin
	swiftc -o ./bin/keybrclicker ./src/main.swift -framework Cocoa && echo "Build successful!" && echo "Run with: ./bin/keybrclicker"

start:
  ./bin/keybrclicker

