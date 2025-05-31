#!/bin/bash

install_from_git() {
    local repo_url="$1"
    local install_cmd="$2"
    local project_name=$(basename "$repo_url" .git)
    
    echo "Установка $project_name..."
    temp_dir=$(mktemp -d)
    
    # Клонирование репозитория
    if ! git clone --depth 1 "$repo_url" "$temp_dir"; then
        echo "Ошибка клонирования $project_name"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Выполнение команды установки
    (
        cd "$temp_dir" || return 1
        eval "$install_cmd"
    )
    
    local status=$?
    
    # Очистка
    sudo rm -rf "$temp_dir"
    if [ $status -eq 0 ]; then
        echo "$project_name успешно установлен"
    else
        echo "Ошибка установки $project_name"
    fi
    
    return $status
}

sudo xbps-install -Syu

# --- Установка темы ---
sudo xbps-install sassc

install_from_git "https://github.com/vinceliuice/Graphite-gtk-theme.git" \
    "sudo ./install.sh -t all -c dark --tweaks rimless" || exit 1

sudo rm -rf /usr/share/themes/Graphite-dark
rm -rf ~/.local/share/themes/Graphite-dark
cp -r ./assets/Graphite-dark ~/.local/share/themes/
echo "Установка расширенного оформления"
# ----------------------

# --- Установка иконок ---
install_from_git "https://github.com/vinceliuice/Tela-icon-theme.git" \
    "sudo ./install.sh -a -c grey" || exit 1


echo "Все компоненты успешно установлены. Временные файлы удалены."

cp -r ./assets/Tela-grey-dark ~/.local/share/icons/
# ----------------------

mkdir -p ~/.config/gtk-3.0
cp ./config/gtk-3.0/gtk.css ~/.config/gtk-3.0/


# =====================================================
# АВТОМАТИЧЕСКАЯ НАСТРОЙКА XFCE
# =====================================================

# Убедимся, что xfconf-query установлен
if ! command -v xfconf-query &> /dev/null; then
    echo "Установка xfce4-settings..."
    sudo xbps-install -y xfce4-settings
fi

# Функция для настройки тем
configure_xfce() {
    # Настройка темы GTK (окна приложений)
    xfconf-query -c xsettings -p /Net/ThemeName -s "Graphite-dark" --create -t string
    
    # Настройка темы иконок
    xfconf-query -c xsettings -p /Net/IconThemeName -s "Tela-grey-dark" --create -t string
    
    # Настройка темы оконного менеджера (декорации окон)
    xfconf-query -c xfwm4 -p /general/theme -s "Graphite-dark" --create -t string
}

# Проверяем, запущены ли мы в графической сессии
if [ -z "$DISPLAY" ]; then
    echo -e "\n⚠️  Невозможно применить настройки автоматически:"
    echo "Графическая сессия Xfce не обнаружена."
    echo "Пожалуйста, выполните после перезагрузки:"
    echo "xfconf-query -c xsettings -p /Net/ThemeName -s 'Graphite-dark'"
    echo "xfconf-query -c xsettings -p /Net/IconThemeName -s 'Tela-grey-dark'"
    echo "xfconf-query -c xfwm4 -p /general/theme -s 'Graphite-dark'"
else
    # Применяем настройки
    if configure_xfce; then
        echo -e "\n✅ Темы успешно применены:"
        echo "• Стиль интерфейса: Graphite-dark"
        echo "• Иконки: Tela-grey-dark"
        echo "• Оконный менеджер: Graphite-dark"
    else
        echo -e "\n⚠️ Ошибка применения настроек! Примените вручную через:"
        echo "Настройки → Внешний вид → Стиль: Graphite-dark"
        echo "Настройки → Внешний вид → Иконки: Tela-grey-dark"
        echo "Настройки → Менеджер окон → Стиль: Graphite-dark"
    fi
fi

echo "Все компоненты успешно установлены. Временные файлы удалены."