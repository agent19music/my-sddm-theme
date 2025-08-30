#!/bin/bash

# SDDM Theme Screenshot Helper
# This script helps capture a screenshot of the SDDM theme

echo "╔════════════════════════════════════════════════════╗"
echo "║     SDDM Theme Screenshot Capture Helper           ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""
echo "This will help you capture a screenshot of your theme."
echo ""
echo "📸 METHOD 1: Test Mode (Window Screenshot)"
echo "========================================="
echo "1. Open a new terminal"
echo "2. Run: sddm-greeter --test-mode --theme ."
echo "3. Wait for the theme window to appear"
echo "4. Press PrtScn or use Spectacle to capture"
echo "5. Save as: assets/preview.png"
echo ""
echo "Would you like to start test mode now? (y/n)"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Starting SDDM test mode in 3 seconds..."
    echo "Once it opens:"
    echo "  1. Press Super key (Windows key)"
    echo "  2. Type 'spectacle' and press Enter"
    echo "  3. Select 'Window Under Cursor'"
    echo "  4. Click on the SDDM preview window"
    echo "  5. Save as 'preview.png' in assets folder"
    echo ""
    sleep 3
    
    # Start test mode
    sddm-greeter --test-mode --theme . &
    SDDM_PID=$!
    
    echo ""
    echo "Test mode started (PID: $SDDM_PID)"
    echo "Press Enter here after capturing the screenshot..."
    read
    
    # Kill the test mode
    kill $SDDM_PID 2>/dev/null
    
    # Check if preview was saved
    if [ -f "assets/preview.png" ]; then
        echo "✅ Screenshot saved successfully!"
        echo ""
        echo "Optimizing image size..."
        # Try to optimize with ImageMagick if available
        if command -v convert &> /dev/null; then
            convert assets/preview.png -quality 85 -resize 1920x1080\> assets/preview_optimized.png
            mv assets/preview_optimized.png assets/preview.png
            echo "✅ Image optimized!"
        fi
        
        echo ""
        echo "Your preview is ready at: assets/preview.png"
        echo "The README will now show this preview!"
    else
        echo "⚠️  No preview.png found in assets/"
        echo "Make sure to save the screenshot as assets/preview.png"
    fi
fi

echo ""
echo "📸 METHOD 2: Full Screen Mode (Advanced)"
echo "========================================="
echo "For a production-quality screenshot:"
echo ""
echo "1. Make sure theme is installed:"
echo "   sudo ./install.sh"
echo ""
echo "2. Switch to another TTY:"
echo "   Press Ctrl+Alt+F3"
echo ""
echo "3. Login and run:"
echo "   DISPLAY=:1 sddm-greeter --test-mode --theme /usr/share/sddm/themes/hyprlock-style"
echo ""
echo "4. Switch back to your desktop (Ctrl+Alt+F1)"
echo ""
echo "5. Use Spectacle to capture Screen 1"
echo ""
echo "This gives you a full-resolution screenshot without window decorations."
