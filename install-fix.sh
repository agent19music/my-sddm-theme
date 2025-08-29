#!/bin/bash

# SDDM Theme Installation Script with Full Fix
# This script properly installs the theme and ensures all assets are accessible

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Theme information
THEME_NAME="hyprlock-style"
THEME_DIR="/usr/share/sddm/themes/${THEME_NAME}"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}  SDDM Theme Installation Script${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root (use sudo)${NC}"
   exit 1
fi

# Check if SDDM is installed
if ! command -v sddm &> /dev/null; then
    echo -e "${RED}SDDM is not installed. Please install SDDM first.${NC}"
    exit 1
fi

echo -e "${YELLOW}Source directory: ${SOURCE_DIR}${NC}"
echo -e "${YELLOW}Target directory: ${THEME_DIR}${NC}"
echo ""

# Create backup if theme already exists
if [ -d "$THEME_DIR" ]; then
    echo -e "${YELLOW}Existing theme found. Creating backup...${NC}"
    BACKUP_DIR="${THEME_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
    cp -r "$THEME_DIR" "$BACKUP_DIR"
    echo -e "${GREEN}Backup created at: ${BACKUP_DIR}${NC}"
    rm -rf "$THEME_DIR"
fi

# Create theme directory
echo -e "${YELLOW}Creating theme directory...${NC}"
mkdir -p "$THEME_DIR"

# Copy all theme files
echo -e "${YELLOW}Copying theme files...${NC}"
cp -r "${SOURCE_DIR}"/* "$THEME_DIR/"

# Ensure assets directory exists
if [ ! -d "$THEME_DIR/assets" ]; then
    echo -e "${YELLOW}Creating assets directory...${NC}"
    mkdir -p "$THEME_DIR/assets"
fi

# Check if assets exist in source
if [ ! -f "${SOURCE_DIR}/assets/darkcityariel.png" ]; then
    echo -e "${RED}Warning: darkcityariel.png not found in assets!${NC}"
fi

if [ ! -f "${SOURCE_DIR}/assets/ronaldo-shadow.jpg" ]; then
    echo -e "${RED}Warning: ronaldo-shadow.jpg not found in assets!${NC}"
fi

# Set proper permissions
echo -e "${YELLOW}Setting permissions...${NC}"
chmod -R 755 "$THEME_DIR"
chmod 644 "$THEME_DIR"/*.qml 2>/dev/null || true
chmod 644 "$THEME_DIR"/*.conf 2>/dev/null || true
chmod 644 "$THEME_DIR"/*.desktop 2>/dev/null || true
chmod 644 "$THEME_DIR"/assets/* 2>/dev/null || true

# Verify installation
echo ""
echo -e "${YELLOW}Verifying installation...${NC}"

ERRORS=0

# Check Main.qml
if [ ! -f "$THEME_DIR/Main.qml" ]; then
    echo -e "${RED}✗ Main.qml not found${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ Main.qml installed${NC}"
fi

# Check theme.conf
if [ ! -f "$THEME_DIR/theme.conf" ]; then
    echo -e "${RED}✗ theme.conf not found${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ theme.conf installed${NC}"
fi

# Check metadata.desktop
if [ ! -f "$THEME_DIR/metadata.desktop" ]; then
    echo -e "${RED}✗ metadata.desktop not found${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ metadata.desktop installed${NC}"
fi

# Check background image
if [ ! -f "$THEME_DIR/assets/darkcityariel.png" ]; then
    echo -e "${RED}✗ Background image (darkcityariel.png) not found${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ Background image installed${NC}"
    # Check file size to ensure it's not corrupted
    SIZE=$(stat -c%s "$THEME_DIR/assets/darkcityariel.png")
    if [ $SIZE -lt 1000 ]; then
        echo -e "${RED}  Warning: Background image seems too small (${SIZE} bytes)${NC}"
    fi
fi

# Check avatar image
if [ ! -f "$THEME_DIR/assets/ronaldo-shadow.jpg" ]; then
    echo -e "${RED}✗ Avatar image (ronaldo-shadow.jpg) not found${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ Avatar image installed${NC}"
    # Check file size to ensure it's not corrupted
    SIZE=$(stat -c%s "$THEME_DIR/assets/ronaldo-shadow.jpg")
    if [ $SIZE -lt 1000 ]; then
        echo -e "${RED}  Warning: Avatar image seems too small (${SIZE} bytes)${NC}"
    fi
fi

# Check if paths in Main.qml are relative
echo ""
echo -e "${YELLOW}Checking path configuration in Main.qml...${NC}"
if grep -q '"/home/uzski' "$THEME_DIR/Main.qml"; then
    echo -e "${RED}✗ Found absolute paths in Main.qml - fixing...${NC}"
    sed -i 's|"/home/uzski/[^"]*darkcityariel.png"|"assets/darkcityariel.png"|g' "$THEME_DIR/Main.qml"
    sed -i 's|"/home/uzski/[^"]*ronaldo-shadow.jpg"|"assets/ronaldo-shadow.jpg"|g' "$THEME_DIR/Main.qml"
    echo -e "${GREEN}✓ Fixed absolute paths to relative paths${NC}"
else
    echo -e "${GREEN}✓ Paths are correctly configured as relative${NC}"
fi

# Update Japanese greeting
echo ""
echo -e "${YELLOW}Updating Japanese greeting...${NC}"
sed -i 's|text: "愛してる"|text: "愛してる、一秒一秒、毎分、毎時間、毎日"|g' "$THEME_DIR/Main.qml"
echo -e "${GREEN}✓ Updated Japanese greeting to: 愛してる、一秒一秒、毎分、毎時間、毎日${NC}"

# Update SDDM configuration
echo ""
echo -e "${YELLOW}Updating SDDM configuration...${NC}"

SDDM_CONF="/etc/sddm.conf"
SDDM_CONF_D="/etc/sddm.conf.d"

# Create config directory if it doesn't exist
if [ ! -d "$SDDM_CONF_D" ]; then
    mkdir -p "$SDDM_CONF_D"
fi

# Create or update theme configuration
THEME_CONF="$SDDM_CONF_D/theme.conf"
cat > "$THEME_CONF" << EOF
[Theme]
Current=${THEME_NAME}
ThemeDir=/usr/share/sddm/themes
EOF

echo -e "${GREEN}✓ SDDM configuration updated${NC}"

# Summary
echo ""
echo -e "${GREEN}====================================${NC}"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ Installation completed successfully!${NC}"
    echo ""
    echo -e "Theme installed to: ${THEME_DIR}"
    echo -e "Theme name: ${THEME_NAME}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "1. Restart SDDM to apply the theme:"
    echo -e "   ${GREEN}sudo systemctl restart sddm${NC}"
    echo -e ""
    echo -e "2. Or test the theme first:"
    echo -e "   ${GREEN}sddm-greeter --test-mode --theme ${THEME_DIR}${NC}"
else
    echo -e "${RED}✗ Installation completed with ${ERRORS} error(s)${NC}"
    echo -e "${YELLOW}Please check the errors above and fix them manually.${NC}"
fi
echo -e "${GREEN}====================================${NC}"

# Optional: Test mode
echo ""
read -p "Would you like to test the theme now? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Launching test mode...${NC}"
    echo -e "${YELLOW}Press Ctrl+C to exit test mode${NC}"
    sleep 2
    sddm-greeter --test-mode --theme "$THEME_DIR"
fi
