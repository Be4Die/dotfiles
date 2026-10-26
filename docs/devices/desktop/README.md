# Спецификация оборудования: Рабочая станция (Desktop / `cachyos-pc`)

> **Хостнейм:** `cachyos-pc`  
> **Используемый профиль dotfiles:** `desktop`  
> **Основное назначение:** Основная производительная рабочая станция разработчика с двумя мониторами.

---

## 📌 Краткая сводка спецификаций

| Компонент / Подсистема | Детальная спецификация | Идентификаторы / Порты |
| :--- | :--- | :--- |
| **Процессор (CPU)** | Intel Core i5-8400 (Coffee Lake-S, 14 нм), 6 ядер / 6 потоков, базовая 2.80 ГГц, Turbo до 4.00 ГГц, 9 МБ Intel Smart Cache | `GenuineIntel`, Family 6 Model 158 |
| **Оперативная память (RAM)** | 32 ГБ DDR4 (доступно 31.3 ГиБ) | Dual-channel DDR4 |
| **Swap (Подкачка)** | 31.3 ГБ zram с алгоритмом сжатия Zstandard (zstd) | `/dev/zram0` |
| **Материнская плата** | MSI B360M MORTAR (MS-7B23) | DMI Board: `B360M MORTAR (MS-7B23)` |
| **Версия BIOS / UEFI** | AMI BIOS v1.D0 | ESRT / DMI v1.D0 |
| **Видеокарта (GPU)** | Gigabyte NVIDIA GeForce GTX 1060 6GB (чип GP106, 1280 CUDA ядер, 192-bit GDDR5) | PCI ID: `10de:1c03`, драйвер `nvidia-dkms` |
| **Накопитель ОС (`sda`)** | 480 ГБ 2.5" SATA SSD (Kingston SA400S37480G) | `sda1` (ESP 8GB FAT32), `sda2` (Btrfs root 439GB) |
| **Накопитель данных (`sdb`)** | 480 ГБ 2.5" SATA SSD (Crucial CT480BX500SSD1) | `sdb1` (Btrfs 447GB, смонтирован в `/home`) |
| **Основной монитор** | Горизонтальный монитор (подключен по HDMI) | Порт: `HDMI-A-1`, позиция `1080x420`, scale 1 |
| **Второй монитор** | Вертикальный портретный монитор 1080x1920 (подключен по DVI) | Порт: `DVI-D-1`, `1920x1080@60`, transform 1, позиция `0x0` |
| **Сетевой контроллер** | Intel I219-V Gigabit Ethernet Controller | MAC: `30:9c:23:a6:29:d2`, onboard |
| **Аудиокодек** | Realtek ALC892 High Definition Audio | Onboard 7.1 HD Audio |
| **Загрузчик системы** | Limine Bootloader v8.x с интеграцией `limine-snapper-sync` | EFI ESP: 8.0 ГБ (`/boot`) |
| **Файловая система** | Btrfs со снапшотами Snapper (сабволюмы `/@`, `/@root`, `/@srv`, `/@cache`, `/@tmp`, `/@log`) | Изолированный `/home` на `sdb` |
| **Операционная система** | CachyOS Linux (Arch-based rolling release), ядро `linux-cachyos` (7.2.x) | Wayland + Hyprland |

---

## 🖥️ Конфигурация мониторов и Wayland

Рабочее пространство организовано с двумя физическими дисплеями:
- **`DVI-D-1` (Левый, вертикальный):** Повернут на 90 градусов против часовой стрелки (`transform = 1`). Расположен в координатах `0x0`. Отлично подходит для чтения документации, логов и мессенджеров.
- **`HDMI-A-1` (Правый, основной):** Основной альбомный экран. Расположен в координатах `1080x420` для эргономичного выравнивания нижней границы с вертикальным монитором.

Файл конфигурации: [hypr/.config/hypr/hosts/desktop.lua](file:///home/michael/dotfiles/hypr/.config/hypr/hosts/desktop.lua)

### Переменные окружения для NVIDIA:
```lua
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")
hl.env("NVD_BACKEND", "direct")
hl.env("BROWSER", "firefox")
```

---

## 💾 Разметка дисков и резервное копирование

1. **Физическая изоляция `/home`:**
   - Личные файлы пользователя, проекты и дотфайлы находятся на отдельном физическом диске `sdb` (Crucial BX500).
   - Это гарантирует, что любые манипуляции с системным диском `sda` (переустановка, откат снапшотов, переразметка) **никогда не затрагивают личные данные**.

2. **Limine + Btrfs Snapper:**
   - Раздел EFI (`sda1`) расширен до **8.0 ГБ**, так как при использовании проприетарного драйвера NVIDIA каждый образ `initramfs` весит ~190 МБ.
   - Подробная история и инструкция настройки описаны в [docs/memory/002-limine-snapper-btrfs.md](file:///home/michael/dotfiles/docs/memory/002-limine-snapper-btrfs.md).

---

## 🔗 Файлы конфигурации профиля `desktop`

- **Оконный менеджер:** [hypr/.config/hypr/hosts/desktop.lua](file:///home/michael/dotfiles/hypr/.config/hypr/hosts/desktop.lua)
- **Панель статуса:** [waybar/.config/waybar/hosts/desktop.json](file:///home/michael/dotfiles/waybar/.config/waybar/hosts/desktop.json) и [desktop.css](file:///home/michael/dotfiles/waybar/.config/waybar/hosts/desktop.css)
- **Эмулятор терминала:** [alacritty/.config/alacritty/hosts/desktop.toml](file:///home/michael/dotfiles/alacritty/.config/alacritty/hosts/desktop.toml) (шрифт 11pt)
- **Уведомления:** [dunst/.config/dunst/hosts/desktop.conf](file:///home/michael/dotfiles/dunst/.config/dunst/hosts/desktop.conf)
- **Редактор кода:** [zed/.config/zed/hosts/desktop.json](file:///home/michael/dotfiles/zed/.config/zed/hosts/desktop.json)

---

## 🔍 Источники данных (Sources)

1. **DMI / SMBIOS:**
   - `/sys/class/dmi/id/product_name` $\to$ `MS-7B23`
   - `/sys/class/dmi/id/board_name` $\to$ `B360M MORTAR (MS-7B23)`
   - `/sys/class/dmi/id/bios_version` $\to$ `1.D0`
2. **Процессор и память:**
   - `/proc/cpuinfo` (Intel Core i5-8400 CPU @ 2.80GHz)
   - `free -h` (31 GiB RAM, 31 GiB zram)
3. **Хранилище:**
   - `lsblk -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE,MOUNTPOINTS` (`sda` 447.1G, `sdb` 447.1G)
   - `/etc/fstab` (Btrfs subvolumes `/@root`, `/@srv`, `/@cache`, `/@tmp`, `/@log`)
4. **Графика и дисплеи:**
   - [hypr/.config/hypr/hosts/desktop.lua](file:///home/michael/dotfiles/hypr/.config/hypr/hosts/desktop.lua)
   - [docs/memory/002-limine-snapper-btrfs.md](file:///home/michael/dotfiles/docs/memory/002-limine-snapper-btrfs.md)
