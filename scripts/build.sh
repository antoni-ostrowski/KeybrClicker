#!/bin/bash

echo "Compiling keybrclicker..."
mkdir bin
swiftc -o ./bin/keybrclicker ./src/main.swift -framework Cocoa

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "Run with: ./bin/keybrclicker"
else
    echo "Build failed!"
    exit 1
fi
