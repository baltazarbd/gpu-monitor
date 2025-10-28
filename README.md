# GPU Monitor for macOS

![macOS](https://img.shields.io/badge/macOS-10.15+-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![SwiftBar](https://img.shields.io/badge/SwiftBar-2.0+-orange)

Real-time GPU monitoring directly in your macOS menu bar with beautiful icons and color-coded load indicators.

## 🎯 Features

- 🔥 **GPU Activity** percentage with color indication
- ⚡ **GPU Frequency** in real-time (MHz)
- ⚙️ **Power Consumption** (Watts)
- 🎨 **Automatic color indication** (green/orange/red)
- 🚀 **Auto-launch** on system startup
- ⏱️ **Updates every 2 seconds**

## 📸 Preview

Displays in menu bar:
```
🔥45% ⚡890MHz ⚙️2.1W
```

Color changes based on load:
- 🟢 **Green** - load < 50%
- 🟠 **Orange** - load 50-80%
- 🔴 **Red** - load > 80%

## 📋 Requirements

- macOS 10.15 (Catalina) or newer
- SwiftBar 2.0+
- Sudo privileges for `powermetrics` command

## 🚀 Quick Installation

### Automatic Installation (Recommended)

Run the installation script:

```bash
git clone https://github.com/baltazarbd/gpu-monitor.git
cd gpu-monitor
./install.sh
```

The script will automatically:
- ✅ Install SwiftBar (if needed)
- ✅ Set up the plugin folder
- ✅ Install GPU Monitor plugin
- ✅ Configure sudo permissions
- ✅ Set up auto-launch (optional)

### Manual Installation

If you prefer to install manually:

#### Step 1: Install SwiftBar

```bash
brew install --cask swiftbar
```

#### Step 2: Create plugins folder

```bash
mkdir -p ~/swiftbar-plugins
```

#### Step 3: Copy the plugin

Copy `gpu-monitor.2s.sh` to `~/swiftbar-plugins/`:

```bash
cp gpu-monitor.2s.sh ~/swiftbar-plugins/
chmod +x ~/swiftbar-plugins/gpu-monitor.2s.sh
```

#### Step 4: Configure sudo permissions

Add rule to run `powermetrics` without password:

```bash
echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/powermetrics" | sudo tee /etc/sudoers.d/powermetrics
sudo chmod 440 /etc/sudoers.d/powermetrics
```

#### Step 5: Configure SwiftBar

1. Launch SwiftBar
2. Click on SwiftBar icon in menu bar
3. Select **Preferences** → **Choose Plugin Folder...**
4. Specify path: `~/swiftbar-plugins`

Done! 🎉 GPU Monitor will appear in your menu bar.

## 📁 Project Structure

```
gpu-monitor/
├── README.md                    # This file
├── install.sh                   # Automatic installation script
├── gpu-monitor.2s.sh            # Main SwiftBar plugin
├── docs/
│   ├── INSTALLATION.md          # Detailed installation guide
│   └── TROUBLESHOOTING.md       # Troubleshooting guide
└── scripts/
    ├── test-gpu-monitor.sh      # Test script
    └── uninstall.sh             # Uninstall script
```

## 🔧 Configuration

### Change update interval

Rename the plugin file, changing the value in the name:

- `gpu-monitor.1s.sh` - every second
- `gpu-monitor.2s.sh` - every 2 seconds (default)
- `gpu-monitor.5s.sh` - every 5 seconds
- `gpu-monitor.10s.sh` - every 10 seconds

Example:
```bash
mv ~/swiftbar-plugins/gpu-monitor.2s.sh ~/swiftbar-plugins/gpu-monitor.5s.sh
```

### Auto-launch SwiftBar

Create LaunchAgent for automatic startup:

```bash
cat > ~/Library/LaunchAgents/com.swiftbar.app.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.swiftbar.app</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Applications/SwiftBar.app/Contents/MacOS/SwiftBar</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

launchctl load ~/Library/LaunchAgents/com.swiftbar.app.plist
```

## 🧪 Testing

Run the test script to check all components:

```bash
./scripts/test-gpu-monitor.sh
```

Or test the plugin manually:

```bash
~/swiftbar-plugins/gpu-monitor.2s.sh
```

Expected output:
```
🔥45% ⚡890MHz ⚙️2.1W | color=green
---
GPU Monitor
---
🔥 GPU Active: 45.2%
⚡ Frequency: 890 MHz
⚙️  Power: 2.1 W
---
Refresh | refresh=true terminal=false
```

## 🐛 Troubleshooting

### Issue: Sudo password is requested

See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md#проблема-запрашивается-пароль-sudo)

### Issue: Plugin doesn't display

1. Check execute permissions: `chmod +x ~/swiftbar-plugins/gpu-monitor.2s.sh`
2. Check plugin folder path in SwiftBar preferences
3. Restart SwiftBar

### Issue: Shows "0%" or empty data

Check powermetrics operation:
```bash
sudo powermetrics --samplers gpu_power -n 1 -i 1000
```

Full troubleshooting guide: [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## 🗑️ Uninstallation

For complete removal, use the script:

```bash
./scripts/uninstall.sh
```

Or manually:

```bash
# Stop auto-launch
launchctl unload ~/Library/LaunchAgents/com.swiftbar.app.plist
rm ~/Library/LaunchAgents/com.swiftbar.app.plist

# Remove SwiftBar
brew uninstall --cask swiftbar

# Remove plugins
rm -rf ~/swiftbar-plugins

# Remove sudo permissions
sudo rm /etc/sudoers.d/powermetrics
```

## 📊 How It Works

The plugin uses the system utility `powermetrics` to gather GPU data:

1. **Data Collection**: Every N seconds, `powermetrics --samplers gpu_power` is executed
2. **Parsing**: Metrics are extracted using `grep` and `awk`
3. **Formatting**: Data is formatted with icons and colors
4. **Display**: SwiftBar shows the result in the menu bar

## 🔒 Security

The script requires sudo privileges only for the `powermetrics` command. This is safe because:

- Sudoers rule is limited to only one command
- No write operations are performed
- Only reads GPU metrics

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## 📝 License

MIT License - see LICENSE file

## 👨‍💻 Author

**baltazarbd**

## 🙏 Acknowledgments

- [SwiftBar](https://github.com/swiftbar/SwiftBar) - for the excellent menu bar application tool
- Apple `powermetrics` - for providing GPU data

## 📚 Additional Resources

- [SwiftBar Documentation](https://github.com/swiftbar/SwiftBar)
- [powermetrics man page](https://www.unix.com/man-page/osx/1/powermetrics/)
- [Detailed Installation Guide](docs/INSTALLATION.md)
- [Troubleshooting Guide](docs/TROUBLESHOOTING.md)

---

**Note**: This plugin is designed specifically for Apple Silicon (M1/M2/M3/M4) Macs, but also works on Intel Macs with GPU support.
