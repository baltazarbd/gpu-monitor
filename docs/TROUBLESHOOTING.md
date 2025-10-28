# GPU Monitor - Устранение проблем

## Проблема: Запрашивается пароль sudo

### Решение

Добавьте правило в sudoers для запуска powermetrics без пароля:

```bash
echo "bprokin ALL=(ALL) NOPASSWD: /usr/bin/powermetrics" | sudo tee /etc/sudoers.d/powermetrics
sudo chmod 440 /etc/sudoers.d/powermetrics
```

Или используйте visudo:
```bash
sudo visudo -f /etc/sudoers.d/powermetrics
```

И добавьте строку:
```
bprokin ALL=(ALL) NOPASSWD: /usr/bin/powermetrics
```

## Проблема: SwiftBar не запускается автоматически

### Проверка статуса

```bash
launchctl list | grep swiftbar
```

### Переустановка LaunchAgent

```bash
# Удалить старый
launchctl unload ~/Library/LaunchAgents/com.swiftbar.app.plist

# Создать заново
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
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF

# Загрузить
launchctl load ~/Library/LaunchAgents/com.swiftbar.app.plist
```

## Проблема: Плагин не работает

### Проверка скрипта вручную

```bash
~/swiftbar-plugins/gpu-monitor.2s.sh
```

Должен вывести что-то вроде:
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

### Проверка прав выполнения

```bash
chmod +x ~/swiftbar-plugins/gpu-monitor.2s.sh
```

### Проверка формата файла

Убедитесь, что файл имеет Unix-окончания строк:
```bash
file ~/swiftbar-plugins/gpu-monitor.2s.sh
```

Если показывает CRLF, исправьте:
```bash
dos2unix ~/swiftbar-plugins/gpu-monitor.2s.sh
```

## Проблема: Данные показываются неправильно

### Проверка powermetrics напрямую

```bash
sudo powermetrics --samplers gpu_power -n 1 -i 1000
```

Должна показаться информация о GPU. Если нет - проблема с доступом к GPU или драйверами.

### Проверка grep паттернов

```bash
sudo powermetrics --samplers gpu_power -n 1 -i 1000 | grep "GPU HW active residency:"
```

Должно показать процент активности.

## Проблема: Высокое потребление CPU

### Увеличение интервала обновления

Переименуйте плагин для более редких обновлений:

```bash
mv ~/swiftbar-plugins/gpu-monitor.2s.sh ~/swiftbar-plugins/gpu-monitor.5s.sh
```

Интервалы:
- `.1s.sh` - каждую секунду
- `.2s.sh` - каждые 2 секунды (по умолчанию)
- `.5s.sh` - каждые 5 секунд
- `.10s.sh` - каждые 10 секунд
- `.30s.sh` - каждые 30 секунд
- `.1m.sh` - каждую минуту

### Оптимизация powermetrics

В скрипте используется `-n 1` для однократного вывода данных. Это оптимальный вариант.

## Проблема: SwiftBar не видит плагины

### Проверка пути к папке плагинов

1. Откройте SwiftBar → Preferences
2. Проверьте "Plugin Folder"
3. Должен быть: `/Users/bprokin/swiftbar-plugins`

### Проверка прав доступа к папке

```bash
ls -la ~/swiftbar-plugins/
```

Все файлы `.sh` должны иметь права выполнения (`-rwxr-xr-x`).

### Перезагрузка плагинов

В меню SwiftBar выберите "Refresh All"

## Проблема: Иконки не отображаются

Это нормально, если терминал не поддерживает эмодзи. В строке меню macOS они отображаются корректно.

## Тестирование отдельных компонентов

### Тест 1: PowerMetrics доступен

```bash
which powermetrics
# Должен вывести: /usr/bin/powermetrics
```

### Тест 2: Sudo работает без пароля

```bash
sudo powermetrics --version
# Не должен запрашивать пароль
```

### Тест 3: SwiftBar установлен

```bash
ls -la /Applications/SwiftBar.app
```

### Тест 4: Скрипт исполняемый

```bash
test -x ~/swiftbar-plugins/gpu-monitor.2s.sh && echo "OK" || echo "NOT EXECUTABLE"
```

## Логи и отладка

### Включение debug режима в скрипте

Добавьте в начало скрипта (после `#!/bin/bash`):

```bash
set -x  # Включить debug вывод
exec 2>>/tmp/gpu-monitor.log  # Логировать ошибки
```

Затем проверьте лог:
```bash
tail -f /tmp/gpu-monitor.log
```

### Консоль SwiftBar

SwiftBar показывает ошибки плагинов в своём интерфейсе. Проверьте:
1. Кликните на иконку SwiftBar
2. Выберите "Open Plugin Folder"
3. Найдите ваш плагин и проверьте сообщения об ошибках

## Полная переустановка

Если ничего не помогает:

```bash
# 1. Удалить всё
brew uninstall --cask swiftbar
rm -rf ~/swiftbar-plugins
launchctl unload ~/Library/LaunchAgents/com.swiftbar.app.plist
rm ~/Library/LaunchAgents/com.swiftbar.app.plist

# 2. Установить заново
brew install --cask swiftbar
mkdir -p ~/swiftbar-plugins

# 3. Скопировать скрипт (используйте бэкап из ~/swiftbar-plugins/gpu-monitor/)

# 4. Настроить автозапуск (см. INSTALLATION.md)
```

## Получение помощи

Если проблема не решена:

1. Соберите информацию:
   ```bash
   echo "macOS версия:"
   sw_vers
   echo -e "\nSwiftBar версия:"
   /Applications/SwiftBar.app/Contents/MacOS/SwiftBar --version
   echo -e "\nТест скрипта:"
   ~/swiftbar-plugins/gpu-monitor.2s.sh
   echo -e "\nТест powermetrics:"
   sudo powermetrics --samplers gpu_power -n 1 -i 1000 | head -30
   ```

2. Сохраните вывод в файл
3. Опишите проблему с приложением вывода команд

## Известные ограничения

- На Virtual Machines может не работать (требуется реальное GPU)
- На старых Mac без GPU может показывать нули
- Intel vs Apple Silicon могут показывать разные метрики

