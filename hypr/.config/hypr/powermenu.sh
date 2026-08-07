#!/bin/bash
# Wlogout power menu script

# If wlogout is already running, kill it
if pgrep -x "wlogout" > /dev/null
then
    killall wlogout
    exit 0
fi

HOSTNAME=$(hostname)

if [ "$HOSTNAME" = "cachyos-laptop" ]; then
    # Laptop: 3 buttons (Suspend, Shutdown, Reboot)
    # Margins tuned for 3 buttons to make them square
    wlogout -b 3 -c 40 -r 40 -T 350 -B 350 -L 200 -R 200 --layout ~/.config/wlogout/layout_laptop --css ~/.config/wlogout/style.css
else
    # PC: 2 buttons (Shutdown, Reboot)
    # Margins tuned for 2 buttons to make them square (larger side margins)
    wlogout -b 2 -c 40 -r 40 -T 350 -B 350 -L 400 -R 400 --layout ~/.config/wlogout/layout_pc --css ~/.config/wlogout/style.css
fi
