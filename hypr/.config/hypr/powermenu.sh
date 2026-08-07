#!/bin/bash
# Wlogout power menu script

# If wlogout is already running, kill it
if pgrep -x "wlogout" > /dev/null
then
    killall wlogout
else
    # Start wlogout with Frappe theme, compact grid (3 columns) and large margins
    wlogout -b 3 -c 40 -r 40 -T 300 -B 300 -L 300 -R 300 --layout ~/.config/wlogout/layout --css ~/.config/wlogout/style.css
fi
