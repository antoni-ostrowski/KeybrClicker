#!/bin/bash

echo "Compiling keybrclicker..."
swiftc -o keybrclicker main.swift -framework Cocoa

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "Run with: ./keybrclicker"
else
    echo "Build failed!"
    exit 1
fi
