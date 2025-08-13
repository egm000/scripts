#!/bin/bash

# Check if an app name was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <app-name>"
    exit 1
fi

APP_NAME="$1"

echo "🔍 Searching for '$APP_NAME' across APT, Snap, and Flatpak..."
echo "------------------------------------------------------------"

# APT search
echo -e "\n📦 APT Results:"
apt search "$APP_NAME" 2>/dev/null | grep -i "$APP_NAME" | head -10

# Snap search
echo -e "\n📦 Snap Results:"
snap find "$APP_NAME" 2>/dev/null | grep -i "$APP_NAME" | head -10

# Flatpak search
echo -e "\n📦 Flatpak Results:"
flatpak search "$APP_NAME" 2>/dev/null | grep -i "$APP_NAME" | head -10

echo "------------------------------------------------------------"
echo "✅ Search complete."
