# Custom Dark SDDM Theme

A modern, minimalist SDDM login screen theme with blur effects and customizable options.

## Features

- 🎨 Modern dark design with glassmorphism effects
- 🔐 Clean login interface with username and password fields
- 🖼️ Customizable background image with blur support
- ⏰ Live clock and date display
- 🎯 Session selector for multiple desktop environments
- ⚡ Power options (shutdown, reboot, suspend)
- 🎭 Smooth animations and transitions
- 🔧 Highly customizable through theme.conf
- 📱 Responsive design that works on all screen sizes

## Preview

![Theme Preview](preview.png)

## Installation

### Automatic Installation

1. Clone or download this theme to your local machine
2. Navigate to the theme directory
3. Run the installation script with sudo privileges:

```bash
cd ~/Development/custom-sddm-theme
sudo ./install.sh
```

The installer will:
- Check for SDDM installation
- Backup any existing theme with the same name
- Install the theme to `/usr/share/sddm/themes/`
- Configure SDDM to use the new theme
- Optionally enable SDDM as your display manager

### Manual Installation

1. Copy the theme directory to the SDDM themes folder:
```bash
sudo cp -r ~/Development/custom-sddm-theme /usr/share/sddm/themes/custom-dark-theme
```

2. Set proper permissions:
```bash
sudo chmod -R 755 /usr/share/sddm/themes/custom-dark-theme
```

3. Configure SDDM to use the theme:
```bash
sudo nano /etc/sddm.conf.d/theme.conf
```

Add the following content:
```ini
[Theme]
Current=custom-dark-theme
```

4. Enable SDDM service (if not already enabled):
```bash
sudo systemctl enable sddm
```

## Customization

### Quick Customization

Edit the `theme.conf` file to customize various aspects of the theme:

```bash
sudo nano /usr/share/sddm/themes/custom-dark-theme/theme.conf
```

### Customizable Options

#### Colors
- `accentColor` - Primary accent color for buttons and focus states
- `textColor` - Main text color
- `errorColor` - Color for error messages
- `inputBackgroundColor` - Background color for input fields
- `loginBoxColor` - Background color for the login container

#### Fonts
- `fontFamily` - Font family for all text
- `titleFontSize` - Welcome text size
- `timeFontSize` - Clock display size
- `inputFontSize` - Input field text size

#### Layout
- `loginBoxWidth` - Width of the login container
- `loginBoxHeight` - Height of the login container
- `cornerRadius` - Border radius for UI elements
- `buttonHeight` - Height of buttons
- `inputHeight` - Height of input fields

#### Features
- `showDateTime` - Show/hide clock and date
- `showAvatar` - Show/hide user avatar
- `showPowerButtons` - Show/hide power options
- `showSessionSelector` - Show/hide session selector
- `enableBlur` - Enable/disable blur effects
- `autoFocusPassword` - Auto-focus password field

### Changing the Background

Replace the background image:
```bash
sudo cp /path/to/your/image.jpg /usr/share/sddm/themes/custom-dark-theme/assets/background.jpg
```

Or edit `theme.conf` to point to a different image:
```ini
background=/path/to/your/wallpaper.jpg
```

### Changing the User Avatar

Replace the default avatar:
```bash
sudo cp /path/to/avatar.png /usr/share/sddm/themes/custom-dark-theme/assets/avatar.png
```

## Testing

Test the theme without logging out:
```bash
sddm-greeter --test-mode --theme /usr/share/sddm/themes/custom-dark-theme
```

Press `Ctrl+Alt+F2` to return to your session.

## Troubleshooting

### Theme not showing up
- Ensure SDDM is installed: `sudo pacman -S sddm`
- Check if the theme is in the correct directory: `ls /usr/share/sddm/themes/`
- Verify the configuration: `cat /etc/sddm.conf.d/theme.conf`

### Black screen or theme not loading
- Check the Main.qml file for syntax errors
- Ensure all required QML modules are installed: `sudo pacman -S qt5-quickcontrols2 qt5-graphicaleffects`
- Check SDDM logs: `journalctl -u sddm -e`

### Login fails
- Ensure your username and password are correct
- Check if the selected session exists
- Review system logs: `journalctl -xe`

## File Structure

```
custom-dark-theme/
├── assets/
│   ├── background.jpg    # Background image
│   └── avatar.png        # Default user avatar
├── components/           # Additional QML components (if needed)
├── Main.qml             # Main QML interface file
├── metadata.desktop     # Theme metadata
├── theme.conf          # Theme configuration
├── install.sh          # Installation script
└── README.md           # This file
```

## Requirements

- SDDM (Simple Desktop Display Manager)
- Qt 5.15 or higher
- QtQuick 2.15
- QtQuick.Controls 2.15
- QtGraphicalEffects 1.15

## License

This theme is released under the GPL-3.0 License.

## Author

Created by uzski

## Contributing

Feel free to fork this theme and create your own variations! Pull requests for improvements are welcome.

## Credits

- SDDM project for the display manager
- Qt/QML for the framework
- Arch Linux community for inspiration
