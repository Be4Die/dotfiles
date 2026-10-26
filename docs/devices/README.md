# Устройства и аппаратные профили (docs/devices/)

В данном каталоге собраны подробные спецификации оборудования всех устройств пользователя, аппаратные особенности, порты и драйверы.

---

## 📋 Список устройств

| Каталог | Устройство | Назначение | Профиль dotfiles | Статус |
| :--- | :--- | :--- | :--- | :--- |
| [desktop/](file:///home/michael/dotfiles/docs/devices/desktop/README.md) | **Рабочая станция cachyos-pc** | Настольный ПК (Dual Monitor, Nvidia GTX 1060, Limine, Btrfs) | `desktop` | Активно |
| [macbook/](file:///home/michael/dotfiles/docs/devices/macbook/README.md) | **Apple MacBook Pro 15" Mid-2015** | Ноутбук Retina A1398 (Intel Iris + AMD R9 M370X, GMUX) | `laptop` | Активно |
| [future-xiaomi-book-pro-14/](file:///home/michael/dotfiles/docs/devices/future-xiaomi-book-pro-14/README.md) | **Xiaomi Book Pro 14 (2026)** | Будущий флагманский ультрабук (Intel Panther Lake-H, OLED 3.1K) | `hosts/xiaomi` *(план)* | Планируется покупка |

---

## ⚙️ Архитектурные правила мультихоста

1. **Динамическое определение хоста:**
   - В [hyprland.lua](file:///home/michael/dotfiles/hypr/.config/hypr/hyprland.lua) проверка хоста осуществляется через:
     ```lua
     if hostname == "cachyos-pc" then
         pcall(require, "hosts.desktop")
     else
         pcall(require, "hosts.laptop")
     end
     ```
2. **Симлинки при установке:**
   - Скрипт [bootstrap.sh](file:///home/michael/dotfiles/bootstrap.sh) при первом запуске разворачивает симлинки на профильные файлы:
     - `hypr/.config/hypr/hosts/${HOST_TYPE}.lua` $\to$ `hypr/.config/hypr/host.lua`
     - `waybar/.config/waybar/hosts/${HOST_TYPE}.json` $\to$ `waybar/.config/waybar/config`
     - `alacritty/.config/alacritty/hosts/${HOST_TYPE}.toml` $\to$ `alacritty/.config/alacritty/local.toml`
     - `zed/.config/zed/hosts/${HOST_TYPE}.json` $\to$ `zed/.config/zed/settings.json`
3. **Как добавить новое устройство:**
   - Создать конфигурации в `hosts/` для соответствующих приложений.
   - Описать спецификацию в новом каталоге `docs/devices/<new-host>/README.md`.
   - Добавить проверку нового хостнейма в [bootstrap.sh](file:///home/michael/dotfiles/bootstrap.sh) и [hyprland.lua](file:///home/michael/dotfiles/hypr/.config/hypr/hyprland.lua).
   - Зарегистрировать в [AGENTS.md](file:///home/michael/dotfiles/AGENTS.md).
