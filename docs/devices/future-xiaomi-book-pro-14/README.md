# Планируемое целевое устройство: Xiaomi Book Pro 14 (2026)

> **Статус:** В планах к приобретению.  
> **Цель миграции:** Полная замена текущего ПК (`cachyos-pc`) и MacBook Pro 15" Mid-2015 одним компактным и мощным ультрабуком для работы, разработки и мобильного использования.  
> **Основная база знаний:** Подробная документация, реверс-инжиниринг и патчи ядра находятся в проекте [/home/michael/Projects/xiaomi-book-pro-14-2026/](file:///home/michael/Projects/xiaomi-book-pro-14-2026/).

---

## 📌 Краткая сводка спецификаций

| Компонент / Подсистема | Детальная спецификация | Особенности в Linux |
| :--- | :--- | :--- |
| **Платформа** | Intel Panther Lake-H (техпроцесс Intel 18A: RibbonFET + PowerVia) | Архитектура ядра Linux 7.x+ |
| **Процессор (CPU)** | Intel Core Ultra X7 358H, 16 ядер / 16 потоков (4 P-ядра Cougar Cove + 8 E-ядер Darkmont + 4 LP-ядра), до 4.8 ГГц Turbo | Высокая энергоэффективность, TDP 25–50W |
| **Графика (iGPU)** | Intel Arc B390 (Xe3-LPG, 3 нм TSMC N3E), 12 Xe3-ядер (1536 ALUs), Ray Tracing, 96 XMX-блоков | Драйвер ядра `xe` (`xe.enable_psr=0` при необходимости) |
| **ИИ-ускоритель (NPU)** | Intel NPU 5 (до 50 TOPS INT8) | Поддержка OpenVINO / ONNX runtime |
| **Оперативная память** | 32 ГБ LPDDR5X-9600 МГц (двухканальная, распаяна) | Экстремальная пропускная способность |
| **Накопитель** | 1 ТБ M.2 NVMe PCIe 4.0 x4 + второй свободный слот M.2 2280 | Возможность расширения до 4 ТБ |
| **Дисплей** | 14.6" 3.1K OLED (3120 × 2080, 3:2), 120 Гц DRR, 1600 нит HDR / 500 нит SDR, 10-точечный тач | Потрясающая цветопередача, автояркость через ALS |
| **Материнская плата** | Bitland TM2424 (версия V14D1, BIOS Insyde H2O) | WMI-драйвер `bitland-mifs-wmi` (ядро 7.1+) |
| **Тачпад** | BetterLife (Blestech) стеклянный прецизионный с виброоткликом (I2C HID: `347D:7853`) | Превосходный отклик в Wayland |
| **Беспроводная связь** | Intel Wi-Fi 7 BE201 (320 МГц, 4K-QAM) + Bluetooth 5.4 / 6.0 | Модуль ядра `iwlwifi` |
| **Аудио** | Intel HD Audio + Sound Open Firmware (SOF), Realtek кодек, 4 динамика Dolby Atmos | Модуль `snd_sof_pci_intel_ptl` |
| **Питание и АКБ** | 72 Вт·ч Li-Po, зарядка 100W GaN (USB-PD 3.0/3.1) | Аппаратный контроль порогов заряда через EC (80%) |
| **Габариты и вес** | Магниево-алюминиевый корпус, карбоновый поддон, вес ~1.08 кг, толщина ~14.95 мм | Идеальный ультралегкий формат |

---

## 🛠️ План адаптации dotfiles при переходе на устройство

Когда устройство будет куплено, переход в `dotfiles` будет осуществлен по следующему протоколу:

1. **Создание нового профиля хоста:**
   - Будет создан профиль `hosts/xiaomi` (или переиспользован `hosts/laptop` с заменой под OLED 3.1K и масштабирование 1.5x / 1.75x).
   - [hypr/.config/hypr/hosts/xiaomi.lua](file:///home/michael/dotfiles/hypr/.config/hypr/hosts/):
     - Разрешение: `3120x2080@120`, scale 1.6 (или дробный с Wayland-native).
     - Драйверы: `LIBVA_DRIVER_NAME="iHD"`, `intel_media`.
2. **Аппаратные фиксы и службы из базы знаний:**
   - Интеграция службы ограничения заряда батареи до 80% через WMI/EC (проект `XiControl`).
   - Синхронизация светодиода Caps Lock через прямой порт `0x60` (`caps-led-sync`).
   - Настройка жестов тактильного тачпада в Hyprland.
3. **Вывод из эксплуатации старых устройств:**
   - Профили `hosts/desktop.*` и специфичные для MacBook костыли GMUX архивируются, освобождая dotfiles от лишнего легаси.

---

## 🔍 Источники данных (Sources)

Полный перечень репозиториев, даташитов и материалов реверс-инжиниринга находится в:  
👉 [/home/michael/Projects/xiaomi-book-pro-14-2026/SOURCES.md](file:///home/michael/Projects/xiaomi-book-pro-14-2026/SOURCES.md)

Ключевые ссылки:
- Проект [XiControl (Oksion/XiControl)](https://github.com/Oksion/XiControl) (WMI-протокол Bitland TM2424, EC, лимиты заряда).
- Репозиторий [Linux on Xiaomi Book Pro 14](https://github.com/RiviaRammer/Linux-on-Xiaomi-Book-Pro-14).
- Драйвер ядра [bitland-mifs-wmi.c (LKML)](https://patchew.org/linux/20260213135107.609958-1-qby140326@gmail.com/).
- Документация [ArchWiki: Xiaomi Book Pro 14](https://wiki.archlinux.org/title/Xiaomi_Book_Pro_14).
