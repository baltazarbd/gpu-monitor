#!/bin/bash

# <xbar.title>GPU Monitor</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>bprokin</xbar.author>
# <xbar.desc>Displays GPU utilization, frequency, and power consumption</xbar.desc>
# <xbar.dependencies>powermetrics</xbar.dependencies>

# Получаем данные GPU через powermetrics
GPU_DATA=$(sudo powermetrics --samplers gpu_power -n 1 -i 1000 2>/dev/null)

# Извлекаем активность GPU
GPU_ACTIVE=$(echo "$GPU_DATA" | grep "GPU HW active residency:" | head -1 | sed -E 's/.*: ([0-9.]+)%.*/\1/')

# Извлекаем частоту
GPU_FREQ=$(echo "$GPU_DATA" | grep "GPU HW active frequency:" | head -1 | sed -E 's/.*: ([0-9]+) MHz.*/\1/')

# Извлекаем потребление энергии
GPU_POWER=$(echo "$GPU_DATA" | grep "GPU Power:" | head -1 | sed -E 's/.*: ([0-9]+) mW.*/\1/')

# Если данные не получены, показываем заглушку
if [ -z "$GPU_ACTIVE" ]; then
    GPU_ACTIVE="0"
fi
if [ -z "$GPU_FREQ" ]; then
    GPU_FREQ="0"
fi
if [ -z "$GPU_POWER" ]; then
    GPU_POWER="0"
fi

# Конвертируем в ватты
GPU_POWER_W=$(awk "BEGIN {printf \"%.1f\", $GPU_POWER/1000}")

# Цвет в зависимости от нагрузки
GPU_ACTIVE_INT=$(printf "%.0f" "$GPU_ACTIVE")
if [ "$GPU_ACTIVE_INT" -gt 80 ]; then
    COLOR="red"
elif [ "$GPU_ACTIVE_INT" -gt 50 ]; then
    COLOR="orange"
else
    COLOR="green"
fi

# Форматируем вывод для строки меню - показываем все параметры
echo "🔥${GPU_ACTIVE_INT}% ⚡${GPU_FREQ}MHz ⚙️${GPU_POWER_W}W | color=$COLOR"

echo "---"
echo "GPU Monitor"
echo "---"
printf "🔥 GPU Active: %s%%\n" "$GPU_ACTIVE"
printf "⚡ Frequency: %s MHz\n" "$GPU_FREQ"
printf "⚙️  Power: %s W\n" "$GPU_POWER_W"
echo "---"
echo "Refresh | refresh=true terminal=false"

