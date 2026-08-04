#!/bin/bash

# Путь к новому стилю
STYLE="$HOME/.config/wofi/power-menu/catppuccin_frappe/style.css"

# Пункты меню с иконками
options="⏻  Выключить
  Перезагрузить
⏾  Ждущий режим
󰤁  Гибернация
󰍃  Выйти"

# Вызываем Wofi (увеличили --lines до 5 и --height до 335)
choice=$(echo -e "$options" | wofi --dmenu \
    --width 380 \
    --height 335 \
    --lines 5 \
    --location center \
    --prompt "⚡ Система" \
    --hide-search \
    --cache-file /dev/null \
    --style "$STYLE")

# Выполняем команду
case "$choice" in
    *"Выключить") systemctl poweroff ;;
    *"Перезагрузить") systemctl reboot ;;
    *"Ждущий режим") systemctl suspend ;;
    *"Гибернация") systemctl hibernate ;;
    *"Выйти") hyprctl dispatch exit ;;
esac
