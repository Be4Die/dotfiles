#!/usr/bin/env bash

# Detect external monitor (anything that is not eDP-1)
EXTERNAL_MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.name != "eDP-1") | .name' | head -n 1)

if [ -z "$EXTERNAL_MONITOR" ]; then
    dunstify -u low -a "Display" -i video-display "Mirror Mode" "No external monitor detected"
    exit 0
fi

# Check if wl-mirror is currently running
if pgrep -x "wl-mirror" > /dev/null; then
    # Stop mirroring
    killall wl-mirror
    dunstify -u low -a "Display" -i video-display "Display Mode" "Extended (Dual Screen)"
else
    # Start mirroring
    # Run wl-mirror for the internal screen
    wl-mirror -b screencopy-shm --fullscreen-output "$EXTERNAL_MONITOR" eDP-1 &
    
    dunstify -u low -a "Display" -i video-display "Display Mode" "Mirrored (Projector Mode)"
fi
