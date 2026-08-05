#!/bin/bash
# Cycles active window state: Tiled -> Maximized -> Floating -> Tiled

WINDOW_INFO=$(hyprctl activewindow -j)

# Check if we have an active window
if [[ "$WINDOW_INFO" == "{}" ]]; then
    exit 0
fi

# Extract properties using jq (which is usually installed, but we can use grep/awk to be safe if jq is missing)
IS_FLOATING=$(echo "$WINDOW_INFO" | grep -q '"floating": true' && echo "true" || echo "false")
FULLSCREEN_VAL=$(echo "$WINDOW_INFO" | grep '"fullscreen":' | awk '{print $2}' | tr -d ',')

# State logic:
# Tiled (fullscreen 0, floating false) -> Maximized (fullscreen 1)
# Maximized (fullscreen 1 or 2) -> Floating (fullscreen 0, floating true)
# Floating (fullscreen 0, floating true) -> Tiled (fullscreen 0, floating false)

if [[ "$FULLSCREEN_VAL" == "1" || "$FULLSCREEN_VAL" == "2" ]]; then
    # Currently Maximized/Fullscreen -> Change to Floating
    hyprctl dispatch "hl.dsp.window.fullscreen(0)"
    hyprctl dispatch "hl.dsp.window.float({ action = 'on' })"
    hyprctl dispatch "hl.dsp.window.center()"
elif [[ "$IS_FLOATING" == "true" ]]; then
    # Currently Floating -> Change to Tiled
    hyprctl dispatch "hl.dsp.window.float({ action = 'off' })"
else
    # Currently Tiled (Normal) -> Change to Maximized (fullscreen 1)
    hyprctl dispatch "hl.dsp.window.fullscreen(1)"
fi
