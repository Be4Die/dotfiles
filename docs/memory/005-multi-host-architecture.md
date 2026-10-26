# ADR 005: Мультихостовая архитектура и стратегия безболезненной миграции

> **Дата:** Октябрь 2026 г.  
> **Статус:** Принято / Внедрено  
> **Затронутые хосты:** `desktop` (`cachyos-pc`), `laptop`, `future-xiaomi-book-pro-14`  
> **Компоненты:** `bootstrap.sh`, Hyprland, Waybar, Alacritty, Dunst, Zed

---

## 1. Контекст и проблема
Репозиторий `dotfiles` обслуживает устройства с принципиально разным оборудованием и сценариями использования:
1. **Рабочая станция (`cachyos-pc`):** Дискретная графика Nvidia GTX 1060, два разнородных монитора (один горизонтальный HDMI, второй вертикальный DVI), специфичный загрузчик Limine, шрифт 11pt.
2. **Ноутбук (`laptop`):** Apple MacBook Pro 15" Retina Mid-2015, чип управления подсветкой Apple GMUX, видеокарта AMD Radeon R9 M370X, дисплей 2880x1800 с целочисленным масштабированием 2x, мультитач-жесты, фильтрация Nvidia-драйверов, шрифт 10.5pt.
3. **Планы пользователя:** В обозримом будущем оба устройства будут проданы, а на смену им придет один универсальный ультрабук (Xiaomi Book Pro 14 2026, 3.1K OLED 120Hz, Intel Panther Lake-H).

При наивной монолитной конфигурации правки под экраны или драйверы одного устройства ломали другое, а добавление нового устройства требовало бы переписывания всех конфигов с нуля.

---

## 2. Принятое решение

1. **Строгая изоляция через каталоги `hosts/`:**
   Все параметры, зависящие от физического железа (мониторы, масштабирование, шрифты, видеодрайверы, горячие клавиши специфичной клавиатуры, правила подсветки), выносятся в подпапки `hosts/`:
   - `hypr/.config/hypr/hosts/<profile>.lua`
   - `waybar/.config/waybar/hosts/<profile>.json` и `<profile>.css`
   - `alacritty/.config/alacritty/hosts/<profile>.toml`
   - `dunst/.config/dunst/hosts/<profile>.conf`
   - `zed/.config/zed/hosts/<profile>.json`

2. **Двухуровневая привязка (Симлинки + Runtime Check):**
   - **Уровень 1 (Bootstrap):** Скрипт [bootstrap.sh](file:///home/michael/dotfiles/bootstrap.sh) при первом запуске определяет хостнейм или запрашивает профиль у пользователя, создавая локальные симлинки:
     - `hypr/host.lua` $\to$ `hosts/<profile>.lua`
     - `waybar/config` $\to$ `hosts/<profile>.json`
     - `alacritty/local.toml` $\to$ `hosts/<profile>.toml`
     - `zed/settings.json` $\to$ `hosts/<profile>.json`
   - **Уровень 2 (Динамический рантайм):** В [hypr/.config/hypr/hyprland.lua](file:///home/michael/dotfiles/hypr/.config/hypr/hyprland.lua) встроен запасной механизм безопасного переключения через `pcall`:
     ```lua
     if hostname == "cachyos-pc" then
         pcall(require, "hosts.desktop")
     else
         local host_ok, host = pcall(require, "host")
         if not host_ok then
             pcall(require, "hosts.laptop")
         end
     end
     ```

3. **Общее ядро остается нетронутым:**
   Базовые темы (Catppuccin Frappé), утилиты (Fuzzel, Thunar, Dunst базовые цвета, Zsh алиасы, Git конфиги, пользовательские скрипты) являются общими для всех хостов и не содержат условных блоков по железу.

---

## 3. Протокол миграции на новое устройство

При появлении нового устройства (Xiaomi Book Pro 14):
1. В каталогах `hosts/` создается набор файлов `hosts/xiaomi.*` (разрешение OLED 3120x2080@120Hz, масштаб 1.6x, Intel Iris/Arc переменные окружения).
2. В [bootstrap.sh](file:///home/michael/dotfiles/bootstrap.sh) добавляется определение хостнейма нового ноутбука.
3. Профили старых машин (`desktop` и `laptop`) архивируются или удаляются без риска затронуть рабочий инструментарий.
