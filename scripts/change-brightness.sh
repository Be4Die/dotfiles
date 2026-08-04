#!/bin/bash
DIR="$1"
STEP="${2:-5%}"
for dev in /sys/class/backlight/*; do
    if [ -e "$dev/brightness" ]; then
        bname="$(basename "$dev")"
        brightnessctl -d "$bname" set "${STEP}${DIR}" 2>/dev/null
    fi
done
