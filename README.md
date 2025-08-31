
# Minimal SDDM Theme

A clean, minimal, and modern SDDM login theme inspired by Hyprlock. Features a blurred background, circular avatar, smooth animations, and a simple layout with a focus on clarity and elegance.

![Theme Preview](https://pub-c6a134c8e1fd4881a475bf80bc0717ba.r2.dev/sddm-preview.png)

## ✨ Features

- **Live Clock** – Real-time clock display (large, centered)
- **Circular Avatar** – Clean, borderless user avatar
- **Smooth Animations** – Subtle shake on login error, animated transitions
- **Minimal UI** – No cards or borders, just content
- **Blurred Background** – High-quality blur with dark overlay
- **Japanese Welcome Text** – "愛してる、一秒一秒、毎分、毎時間、毎日" (I love you, every second, every minute, every hour, every day)

## 📦 What's Included

- **Background**: Blurred cityscape (`assets/background.jpg` or `assets/darkcityariel.png`)
- **Avatar**: Shadow profile image (`assets/avatar.jpg` or `assets/ronaldo-shadow.jpg`)
- **Main.qml**: Main theme file (all UI logic)
- **theme.conf**: Theme configuration
- **metadata.desktop**: Theme metadata

## 🚀 Quick Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/uzski/custom-sddm-theme.git
   cd custom-sddm-theme
   ```

2. **Run the installer:**
   ```bash
   sudo ./install.sh
   ```

3. **Follow the prompts to:**
   - Install the theme
   - Test it in preview mode
   - Enable SDDM as your display manager

That's it! The theme is ready to use with the included images.

## 🎨 Customization Guide

### Change the Background Image

Replace the default background with your own:

```bash
# Copy your image to the assets folder
cp /path/to/your/wallpaper.jpg assets/background.jpg

# If already installed, update the theme
sudo cp assets/background.jpg /usr/share/sddm/themes/hyprlock-style/assets/
```

**Tips:**
- Recommended resolution: 1920x1080 or higher
- Dark images work best with the theme's color scheme
- The theme automatically applies blur and overlay

### Change the Avatar Image

Replace the default avatar:

```bash
# Copy your avatar to the assets folder
cp /path/to/your/avatar.jpg assets/avatar.jpg

# If already installed, update the theme
sudo cp assets/avatar.jpg /usr/share/sddm/themes/hyprlock-style/assets/
```

**Tips:**
- Any size works (will be cropped to a circle)
- Square images look best
- High contrast images look great with the dark theme

### Customize Colors & Fonts

Edit `Main.qml` for color and font changes:

```qml
// Core color scheme (lines 8-11)
readonly property color textPrimary: "#FFFFFF"      // Main text
readonly property color textSecondary: Qt.rgba(255,255,255,0.9) // Subtle text
readonly property color textTertiary: Qt.rgba(255,255,255,0.6) // Placeholder text
readonly property string systemFont: "SF Pro Display, -apple-system, Helvetica Neue, sans-serif"
```

**Font:**
Change the font by editing the `systemFont` property (line 11):

```qml
readonly property string systemFont: "Your Font Here, sans-serif"
```

### Change the Welcome Text

Edit the greeting (line 74):

```qml
text: "愛してる、一秒一秒、毎分、毎時間、毎日"
```

Some alternatives:
- English: `text: "Welcome back"`
- Motivational: `text: "今日も頑張ろう"` (Let's do our best today)
- Minimal: `text: ""` (no text)
- Custom: `text: "Your message here"`

### Blur Effect

Adjust blur intensity in `Main.qml` (lines 32-39):

```qml
GaussianBlur {
    radius: 48  // Increase for more blur
    samples: 97 // Increase for smoother blur
}
```

### Password Field Size

Edit `Main.qml` (lines 92-93):

```qml
width: 280  // Make wider/narrower
height: 44  // Make taller/shorter
```

### Clock Format

Change time format in `Main.qml` (lines 61 & 168):

```qml
text: Qt.formatTime(new Date(), "h:mm")  // 24-hour
// Or for 12-hour with AM/PM:
text: Qt.formatTime(new Date(), "hh:mm AP")
```

## 🔧 Testing Your Changes

Test the theme without logging out:

```bash
# Test directly from your development folder
sddm-greeter --test-mode --theme .

# Or test installed version
sddm-greeter --test-mode --theme /usr/share/sddm/themes/hyprlock-style
```

Press `Ctrl+C` to exit test mode.

## 📁 File Structure

```
custom-sddm-theme/
├── assets/
│   ├── background.jpg    # Background image
│   └── avatar.jpg        # User avatar
├── Main.qml              # Main theme file
├── theme.conf            # Configuration
├── metadata.desktop      # Theme metadata
├── install.sh            # Installation script
└── README.md             # This file
```

## 🛠️ Troubleshooting

### Theme not appearing
```bash
# Check if SDDM is using the theme
cat /etc/sddm.conf.d/theme.conf

# Should show:
# [Theme]
# Current=hyprlock-style
```

### Images not showing
- Ensure images are in `assets/` folder
- Check file permissions: `ls -la /usr/share/sddm/themes/hyprlock-style/assets/`
- Images should be readable: `chmod 644 assets/*`

### Testing fails
- Install required packages:
  ```bash
  # Arch Linux
  sudo pacman -S sddm qt5-quickcontrols2 qt5-graphicaleffects
  
  # Ubuntu/Debian
  sudo apt install sddm qml-module-qtquick-controls2 qml-module-qtgraphicaleffects
  ```

## 📦 Requirements

- SDDM
- Qt 5.15+
- QtQuick Controls 2
- QtGraphicalEffects

## 📄 License

MIT License – Feel free to modify and share!

## 👤 Author

Created by **sean**

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Fork and create your own version
- Submit pull requests with improvements
- Share your custom color schemes
- Report issues

## 🙏 Credits

- Inspired by Hyprlock's aesthetic
- Dark city background and shadow avatar included as starter images
- SDDM and Qt/QML teams for the framework

---

**Enjoy your new minimal login screen!**
