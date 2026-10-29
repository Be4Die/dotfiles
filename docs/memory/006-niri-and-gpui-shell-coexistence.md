# ADR 006: Параллельное окружение Niri + GPUI Shell и кнопка Logout в Power Menu

> **Дата:** Октябрь 2026 г.  
> **Статус:** Внедрено  
> **Затронутые хосты:** `desktop` (`cachyos-pc`), `laptop`  
> **Компоненты:** `niri`, `gpuishell`, `wlogout`, SDDM

---

## 1. Контекст и задача

Пользователь захотел протестировать новое перспективное Wayland-окружение:
- **Niri:** Инновационный скролл-тайлинговый композитор с бесконечной горизонтальной лентой окон.
- **`gpuishell` (GPUI Shell):** Легковесный GPU-акселерированный шелл (статус-бар, единый лаунчер, центр управления, OSD) на Rust и движке Zed GPUI, заменяющий разнородные компоненты (Waybar, SwayNC, Fuzzel/Rofi, Wlogout).

**Ключевое требование:** Полное сохранение работоспособности текущего сетапа Hyprland, изоляция настроек и возможность легкого переключения между окружениями.

---

## 2. Принятые решения

### 1. Добавление действия Logout в Power Menu и консоль
В меню питания рабочей станции (`cachyos-pc`) изначально были доступны только Shutdown и Reboot. Для комфортного переключения сессий через SDDM:
- Создан системный скрипт [scripts/.local/bin/logout-session](file:///home/michael/dotfiles/scripts/.local/bin/logout-session), автоматически определяющий активный композитор (Hyprland или Niri) и завершающий сессию в SDDM.
- В [wlogout/.config/wlogout/layout_pc](file:///home/michael/dotfiles/wlogout/.config/wlogout/layout_pc) добавлена кнопка **Logout** (вызывает `logout-session`).
- В [hypr/.config/hypr/powermenu.sh](file:///home/michael/dotfiles/hypr/.config/hypr/powermenu.sh) скорректированы параметры запуска `wlogout` под 3 кнопки (`-b 3 -c 30 -r 30 -L 250 -R 250`).
- В [zsh/.zshrc](file:///home/michael/dotfiles/zsh/.zshrc) переопределена встроенная команда `logout`, чтобы при вводе `logout` в графическом терминале происходил мгновенный выход из сессии в SDDM вместо системной ошибки `not login shell`.

### 2. Мульти-сессионная поддержка в SDDM
Пакет `niri` установлен через официальный репозиторий CachyOS (`pacman -S niri xdg-desktop-portal-gnome`).  
Это предоставило файл сессии `/usr/share/wayland-sessions/niri.desktop`. На экране входа SDDM выбор между Hyprland и Niri происходит через стандартный выпадающий список сессий.

### 3. Изоляция конфигурации Niri через Stow
- Создан модуль [niri/.config/niri/config.kdl](file:///home/michael/dotfiles/niri/.config/niri/config.kdl) внутри репозитория `dotfiles`.
- Модуль добавлен в список `PACKAGES` в [bootstrap.sh](file:///home/michael/dotfiles/bootstrap.sh) и развернут через `stow`.
- **Настройка двух дисплеев под `cachyos-pc`:**
  - `HDMI-A-1`: `1920x1080@60`, позиция `x=1080 y=420` (основной).
  - `DVI-D-1`: `1920x1080@60`, поворот `transform "90"`, позиция `x=0 y=0` (вертикальный).
- **Переменные окружения для Nvidia:** `LIBVA_DRIVER_NAME`, `GBM_BACKEND`, `NVD_BACKEND direct`.
- Профиль защиты от утечки VRAM в драйвере Nvidia для Niri уже присутствует в `/etc/nvidia/nvidia-application-profiles-rc.d/limit-vram-usage`.

### 4. Сборка и интеграция GPUI Shell
Исходный код склонирован в `~/Projects/gpui-shell` и собран в release-режиме с помощью Rust toolchain.  
Бинарный файл установлен в `~/.local/bin/gpuishell` (с алиасом `gpui-shell`).  
Запускается автоматически при старте Niri через `spawn-at-startup "gpuishell"`.

**Кастомизация и доработки GPUI Shell:**
- В `crates/services/src/tray/dbus.rs` устранена проблема дублирования иконок приложений (StatusNotifierItem) через сопоставление уникального ID отправителя (`sender`).
- В `crates/app/src/bar/` добавлена поддержка фильтрации мониторов (`monitors = "HDMI-A-1"`), что исключило отображение бара на втором (портретном) мониторе `DVI-D-1`.
- В `crates/app/src/dock/` реализовано отключение дока (`enabled = false`), убравшее всплывающую панель приложений с вертикального экрана.
- В `crates/app/src/osd/` добавлена поддержка флага `[osd] enabled = false` для отключения встроенного OSD громкости, дублировавшегося на правом краю экрана.
- В [niri/.config/niri/config.kdl](file:///home/michael/dotfiles/niri/.config/niri/config.kdl):
  - Хоткей `Mod+R` / `Mod+D` перенаправлен на запуск единого лаунчера `gpuishell`, `Mod+Shift+R` оставлен для `fuzzel`.
  - Отключен стартовый баннер подсказок (`hotkey-overlay { skip-at-startup; }`).
  - Включено постоянное центрирование окон (`center-focused-column "always"`).
  - Настроено циклирование пресетов ширины (`Super + W`) и режим вкладок (`Super + T`).
  - Настроена единая система колесика мыши: `Super + Wheel` (горизонтальная лента), `Super + Shift + Wheel` (вертикальные воркспейсы), `Super + Ctrl + Wheel` (переключение мониторов).
  - Добавлены быстрые переключатели: `Alt + Tab` (предыдущее окно) и `Super + Tab` (предыдущий воркспейс).
- В FlClashX активированы флаги `silentLaunch` и `minimizeOnExit` для корректной фоновой работы в системном трее.

---

## 3. Маппинг хоткеев: Hyprland $\leftrightarrow$ Niri

Для сохранения мышечной памяти пользователя ключевые хоткеи синхронизированы:

| Действие | Hyprland | Niri | Особенности Niri |
| :--- | :--- | :--- | :--- |
| **Терминал (Alacritty)** | `Super + Q` | `Super + Q` | Тот же хоткей |
| **Закрыть окно** | `Super + C` | `Super + C` | Тот же хоткей |
| **Файловый менеджер (Thunar)** | `Super + E` | `Super + E` | Тот же хоткей |
| **Лаунчер приложений** | `Super + R` (fuzzel) | `Super + R` / `Super + D` (GPUI launcher) | Резерв: `Super + Shift + R` (fuzzel) |
| **Плавающий режим (Float)** | `Super + V` | `Super + V` | Переключение tiling $\leftrightarrow$ floating |
| **Фокус влево / вправо** | `Super + Left/Right` или `H/L` | `Super + Left/Right` или `H/L` | Скроллит бесконечную ленту колонок |
| **Фокус вверх / вниз** | `Super + Up/Down` или `K/J` | `Super + Up/Down` или `K/J` | Листает окна в колонке или переходит по воркспейсам |
| **Смена монитора** | `Super + Shift + Left/Right` | `Super + Shift + Left/Right` | Переход между HDMI-A-1 и DVI-D-1 |
| **Воркспейсы 1..9** | `Super + 1..9` | `Super + 1..9` | В Niri воркспейсы расположены вертикально |
| **Предыдущее окно** | `Alt + Tab` | `Alt + Tab` | Мгновенный возврат к предыдущему активному окну |
| **Предыдущий воркспейс** | N/A | `Super + Tab` | Быстрый возврат к предыдущему рабочему столу |
| **Пресеты ширины** | N/A | `Super + W` | Циклическое переключение 33% → 50% → 66% → 100% |
| **Режим вкладок (табов)** | N/A | `Super + T` | Превращает окна в колонке во вкладки |
| **Меню питания** | `Super + Escape` | `Super + Escape` | Запуск того же `powermenu.sh` с кнопкой Logout |
| **Скриншот** | `Print` / `Super + S` | `Print` / `Super + S` | Запуск скриншотера |
| **Смена раскладки (US/RU)** | `Super + Space` | `Super + Space` | `options "grp:alt_shift_toggle"` + шорткат |
| **Обзор всех окон (Overview)** | N/A | `Super + O` | Наглядный масштабный зум-аут |
