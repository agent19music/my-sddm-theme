#!/bin/bash
# Test script for SDDM theme
# This will test the theme in a window without needing to restart SDDM

echo "Testing SDDM theme..."
echo "Note: This will open a test window. Press Ctrl+C to close."
echo ""

# Check if we're in the right directory
if [ ! -f "Main.qml" ]; then
    echo "Error: Main.qml not found in current directory"
    exit 1
fi

# Create a temporary test configuration
cat > test.conf << EOF
[Theme]
Current=$(pwd)
EOF

# Test the theme
# Note: This requires X11/Wayland to be running
# Try Qt5 greeter since the theme uses Qt5 GraphicalEffects
sddm-greeter --test-mode --theme $(pwd) 2>&1 | while read line; do
    # Filter out non-critical warnings
    if [[ "$line" == *"cannot assign to non-existent property"* ]]; then
        echo "❌ ERROR: $line"
    elif [[ "$line" == *"ReferenceError"* ]]; then
        echo "❌ ERROR: $line"
    elif [[ "$line" == *"TypeError"* ]]; then
        echo "❌ ERROR: $line"
    elif [[ "$line" == *"Error"* ]] && [[ "$line" != *"QML debugging"* ]]; then
        echo "⚠️  WARNING: $line"
    fi
done

echo ""
echo "Test completed. If no errors appeared above, the theme should work properly."
echo "To install the theme system-wide, copy this directory to /usr/share/sddm/themes/"
