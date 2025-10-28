# GPU Monitor для macOS

![macOS](https://img.shields.io/badge/macOS-10.15+-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![SwiftBar](https://img.shields.io/badge/SwiftBar-2.0+-orange)

Мониторинг GPU в реальном времени прямо в строке меню macOS с красивыми иконками и цветовой индикацией нагрузки.

## 🎯 Возможности

- 🔥 **Активность GPU** в процентах с цветовой индикацией
- ⚡ **Частота GPU** в реальном времени (MHz)
- ⚙️ **Потребление энергии** (Watts)
- 🎨 **Автоматическая цветовая индикация** (зелёный/оранжевый/красный)
- 🚀 **Автозапуск** при старте системы
- ⏱️ **Обновление каждые 2 секунды**

## 📸 Превью

В строке меню отображается:
```
🔥45% ⚡890MHz ⚙️2.1W
```

Цвет меняется в зависимости от нагрузки:
- 🟢 **Зелёный** - нагрузка < 50%
- 🟠 **Оранжевый** - нагрузка 50-80%
- 🔴 **Красный** - нагрузка > 80%

## 📋 Требования

- macOS 10.15 (Catalina) или новее
- SwiftBar 2.0+
- Права sudo для команды `powermetrics`

## 🚀 Быстрая установка

### Шаг 1: Установка SwiftBar

```bash
brew install --cask swiftbar
```

### Шаг 2: Создание папки плагинов

```bash
mkdir -p ~/swiftbar-plugins
```

### Шаг 3: Копирование плагина

Скопируйте файл `gpu-monitor.2s.sh` в `~/swiftbar-plugins/`:

```bash
cp gpu-monitor.2s.sh ~/swiftbar-plugins/
chmod +x ~/swiftbar-plugins/gpu-monitor.2s.sh
```

### Шаг 4: Настройка прав sudo

Добавьте правило для запуска `powermetrics` без пароля:

```bash
echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/powermetrics" | sudo tee /etc/sudoers.d/powermetrics
sudo chmod 440 /etc/sudoers.d/powermetrics
```

### Шаг 5: Настройка SwiftBar

1. Запустите SwiftBar
2. Кликните на иконку SwiftBar в строке меню
3. Выберите **Preferences** → **Choose Plugin Folder...**
4. Укажите путь: `~/swiftbar-plugins`

Готово! 🎉 GPU Monitor появится в строке меню.

## 📁 Структура проекта

```
gpu-monitor/
├── README.md                    # Этот файл
├── gpu-monitor.2s.sh            # Основной плагин SwiftBar
├── docs/
│   ├── INSTALLATION.md          # Детальная инструкция установки
│   └── TROUBLESHOOTING.md       # Решение проблем
└── scripts/
    ├── test-gpu-monitor.sh      # Скрипт тестирования
    └── uninstall.sh             # Скрипт удаления
```

## 🔧 Настройка

### Изменение интервала обновления

Переименуйте файл плагина, изменив значение в имени:

- `gpu-monitor.1s.sh` - каждую секунду
- `gpu-monitor.2s.sh` - каждые 2 секунды (по умолчанию)
- `gpu-monitor.5s.sh` - каждые 5 секунд
- `gpu-monitor.10s.sh` - каждые 10 секунд

Пример:
```bash
mv ~/swiftbar-plugins/gpu-monitor.2s.sh ~/swiftbar-plugins/gpu-monitor.5s.sh
```

### Автозапуск SwiftBar

Создайте LaunchAgent для автоматического запуска при старте системы:

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

## 🧪 Тестирование

Запустите скрипт тестирования для проверки всех компонентов:

```bash
./scripts/test-gpu-monitor.sh
```

Или протестируйте плагин вручную:

```bash
~/swiftbar-plugins/gpu-monitor.2s.sh
```

Должен вывести:
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

## 🐛 Устранение проблем

### Проблема: Запрашивается пароль sudo

См. [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md#проблема-запрашивается-пароль-sudo)

### Проблема: Плагин не отображается

1. Проверьте права выполнения: `chmod +x ~/swiftbar-plugins/gpu-monitor.2s.sh`
2. Проверьте путь к папке плагинов в настройках SwiftBar
3. Перезапустите SwiftBar

### Проблема: Показывает "0%" или пустые данные

Проверьте работу powermetrics:
```bash
sudo powermetrics --samplers gpu_power -n 1 -i 1000
```

Полный список решений: [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## 🗑️ Удаление

Для полного удаления используйте скрипт:

```bash
./scripts/uninstall.sh
```

Или вручную:

```bash
# Остановить автозапуск
launchctl unload ~/Library/LaunchAgents/com.swiftbar.app.plist
rm ~/Library/LaunchAgents/com.swiftbar.app.plist

# Удалить SwiftBar
brew uninstall --cask swiftbar

# Удалить плагины
rm -rf ~/swiftbar-plugins

# Удалить права sudo
sudo rm /etc/sudoers.d/powermetrics
```

## 📊 Как это работает

Плагин использует системную утилиту `powermetrics` для получения данных о GPU:

1. **Сбор данных**: Каждые N секунд запускается `powermetrics --samplers gpu_power`
2. **Парсинг**: Извлекаются метрики через `grep` и `sed`
3. **Форматирование**: Данные форматируются с иконками и цветами
4. **Отображение**: SwiftBar показывает результат в строке меню

## 🔒 Безопасность

Скрипт требует прав sudo только для команды `powermetrics`. Это безопасно, так как:

- Правило sudoers ограничено только одной командой
- Не выполняется никаких операций записи
- Только чтение метрик GPU

## 🤝 Вклад в проект

Принимаются pull requests! Для крупных изменений сначала откройте issue для обсуждения.

## 📝 Лицензия

MIT License - см. файл LICENSE

## 👨‍💻 Автор

**bprokin**

## 🙏 Благодарности

- [SwiftBar](https://github.com/swiftbar/SwiftBar) - за отличный инструмент для создания menu bar приложений
- Apple `powermetrics` - за предоставление данных о GPU

## 📚 Дополнительные ресурсы

- [Документация SwiftBar](https://github.com/swiftbar/SwiftBar)
- [powermetrics man page](https://www.unix.com/man-page/osx/1/powermetrics/)
- [Детальная установка](docs/INSTALLATION.md)
- [Решение проблем](docs/TROUBLESHOOTING.md)

---

**Примечание**: Этот плагин разработан специально для Apple Silicon (M1/M2/M3/M4) Mac, но также работает на Intel Mac с поддержкой GPU.

