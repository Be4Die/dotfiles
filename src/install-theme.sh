#!/bin/bash

cp -r ../assets/Graphite-dark ~/.local/share/themes/

mkdir -p ~/.config/gtk-3.0
cp ../config/gtk-3.0/gtk.css ~/.config/gtk-3.0/
cp -r ../assets/Graphite-dark/xfwm4 ~/.local/share/themes/Graphite-dark/