#!/bin/bash

# Скрипт для тестирования GPU монитора

echo "═══════════════════════════════════════════════════"
echo "  GPU Monitor - Тест компонентов"
echo "═══════════════════════════════════════════════════"
echo ""

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для проверки
check_component() {
    local name="$1"
    local command="$2"
    
    printf "%-50s" "$name"
    
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ OK${NC}"
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        return 1
    fi
}

# Тест 1: PowerMetrics установлен
check_component "1. PowerMetrics установлен" "which powermetrics"

# Тест 2: Sudo без пароля
check_component "2. Sudo без пароля для powermetrics" "sudo -n powermetrics --version"

# Тест 3: SwiftBar установлен
check_component "3. SwiftBar установлен" "test -d /Applications/SwiftBar.app"

# Тест 4: Папка плагинов существует
check_component "4. Папка плагинов существует" "test -d ~/swiftbar-plugins"

# Тест 5: Скрипт GPU монитора существует
check_component "5. Скрипт GPU монитора существует" "test -f ~/swiftbar-plugins/gpu-monitor.2s.sh"

# Тест 6: Скрипт исполняемый
check_component "6. Скрипт имеет права выполнения" "test -x ~/swiftbar-plugins/gpu-monitor.2s.sh"

# Тест 7: LaunchAgent существует
check_component "7. LaunchAgent для автозапуска" "test -f ~/Library/LaunchAgents/com.swiftbar.app.plist"

echo ""
echo "═══════════════════════════════════════════════════"
echo "  Тест работы GPU монитора"
echo "═══════════════════════════════════════════════════"
echo ""

# Запуск скрипта
echo -e "${YELLOW}Запуск скрипта GPU монитора:${NC}"
echo ""
~/swiftbar-plugins/gpu-monitor.2s.sh
echo ""

# Тест PowerMetrics напрямую
echo "═══════════════════════════════════════════════════"
echo "  Тест PowerMetrics (первые 20 строк)"
echo "═══════════════════════════════════════════════════"
echo ""
echo -e "${YELLOW}Получение данных GPU:${NC}"
sudo powermetrics --samplers gpu_power -n 1 -i 1000 2>/dev/null | head -20
echo ""

# Проверка процессов
echo "═══════════════════════════════════════════════════"
echo "  Проверка запущенных процессов"
echo "═══════════════════════════════════════════════════"
echo ""

SWIFTBAR_RUNNING=$(ps aux | grep -v grep | grep SwiftBar | wc -l)
if [ "$SWIFTBAR_RUNNING" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} SwiftBar запущен"
else
    echo -e "${RED}✗${NC} SwiftBar не запущен"
fi

POWERMETRICS_RUNNING=$(ps aux | grep -v grep | grep powermetrics | wc -l)
echo "  Активных процессов powermetrics: $POWERMETRICS_RUNNING"

echo ""
echo "═══════════════════════════════════════════════════"
echo "  Информация о системе"
echo "═══════════════════════════════════════════════════"
echo ""

echo "macOS версия:"
sw_vers

echo ""
echo "GPU информация:"
system_profiler SPDisplaysDataType | grep -E "Chipset Model|VRAM"

echo ""
echo "═══════════════════════════════════════════════════"
echo "  Тест завершён"
echo "═══════════════════════════════════════════════════"

