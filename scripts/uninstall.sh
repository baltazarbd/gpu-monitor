#!/bin/bash

# Скрипт для удаления GPU Monitor

echo "═══════════════════════════════════════════════════"
echo "  GPU Monitor - Удаление"
echo "═══════════════════════════════════════════════════"
echo ""

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Подтверждение
echo -e "${YELLOW}Это удалит следующие компоненты:${NC}"
echo "  - SwiftBar приложение"
echo "  - Папку ~/swiftbar-plugins"
echo "  - LaunchAgent для автозапуска"
echo "  - Правила sudoers для powermetrics"
echo ""
read -p "Вы уверены? (yes/no): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "Удаление отменено."
    exit 0
fi

echo ""
echo "Начинаем удаление..."
echo ""

# 1. Остановка и удаление LaunchAgent
if [ -f ~/Library/LaunchAgents/com.swiftbar.app.plist ]; then
    echo -n "1. Остановка автозапуска SwiftBar... "
    launchctl unload ~/Library/LaunchAgents/com.swiftbar.app.plist 2>/dev/null
    rm ~/Library/LaunchAgents/com.swiftbar.app.plist
    echo -e "${GREEN}✓${NC}"
else
    echo "1. LaunchAgent не найден (пропускаем)"
fi

# 2. Закрытие SwiftBar
echo -n "2. Закрытие SwiftBar... "
killall SwiftBar 2>/dev/null
echo -e "${GREEN}✓${NC}"

# 3. Удаление SwiftBar через Homebrew
if brew list --cask swiftbar &>/dev/null; then
    echo -n "3. Удаление SwiftBar... "
    brew uninstall --cask swiftbar 2>/dev/null
    echo -e "${GREEN}✓${NC}"
else
    echo "3. SwiftBar не установлен через Homebrew (пропускаем)"
fi

# 4. Удаление папки плагинов
if [ -d ~/swiftbar-plugins ]; then
    echo -n "4. Удаление папки плагинов... "
    rm -rf ~/swiftbar-plugins
    echo -e "${GREEN}✓${NC}"
else
    echo "4. Папка плагинов не найдена (пропускаем)"
fi

# 5. Удаление правил sudoers (требует sudo)
if [ -f /etc/sudoers.d/powermetrics ]; then
    echo -n "5. Удаление правил sudoers (требуется пароль)... "
    sudo rm /etc/sudoers.d/powermetrics
    echo -e "${GREEN}✓${NC}"
else
    echo "5. Правила sudoers не найдены (пропускаем)"
fi

echo ""
echo "═══════════════════════════════════════════════════"
echo -e "${GREEN}GPU Monitor успешно удалён!${NC}"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Компоненты, которые остались (если были):"
echo "  - Любые другие приложения в /Applications/"
echo "  - Системные настройки macOS"
echo ""

