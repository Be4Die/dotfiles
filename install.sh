#!/bin/sh

set -e

# Сохраняем текущую директорию
ORIG_DIR=$(pwd)

# Обновление системы и установка пакетов
sudo xbps-install -Suy
sudo xbps-install -y dbus elogind gdm alacritty river Waybar wl-clipboard foot bemenu setxkbmap grim slurp curl unzip

# Включение сервисов
sudo ln -s /etc/sv/dbus /var/service/
sudo ln -s /etc/sv/elogind /var/service/
sudo ln -s /etc/sv/gdm /var/service/

# Установка Noto Nerd Font
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Noto.zip
unzip -o Noto.zip
rm Noto.zip
fc-cache -fv

# Возвращаемся в исходную директорию
cd "$ORIG_DIR"

# Копирование конфигураций
mkdir -p ~/.config
cp -r config/alacritty ~/.config/
cp -r config/river ~/.config/
cp -r config/waybar ~/.config/

# Права на исполнение для скрипта River
chmod +x ~/.config/river/init

# Настройка раскладки клавиатуры (us+ru)
localectl set-x11-keymap us,ru pc105 , grp:alt_shift_toggle

echo "Установка завершена! Перезагрузите систему."