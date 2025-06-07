#!/bin/sh

set -e

# Обновление системы и установка пакетов
sudo xbps-install -Suy
sudo xbps-install -y dbus elogind gdm alacritty river waybar wl-clipboard foot bemenu setxkbmap grim slurp nerd-fonts-Noto

# Включение сервисов
sudo ln -s /etc/sv/dbus /var/service/
sudo ln -s /etc/sv/elogind /var/service/
sudo ln -s /etc/sv/gdm /var/service/

# Копирование конфигураций
mkdir -p ~/.config
cp -r dots/alacritty ~/.config/
cp -r dots/river ~/.config/
cp -r dots/waybar ~/.config/

# Права на исполнение для скрипта River
chmod +x ~/.config/river/init

# Настройка раскладки клавиатуры (us+ru)
localectl set-x11-keymap us,ru pc105 , grp:alt_shift_toggle