#!/bin/bash
# MacBook Pro Lid Switch Handler with exact brightness memory

ACTION="$1"

case "$ACTION" in
    close)
        # 1. Lock screen
        pidof hyprlock >/dev/null || hyprlock &
        sleep 0.2
        # 2. Save current brightness and turn off display
        brightnessctl -d gmux_backlight --save set 0% 2>/dev/null || true
        ;;
    open)
        # 1. Unlock GMUX bridge
        sudo /usr/local/bin/unlock-gmux 2>/dev/null || true
        # 2. Restore saved brightness
        brightnessctl -d gmux_backlight --restore 2>/dev/null || brightnessctl -d gmux_backlight set 50%
        ;;
esac
