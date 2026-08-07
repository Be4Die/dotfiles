#!/bin/bash
# Wlogout power menu script

# If wlogout is already running, kill it
if pgrep -x "wlogout" > /dev/null
then
    killall wlogout
else
    # Start wlogout with Frappe theme
    wlogout -b 2 -c 0 -r 0 -m 0 --layout ~/.config/wlogout/layout --css ~/.config/wlogout/style.css
fi
