#!/bin/bash

# Hyprlock-Style SDDM Theme Installation Script
# A beautiful dark theme with Japanese text and murder-red accents
# Version: 1.0

set -e

# Theme information
THEME_NAME="hyprlock-style"
THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDDM_THEMES_DIR="/usr/share/sddm/themes"
SDDM_CONFIG_DIR="/etc/sddm.conf.d"
TARGET_DIR="${SDDM_THEMES_DIR}/${THEME_NAME}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print banner
print_banner() {
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║    ${GREEN}Hyprlock-Style SDDM Theme${BLUE}          ║${NC}"
    echo -e "${BLUE}║    ${YELLOW}Installation Script${BLUE}                ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}✗ This script must be run with sudo privileges${NC}"
        echo -e "  Please run: ${GREEN}sudo ./install.sh${NC}"
        exit 1
    fi
}

# Check dependencies
check_dependencies() {
    echo -e "${YELLOW}→ Checking dependencies...${NC}"
    
    if ! command -v sddm &> /dev/null; then
        echo -e "${RED}✗ SDDM is not installed${NC}"
        echo -e "  Install it with: ${GREEN}sudo pacman -S sddm${NC} (Arch)"
        echo -e "                   ${GREEN}sudo apt install sddm${NC} (Debian/Ubuntu)"
        echo -e "                   ${GREEN}sudo dnf install sddm${NC} (Fedora)"
        exit 1
    fi
    echo -e "${GREEN}✓ SDDM is installed${NC}"
    
    # Check for required QML modules
    if ! pacman -Q qt5-quickcontrols2 &> /dev/null 2>&1 && \
       ! dpkg -l qt5-quickcontrols2 &> /dev/null 2>&1 && \
       ! rpm -q qt5-quickcontrols2 &> /dev/null 2>&1; then
        echo -e "${YELLOW}⚠ Qt5 Quick Controls 2 may not be installed${NC}"
        echo -e "  The theme might not work properly without it"
    fi
}

# Validate theme files
validate_theme() {
    echo -e "${YELLOW}→ Validating theme files...${NC}"
    
    local errors=0
    
    # Check Main.qml
    if [[ ! -f "${THEME_DIR}/Main.qml" ]]; then
        echo -e "${RED}✗ Main.qml not found${NC}"
        ((errors++))
    else
        echo -e "${GREEN}✓ Main.qml found${NC}"
    fi
    
    # Check theme.conf
    if [[ ! -f "${THEME_DIR}/theme.conf" ]]; then
        echo -e "${YELLOW}⚠ theme.conf not found - will create default${NC}"
    else
        echo -e "${GREEN}✓ theme.conf found${NC}"
    fi
    
    # Check metadata.desktop
    if [[ ! -f "${THEME_DIR}/metadata.desktop" ]]; then
        echo -e "${YELLOW}⚠ metadata.desktop not found - will create default${NC}"
    else
        echo -e "${GREEN}✓ metadata.desktop found${NC}"
    fi
    
    # Check assets directory
    if [[ ! -d "${THEME_DIR}/assets" ]]; then
        echo -e "${YELLOW}⚠ assets directory not found - will create${NC}"
        mkdir -p "${THEME_DIR}/assets"
    else
        echo -e "${GREEN}✓ assets directory found${NC}"
    fi
    
    if [[ $errors -gt 0 ]]; then
        echo -e "${RED}✗ Theme validation failed${NC}"
        exit 1
    fi
}

# Create default theme.conf if it doesn't exist
create_theme_conf() {
    if [[ ! -f "${THEME_DIR}/theme.conf" ]]; then
        echo -e "${YELLOW}→ Creating theme.conf...${NC}"
        cat > "${THEME_DIR}/theme.conf" << 'EOF'
[General]
type=color
color=#121212
fontSize=10
font="Maple Mono NF"
EOF
        echo -e "${GREEN}✓ theme.conf created${NC}"
    fi
}

# Create default metadata.desktop if it doesn't exist
create_metadata() {
    if [[ ! -f "${THEME_DIR}/metadata.desktop" ]]; then
        echo -e "${YELLOW}→ Creating metadata.desktop...${NC}"
        cat > "${THEME_DIR}/metadata.desktop" << 'EOF'
[SddmGreeterTheme]
Name=Hyprlock Style
Description=A beautiful dark theme with Japanese text and murder-red accents
Author=uzski
Copyright=(c) 2024
License=MIT
Type=sddm-theme
Version=1.0
Website=https://github.com/uzski/custom-sddm-theme
Screenshot=preview.png
MainScript=Main.qml
ConfigFile=theme.conf
TranslationsDirectory=translations
Email=
Theme-Id=hyprlock-style
Theme-API=2.0
EOF
        echo -e "${GREEN}✓ metadata.desktop created${NC}"
    fi
}

# Create placeholder assets
create_placeholder_assets() {
    echo -e "${YELLOW}→ Checking assets...${NC}"
    
    # Create a simple placeholder background if none exists
    if [[ ! -f "${THEME_DIR}/assets/background.jpg" ]] && [[ ! -f "${THEME_DIR}/assets/background.png" ]]; then
        echo -e "${YELLOW}  Creating placeholder background...${NC}"
        # Create a dark gradient image using ImageMagick if available
        if command -v convert &> /dev/null; then
            convert -size 1920x1080 gradient:'#121212-#2a0a0e' "${THEME_DIR}/assets/background.jpg"
            echo -e "${GREEN}  ✓ Placeholder background created${NC}"
        else
            echo -e "${YELLOW}  ⚠ ImageMagick not found - no placeholder background created${NC}"
            echo -e "${YELLOW}    Add your own background.jpg to assets/ directory${NC}"
        fi
    fi
    
    # Create a simple placeholder avatar if none exists
    if [[ ! -f "${THEME_DIR}/assets/avatar.jpg" ]] && [[ ! -f "${THEME_DIR}/assets/avatar.png" ]]; then
        echo -e "${YELLOW}  Creating placeholder avatar...${NC}"
        if command -v convert &> /dev/null; then
            convert -size 100x100 xc:'#a31621' \
                    -draw "fill white circle 50,50 50,1" \
                    "${THEME_DIR}/assets/avatar.jpg"
            echo -e "${GREEN}  ✓ Placeholder avatar created${NC}"
        else
            echo -e "${YELLOW}  ⚠ ImageMagick not found - no placeholder avatar created${NC}"
            echo -e "${YELLOW}    Add your own avatar.jpg to assets/ directory${NC}"
        fi
    fi
}

# Backup existing theme
backup_existing_theme() {
    if [[ -d "${TARGET_DIR}" ]]; then
        echo -e "${YELLOW}→ Backing up existing theme...${NC}"
        local backup_name="${THEME_NAME}-backup-$(date +%Y%m%d-%H%M%S)"
        local backup_dir="${SDDM_THEMES_DIR}/${backup_name}"
        mv "${TARGET_DIR}" "${backup_dir}"
        echo -e "${GREEN}✓ Backup created: ${backup_dir}${NC}"
    fi
}

# Install theme
install_theme() {
    echo -e "${YELLOW}→ Installing theme to ${TARGET_DIR}...${NC}"
    
    # Create themes directory if it doesn't exist
    mkdir -p "${SDDM_THEMES_DIR}"
    
    # Copy theme files
    cp -r "${THEME_DIR}" "${TARGET_DIR}"
    
    # Remove install script from target
    rm -f "${TARGET_DIR}/install.sh"
    rm -f "${TARGET_DIR}/install-fix.sh"
    
    # Set proper permissions
    chmod -R 755 "${TARGET_DIR}"
    find "${TARGET_DIR}" -type f -name "*.qml" -exec chmod 644 {} \;
    find "${TARGET_DIR}" -type f -name "*.conf" -exec chmod 644 {} \;
    find "${TARGET_DIR}" -type f -name "*.desktop" -exec chmod 644 {} \;
    find "${TARGET_DIR}/assets" -type f -exec chmod 644 {} \; 2>/dev/null || true
    
    echo -e "${GREEN}✓ Theme installed successfully${NC}"
}

# Configure SDDM
configure_sddm() {
    echo -e "${YELLOW}→ Configuring SDDM...${NC}"
    
    # Create config directory if it doesn't exist
    mkdir -p "${SDDM_CONFIG_DIR}"
    
    # Backup existing config
    local config_file="${SDDM_CONFIG_DIR}/theme.conf"
    if [[ -f "${config_file}" ]]; then
        cp "${config_file}" "${config_file}.backup-$(date +%Y%m%d-%H%M%S)"
        echo -e "${GREEN}✓ Existing configuration backed up${NC}"
    fi
    
    # Write new configuration
    cat > "${config_file}" << EOF
[Theme]
Current=${THEME_NAME}
ThemeDir=${SDDM_THEMES_DIR}
EOF
    
    echo -e "${GREEN}✓ SDDM configuration updated${NC}"
}

# Test theme
test_theme() {
    echo ""
    echo -e "${YELLOW}Would you like to test the theme? (y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}→ Starting SDDM test mode...${NC}"
        echo -e "${YELLOW}  Press Ctrl+C to exit test mode${NC}"
        sleep 2
        sddm-greeter --test-mode --theme "${TARGET_DIR}"
    fi
}

# Enable SDDM service
enable_sddm_service() {
    echo ""
    echo -e "${YELLOW}Would you like to enable SDDM as your display manager? (y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}→ Configuring display manager...${NC}"
        
        # Disable other display managers
        for dm in gdm lightdm lxdm xdm; do
            if systemctl is-enabled "${dm}" &> /dev/null; then
                echo -e "${YELLOW}  Disabling ${dm}...${NC}"
                systemctl disable "${dm}"
            fi
        done
        
        # Enable SDDM
        echo -e "${YELLOW}  Enabling SDDM...${NC}"
        systemctl enable sddm
        echo -e "${GREEN}✓ SDDM enabled as display manager${NC}"
        echo -e "${YELLOW}  SDDM will start on next boot${NC}"
    fi
}

# Print summary
print_summary() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       Installation Complete! 🎉        ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Theme Details:${NC}"
    echo -e "  • Name: ${GREEN}${THEME_NAME}${NC}"
    echo -e "  • Location: ${GREEN}${TARGET_DIR}${NC}"
    echo -e "  • Config: ${GREEN}${SDDM_CONFIG_DIR}/theme.conf${NC}"
    echo ""
    echo -e "${BLUE}Customization:${NC}"
    echo -e "  • Background: Place your image at ${YELLOW}${TARGET_DIR}/assets/background.jpg${NC}"
    echo -e "  • Avatar: Place your image at ${YELLOW}${TARGET_DIR}/assets/avatar.jpg${NC}"
    echo -e "  • Colors: Edit ${YELLOW}${TARGET_DIR}/Main.qml${NC}"
    echo ""
    echo -e "${BLUE}Commands:${NC}"
    echo -e "  • Test theme: ${GREEN}sddm-greeter --test-mode --theme ${TARGET_DIR}${NC}"
    echo -e "  • Restart SDDM: ${GREEN}sudo systemctl restart sddm${NC}"
    echo ""
}

# Main installation flow
main() {
    print_banner
    check_root
    check_dependencies
    validate_theme
    create_theme_conf
    create_metadata
    create_placeholder_assets
    backup_existing_theme
    install_theme
    configure_sddm
    print_summary
    test_theme
    enable_sddm_service
}

# Run the installation
main "$@"
