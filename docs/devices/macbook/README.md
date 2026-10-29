# Спецификация оборудования: Ноутбук (MacBook Pro 15" Mid-2015 / `laptop`)

> **Хостнейм:** Динамический (любой отличный от `cachyos-pc`)  
> **Используемый профиль dotfiles:** `laptop`  
> **Основное назначение:** Мобильное рабочее место на базе классического MacBook Pro 15 Retina.

---

## 📌 Краткая сводка спецификаций

| Компонент / Подсистема | Детальная спецификация | Идентификаторы / Особенности |
| :--- | :--- | :--- |
| **Модель устройства** | Apple MacBook Pro 15" Retina (Mid-2015), Model A1398 | Идентификатор Apple: `MacBookPro11,5` |
| **Дисплей** | 15.4" IPS Retina, 2880 × 1800 (16:10), 60 Гц, глянцевое антибликовое покрытие | Вывод: `eDP-1`, масштабирование **2.0** (нативный integer scale) |
| **Процессор (CPU)** | Intel Core i7 4-го поколения (Haswell, 22 нм), 4 ядра / 8 потоков *(i7-4870HQ / i7-4980HQ)* | *(Точная модель уточняется при сессии с Mac)* |
| **Оперативная память (RAM)** | 16 ГБ DDR3L 1600 МГц (распаяна на плате) | On-board Dual-channel |
| **Накопитель (SSD)** | Apple Proprietary PCIe 3.0 x4 NVMe/AHCI SSD | *(Точный объём уточняется при сессии с Mac)* |
| **Дискретная графика (dGPU)** | AMD Radeon R9 M370X (2 ГБ GDDR5) | Драйвер ядра: `amdgpu` / Mesa: `radeonsi` |
| **Встроенная графика (iGPU)** | Intel Iris Pro Graphics 5200 (Haswell GT3e со 128 МБ eDRAM) | Драйвер: `i915` |
| **Управление подсветкой экрана** | Аппаратный чип **Apple GMUX** (Graphics Multiplexer) | Требует снятия блокировки I/O портов моста AMD `00:01.00` |
| **Тачпад** | Apple Force Touch Trackpad (мультитач, жесты, тактильный отклик) | Hyprland: `natural_scroll = true` |
| **Клавиатура** | Классическая клавиатура Apple с ножничным механизмом и датчиком освещённости | Подсветка клавиш, бинды яркости на `F1/F2` и `XF86MonBrightness` |
| **Аудиосистема** | Стереодинамики с сабвуферами, двойной микрофон, 3.5 мм разъем со встроенным оптическим выходом SPDIF | Cirrus Logic CS4208 |
| **Беспроводная связь** | Broadcom BCM43602 (802.11ac Wi-Fi 3x3) + Bluetooth 4.2 | Модуль Apple AirPort |
| **Операционная система** | CachyOS Linux (Arch-based rolling release), ядро `linux-cachyos` | Wayland + Hyprland (без Nvidia-блоата) |

> ⚠️ *Примечание:* Поля со звёздочками будут автоматически дополнены точными дампами (`lscpu`, `lsblk`, `dmidecode`) во время первой рабочей сессии непосредственно с этого ноутбука.

---

## ⚡ Критические аппаратные особенности

### 1. Аппаратный микроконтроллер Apple GMUX и подсветка
На MacBookPro11,5 видеокарта не управляет подсветкой напрямую — сигнал ШИМ подаёт чип Apple GMUX. По умолчанию в Linux PCI-мост дискретной видеокарты AMD (`00:01.00`) перехватывает I/O порты GMUX, из-за чего регулировка яркости полностью блокируется.
* В системе настроен ранний systemd-сервис `/etc/systemd/system/gmux-backlight-fix.service`.
* Для предотвращения повторной блокировки со стороны `vgaarb` во время работы используется утилита `/usr/local/bin/unlock-gmux` с правами в `sudoers`.
* Полное описание решения зафиксировано в [docs/memory/001-apple-gmux-backlight.md](file:///home/michael/dotfiles/docs/memory/001-apple-gmux-backlight.md).

### 2. Масштабирование Retina 2x и XWayland
* Дисплей 2880x1800 настроен с целочисленным масштабированием `scale = 2` (эффективное рабочее пространство 1440x900).
* Чтобы старые приложения X11 (Steam, ONLYOFFICE) не размывались, в [hypr/.config/hypr/hosts/laptop.lua](file:///home/michael/dotfiles/hypr/.config/hypr/hosts/laptop.lua) активирован параметр:
  ```lua
  hl.config({
      xwayland = {
          force_zero_scaling = true,
      },
  })
  ```

### 3. Очистка от Noctua Shell и драйверов Nvidia
Скрипт развёртывания [bootstrap.sh](file:///home/michael/dotfiles/bootstrap.sh) автоматически определяет профиль ноутбука и:
- Удаляет предустановленный блоат CachyOS (`noctua-shell`, `cachyos-hyprland-settings`).
- Фильтрует пакеты `nvidia`, `cuda`, `egl-wayland` из списков установки пакетов.
- Настраивает HiDPI конфигурацию для экрана входа SDDM.

---

## 🔗 Файлы конфигурации профиля `laptop`

- **Оконный менеджер (основной):** [hypr/.config/hypr/hosts/laptop.lua](file:///home/michael/dotfiles/hypr/.config/hypr/hosts/laptop.lua)
- **Оконный менеджер (альтернативный):** [niri/.config/niri/hosts/laptop.kdl](file:///home/michael/dotfiles/niri/.config/niri/hosts/laptop.kdl) (Retina 2x, GMUX brightness, тачпад)
- **Шелл и статус-бар:** `gpuishell` (GPUI Shell fork) / [waybar/.config/waybar/hosts/laptop.json](file:///home/michael/dotfiles/waybar/.config/waybar/hosts/laptop.json) и [laptop.css](file:///home/michael/dotfiles/waybar/.config/waybar/hosts/laptop.css)
- **Эмулятор терминала:** [alacritty/.config/alacritty/hosts/laptop.toml](file:///home/michael/dotfiles/alacritty/.config/alacritty/hosts/laptop.toml) (шрифт 10.5pt)
- **Уведомления:** [dunst/.config/dunst/hosts/laptop.conf](file:///home/michael/dotfiles/dunst/.config/dunst/hosts/laptop.conf)
- **Редактор кода:** [zed/.config/zed/hosts/laptop.json](file:///home/michael/dotfiles/zed/.config/zed/hosts/laptop.json)
- **Меню выхода:** [wlogout/.config/wlogout/layout_laptop](file:///home/michael/dotfiles/wlogout/.config/wlogout/layout_laptop)

---

## 🔍 Источники данных (Sources)

1. **Анализ ядра и аппаратного моста:**
   - [docs/memory/001-apple-gmux-backlight.md](file:///home/michael/dotfiles/docs/memory/001-apple-gmux-backlight.md) (`apple-gmux`, `setpci -s 00:01.00 BRIDGE_CONTROL=0`)
2. **Скрипт начальной установки:**
   - [bootstrap.sh](file:///home/michael/dotfiles/bootstrap.sh) (секции `HOST_TYPE="laptop"`, удаление `noctua-shell`, фильтрация `nvidia`)
3. **Конфигурация Hyprland:**
   - [hypr/.config/hypr/hosts/laptop.lua](file:///home/michael/dotfiles/hypr/.config/hypr/hosts/laptop.lua) (параметры дисплея `eDP-1`, переменные `radeonsi`, тачпад)
