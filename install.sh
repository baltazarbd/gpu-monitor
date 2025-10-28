#!/bin/bash

# GPU Monitor Installation Script
# Автоматическая установка GPU Monitor для macOS

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Функция для красивого вывода
print_header() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Проверка macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is only for macOS"
    exit 1
fi

print_header "GPU Monitor Installation"

echo "This script will install GPU Monitor on your macOS system"
echo ""
echo "What will be installed:"
echo "  • SwiftBar (if not installed)"
echo "  • GPU Monitor plugin"
echo "  • Sudo permissions for powermetrics"
echo "  • Auto-launch configuration (optional)"
echo ""
read -p "Continue with installation? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Installation cancelled"
    exit 0
fi

# Шаг 1: Проверка Homebrew
print_header "Step 1: Checking Homebrew"

if ! command -v brew &> /dev/null; then
    print_warning "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    print_success "Homebrew installed"
else
    print_success "Homebrew already installed"
fi

# Шаг 2: Установка SwiftBar
print_header "Step 2: Installing SwiftBar"

if [ -d "/Applications/SwiftBar.app" ]; then
    print_success "SwiftBar already installed"
else
    print_step "Installing SwiftBar..."
    brew install --cask swiftbar
    print_success "SwiftBar installed"
fi

# Шаг 3: Создание папки плагинов
print_header "Step 3: Setting up plugin folder"

PLUGIN_DIR="$HOME/swiftbar-plugins"
if [ ! -d "$PLUGIN_DIR" ]; then
    print_step "Creating plugin folder: $PLUGIN_DIR"
    mkdir -p "$PLUGIN_DIR"
    print_success "Plugin folder created"
else
    print_success "Plugin folder already exists"
fi

# Шаг 4: Копирование плагина
print_header "Step 4: Installing GPU Monitor plugin"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PLUGIN_FILE="$SCRIPT_DIR/gpu-monitor.2s.sh"

if [ ! -f "$PLUGIN_FILE" ]; then
    print_error "Plugin file not found: $PLUGIN_FILE"
    exit 1
fi

print_step "Copying plugin to $PLUGIN_DIR"
cp "$PLUGIN_FILE" "$PLUGIN_DIR/"
chmod +x "$PLUGIN_DIR/gpu-monitor.2s.sh"
print_success "Plugin installed"

# Шаг 5: Настройка sudo прав
print_header "Step 5: Configuring sudo permissions"

print_warning "This step requires your password to configure passwordless sudo for powermetrics"
echo ""

SUDOERS_FILE="/etc/sudoers.d/powermetrics"
if [ -f "$SUDOERS_FILE" ]; then
    print_success "Sudo permissions already configured"
else
    print_step "Adding sudo rule for powermetrics..."
    echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/powermetrics" | sudo tee "$SUDOERS_FILE" > /dev/null
    sudo chmod 440 "$SUDOERS_FILE"
    print_success "Sudo permissions configured"
fi

# Шаг 6: Настройка SwiftBar
print_header "Step 6: Configuring SwiftBar"

print_step "Opening SwiftBar..."
open -a SwiftBar

echo ""
echo -e "${YELLOW}IMPORTANT:${NC} Please configure SwiftBar manually:"
echo "  1. Click on SwiftBar icon in menu bar"
echo "  2. Select 'Preferences' → 'Choose Plugin Folder...'"
echo "  3. Select: $PLUGIN_DIR"
echo ""
read -p "Press Enter after you've configured SwiftBar plugin folder..."

# Шаг 7: Автозапуск (опционально)
print_header "Step 7: Auto-launch configuration (optional)"

read -p "Do you want SwiftBar to start automatically on login? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    LAUNCH_AGENT="$HOME/Library/LaunchAgents/com.swiftbar.app.plist"
    
    if [ -f "$LAUNCH_AGENT" ]; then
        print_success "Auto-launch already configured"
    else
        print_step "Creating LaunchAgent..."
        cat > "$LAUNCH_AGENT" << 'EOF'
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
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF
        launchctl load "$LAUNCH_AGENT" 2>/dev/null || true
        print_success "Auto-launch configured"
    fi
else
    print_warning "Auto-launch skipped"
fi

# Шаг 8: Тестирование
print_header "Step 8: Testing installation"

print_step "Testing GPU Monitor plugin..."
if "$PLUGIN_DIR/gpu-monitor.2s.sh" > /dev/null 2>&1; then
    print_success "Plugin is working correctly"
else
    print_error "Plugin test failed. Please check the configuration."
fi

# Финальное сообщение
print_header "Installation Complete!"

echo ""
echo -e "${GREEN}✓ GPU Monitor has been successfully installed!${NC}"
echo ""
echo "You should see the GPU monitor in your menu bar:"
echo -e "  ${CYAN}🔥XX% ⚡XXXMHz ⚙️X.XW${NC}"
echo ""
echo "Color indicators:"
echo -e "  ${GREEN}🟢 Green${NC}  - load < 50%"
echo -e "  ${YELLOW}🟠 Orange${NC} - load 50-80%"
echo -e "  ${RED}🔴 Red${NC}    - load > 80%"
echo ""
echo "Configuration:"
echo "  Plugin folder: $PLUGIN_DIR"
echo "  Plugin file:   $PLUGIN_DIR/gpu-monitor.2s.sh"
echo ""
echo "Useful commands:"
echo "  Test plugin:   $PLUGIN_DIR/gpu-monitor.2s.sh"
echo "  Refresh:       Click on the indicator → 'Refresh'"
echo "  Uninstall:     $SCRIPT_DIR/scripts/uninstall.sh"
echo ""
echo "Documentation:"
echo "  README:        $SCRIPT_DIR/README.md"
echo "  Installation:  $SCRIPT_DIR/docs/INSTALLATION.md"
echo "  Troubleshoot:  $SCRIPT_DIR/docs/TROUBLESHOOTING.md"
echo ""
echo -e "${CYAN}GitHub: https://github.com/baltazarbd/gpu-monitor${NC}"
echo ""
print_success "Enjoy monitoring your GPU! 🚀"
echo ""

