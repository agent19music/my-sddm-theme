#!/bin/bash

# Hyprlock-Style SDDM Theme Installation Script
# Author: uzski
# Version: 2.0

set -e

THEME_NAME="hyprlock-style"
THEME_DIR="$(dirname "$(readlink -f "$0")")"
SDDM_THEMES_DIR="/usr/share/sddm/themes"
SDDM_CONFIG_DIR="/etc/sddm.conf.d"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}  Custom SDDM Theme Installer${NC}"
echo -e "${GREEN}==================================${NC}\n"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}This script needs to be run with sudo privileges.${NC}"
    echo "Please run: sudo ./install.sh"
    exit 1
fi

# Check if SDDM is installed
if ! command -v sddm &> /dev/null; then
    echo -e "${RED}Error: SDDM is not installed on this system.${NC}"
    echo "Please install SDDM first: sudo pacman -S sddm"
    exit 1
fi

# Function to backup existing theme
backup_theme() {
    if [ -d "$SDDM_THEMES_DIR/$THEME_NAME" ]; then
        echo -e "${YELLOW}Existing theme found. Creating backup...${NC}"
        BACKUP_NAME="${THEME_NAME}-backup-$(date +%Y%m%d-%H%M%S)"
        mv "$SDDM_THEMES_DIR/$THEME_NAME" "$SDDM_THEMES_DIR/$BACKUP_NAME"
        echo -e "${GREEN}Backup created: $BACKUP_NAME${NC}"
    fi
}

# Function to install theme
install_theme() {
    echo -e "${GREEN}Installing theme...${NC}"
    
    # Create theme directory if it doesn't exist
    mkdir -p "$SDDM_THEMES_DIR"
    
    # Copy theme files
    cp -r "$THEME_DIR" "$SDDM_THEMES_DIR/$THEME_NAME"
    
    # Set proper permissions
    chmod -R 755 "$SDDM_THEMES_DIR/$THEME_NAME"
    
    echo -e "${GREEN}Theme files installed successfully!${NC}"
}

# Function to configure SDDM
configure_sddm() {
    echo -e "${GREEN}Configuring SDDM...${NC}"
    
    # Create config directory if it doesn't exist
    mkdir -p "$SDDM_CONFIG_DIR"
    
    # Create or update configuration file
    CONFIG_FILE="$SDDM_CONFIG_DIR/theme.conf"
    
    # Backup existing config if it exists
    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" "${CONFIG_FILE}.backup-$(date +%Y%m%d-%H%M%S)"
        echo -e "${YELLOW}Existing configuration backed up${NC}"
    fi
    
    # Write new configuration
    cat > "$CONFIG_FILE" <<EOF
[Theme]
Current=$THEME_NAME
ThemeDir=$SDDM_THEMES_DIR
EOF
    
    echo -e "${GREEN}SDDM configuration updated!${NC}"
}

# Function to test theme
test_theme() {
    echo -e "\n${YELLOW}Would you like to test the theme? (y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Starting SDDM test mode...${NC}"
        echo -e "${YELLOW}Press Ctrl+Alt+F2 to return to your session${NC}"
        sleep 3
        sddm-greeter --test-mode --theme "$SDDM_THEMES_DIR/$THEME_NAME"
    fi
}

# Function to enable SDDM service
enable_service() {
    echo -e "\n${YELLOW}Would you like to enable SDDM as your display manager? (y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        # Disable other display managers if they exist
        for dm in gdm lightdm lxdm xdm; do
            if systemctl is-enabled "$dm" &> /dev/null; then
                echo -e "${YELLOW}Disabling $dm...${NC}"
                systemctl disable "$dm"
            fi
        done
        
        # Enable SDDM
        echo -e "${GREEN}Enabling SDDM...${NC}"
        systemctl enable sddm
        echo -e "${GREEN}SDDM enabled! It will start on next boot.${NC}"
    fi
}

# Main installation process
main() {
    echo "Theme directory: $THEME_DIR"
    echo "Target directory: $SDDM_THEMES_DIR/$THEME_NAME"
    echo ""
    
    # Check if theme files exist
    if [ ! -f "$THEME_DIR/Main.qml" ]; then
        echo -e "${RED}Error: Theme files not found in current directory.${NC}"
        echo "Please run this script from the theme directory."
        exit 1
    fi
    
    # Backup existing theme if present
    backup_theme
    
    # Install theme
    install_theme
    
    # Configure SDDM
    configure_sddm
    
    echo -e "\n${GREEN}==================================${NC}"
    echo -e "${GREEN}  Installation Complete!${NC}"
    echo -e "${GREEN}==================================${NC}\n"
    
    echo -e "Theme installed to: ${GREEN}$SDDM_THEMES_DIR/$THEME_NAME${NC}"
    echo -e "Configuration file: ${GREEN}$SDDM_CONFIG_DIR/theme.conf${NC}"
    
    # Ask if user wants to test
    test_theme
    
    # Ask if user wants to enable SDDM
    enable_service
    
    echo -e "\n${GREEN}All done!${NC}"
    echo -e "You can customize your theme by editing:"
    echo -e "  ${YELLOW}$SDDM_THEMES_DIR/$THEME_NAME/theme.conf${NC}"
    echo -e "\nTo change the background image, replace:"
    echo -e "  ${YELLOW}$SDDM_THEMES_DIR/$THEME_NAME/assets/background.jpg${NC}"
}

# Run main function
main
