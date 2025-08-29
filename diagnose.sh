#!/bin/bash

# SDDM Theme Diagnostic Script
# This script helps diagnose issues with SDDM theme rendering

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

THEME_NAME="hyprlock-style"
THEME_DIR="/usr/share/sddm/themes/${THEME_NAME}"

echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}  SDDM Theme Diagnostic Report${NC}"
echo -e "${BLUE}====================================${NC}"
echo ""

# 1. Check SDDM Service Status
echo -e "${YELLOW}1. SDDM Service Status:${NC}"
if systemctl is-active --quiet sddm; then
    echo -e "${GREEN}   ✓ SDDM service is running${NC}"
else
    echo -e "${RED}   ✗ SDDM service is not running${NC}"
fi
echo ""

# 2. Check Theme Directory
echo -e "${YELLOW}2. Theme Directory Check:${NC}"
if [ -d "$THEME_DIR" ]; then
    echo -e "${GREEN}   ✓ Theme directory exists: $THEME_DIR${NC}"
    echo -e "   Directory permissions: $(stat -c '%a' $THEME_DIR)"
else
    echo -e "${RED}   ✗ Theme directory not found: $THEME_DIR${NC}"
fi
echo ""

# 3. Check Required Files
echo -e "${YELLOW}3. Required Files:${NC}"
FILES=("Main.qml" "theme.conf" "metadata.desktop")
for file in "${FILES[@]}"; do
    if [ -f "$THEME_DIR/$file" ]; then
        echo -e "${GREEN}   ✓ $file exists${NC}"
        echo -e "     Size: $(stat -c%s "$THEME_DIR/$file") bytes"
        echo -e "     Permissions: $(stat -c '%a' "$THEME_DIR/$file")"
    else
        echo -e "${RED}   ✗ $file missing${NC}"
    fi
done
echo ""

# 4. Check Assets
echo -e "${YELLOW}4. Asset Files:${NC}"
ASSETS=("assets/darkcityariel.png" "assets/ronaldo-shadow.jpg")
for asset in "${ASSETS[@]}"; do
    if [ -f "$THEME_DIR/$asset" ]; then
        SIZE=$(stat -c%s "$THEME_DIR/$asset")
        echo -e "${GREEN}   ✓ $asset exists${NC}"
        echo -e "     Size: $SIZE bytes ($(numfmt --to=iec-i --suffix=B $SIZE))"
        echo -e "     Permissions: $(stat -c '%a' "$THEME_DIR/$asset")"
        
        # Check if file is actually an image
        if command -v file &> /dev/null; then
            FILE_TYPE=$(file -b "$THEME_DIR/$asset")
            echo -e "     Type: $FILE_TYPE"
        fi
    else
        echo -e "${RED}   ✗ $asset missing${NC}"
    fi
done
echo ""

# 5. Check Path References in Main.qml
echo -e "${YELLOW}5. Path References in Main.qml:${NC}"
if [ -f "$THEME_DIR/Main.qml" ]; then
    # Check for absolute paths
    if grep -q '"/home/' "$THEME_DIR/Main.qml"; then
        echo -e "${RED}   ✗ Found absolute paths in Main.qml:${NC}"
        grep -n '"/home/' "$THEME_DIR/Main.qml" | head -5
    else
        echo -e "${GREEN}   ✓ No absolute paths found${NC}"
    fi
    
    # Check asset references
    echo -e "${BLUE}   Asset references in Main.qml:${NC}"
    grep -o 'source:.*"[^"]*"' "$THEME_DIR/Main.qml" | head -5
else
    echo -e "${RED}   ✗ Main.qml not found${NC}"
fi
echo ""

# 6. Check SDDM Configuration
echo -e "${YELLOW}6. SDDM Configuration:${NC}"
if [ -f "/etc/sddm.conf.d/theme.conf" ]; then
    echo -e "${GREEN}   ✓ Theme configuration exists${NC}"
    echo -e "   Current theme setting:"
    grep "Current=" /etc/sddm.conf.d/theme.conf | sed 's/^/     /'
elif [ -f "/etc/sddm.conf" ]; then
    echo -e "${YELLOW}   Theme setting in main config:${NC}"
    grep -A2 "\[Theme\]" /etc/sddm.conf | sed 's/^/     /'
else
    echo -e "${RED}   ✗ No SDDM configuration found${NC}"
fi
echo ""

# 7. Check Qt/QML Dependencies
echo -e "${YELLOW}7. Qt/QML Dependencies:${NC}"
REQUIRED_PACKAGES=("qt5-base" "qt5-declarative" "qt5-quickcontrols2" "qt5-graphicaleffects")
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if pacman -Qi "$pkg" &> /dev/null; then
        VERSION=$(pacman -Qi "$pkg" | grep "Version" | cut -d: -f2 | xargs)
        echo -e "${GREEN}   ✓ $pkg installed (v$VERSION)${NC}"
    else
        echo -e "${RED}   ✗ $pkg not installed${NC}"
    fi
done
echo ""

# 8. Check for Common Issues
echo -e "${YELLOW}8. Common Issues Check:${NC}"

# Check if running Wayland
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    echo -e "${YELLOW}   ⚠ Running Wayland session - some SDDM themes may have compatibility issues${NC}"
fi

# Check display manager conflicts
if systemctl is-enabled --quiet gdm; then
    echo -e "${RED}   ✗ GDM is also enabled - this may conflict with SDDM${NC}"
fi
if systemctl is-enabled --quiet lightdm; then
    echo -e "${RED}   ✗ LightDM is also enabled - this may conflict with SDDM${NC}"
fi

# Check SELinux (if applicable)
if command -v getenforce &> /dev/null; then
    SELINUX_STATUS=$(getenforce)
    if [ "$SELINUX_STATUS" = "Enforcing" ]; then
        echo -e "${YELLOW}   ⚠ SELinux is enforcing - may need to adjust contexts${NC}"
    fi
fi
echo ""

# 9. SDDM Log Analysis
echo -e "${YELLOW}9. Recent SDDM Errors (if any):${NC}"
if [ -f "/var/log/sddm.log" ]; then
    ERRORS=$(grep -i "error\|warning\|failed" /var/log/sddm.log 2>/dev/null | tail -5)
    if [ -n "$ERRORS" ]; then
        echo -e "${RED}   Recent errors found:${NC}"
        echo "$ERRORS" | sed 's/^/     /'
    else
        echo -e "${GREEN}   ✓ No recent errors in SDDM log${NC}"
    fi
else
    # Try journalctl
    if command -v journalctl &> /dev/null; then
        ERRORS=$(journalctl -u sddm -p err -n 5 --no-pager 2>/dev/null)
        if [ -n "$ERRORS" ]; then
            echo -e "${RED}   Recent errors from journalctl:${NC}"
            echo "$ERRORS" | sed 's/^/     /'
        else
            echo -e "${GREEN}   ✓ No recent errors in journal${NC}"
        fi
    fi
fi
echo ""

# 10. Summary and Recommendations
echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}  Summary & Recommendations${NC}"
echo -e "${BLUE}====================================${NC}"

ISSUES=0

# Check critical files
if [ ! -f "$THEME_DIR/Main.qml" ]; then
    echo -e "${RED}• Main.qml is missing - reinstall the theme${NC}"
    ISSUES=$((ISSUES + 1))
fi

if [ ! -f "$THEME_DIR/assets/darkcityariel.png" ]; then
    echo -e "${RED}• Background image is missing - check assets folder${NC}"
    ISSUES=$((ISSUES + 1))
fi

if [ ! -f "$THEME_DIR/assets/ronaldo-shadow.jpg" ]; then
    echo -e "${RED}• Avatar image is missing - check assets folder${NC}"
    ISSUES=$((ISSUES + 1))
fi

if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✓ All critical components are present!${NC}"
    echo ""
    echo -e "${YELLOW}If images still don't render, try:${NC}"
    echo -e "1. Clear SDDM cache:"
    echo -e "   ${BLUE}sudo rm -rf /var/lib/sddm/.cache${NC}"
    echo -e ""
    echo -e "2. Restart SDDM service:"
    echo -e "   ${BLUE}sudo systemctl restart sddm${NC}"
    echo -e ""
    echo -e "3. Check if running from TTY (Ctrl+Alt+F2) and restart:"
    echo -e "   ${BLUE}sudo systemctl stop sddm${NC}"
    echo -e "   ${BLUE}sudo systemctl start sddm${NC}"
    echo -e ""
    echo -e "4. Test with a different user account"
    echo -e ""
    echo -e "5. Try the default SDDM theme first to verify SDDM works:"
    echo -e "   ${BLUE}sudo sed -i 's/Current=.*/Current=breeze/' /etc/sddm.conf.d/theme.conf${NC}"
    echo -e "   Then switch back after testing"
else
    echo -e "${RED}✗ Found $ISSUES critical issue(s) - please fix them first${NC}"
fi

echo -e "${BLUE}====================================${NC}"
