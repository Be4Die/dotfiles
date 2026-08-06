# Исправление регулировки яркости на MacBook Pro (Mid-2015) в Linux

Этот документ описывает глубокую проблему отсутствия регулировки яркости экрана на MacBook Pro 15" Retina (MacBookPro11,5) с двумя видеокартами (Intel + AMD) под управлением Linux (CachyOS/Arch Linux), а также детальное решение, которое позволило вернуть нативную аппаратную регулировку подсветки.

## 1. Суть проблемы
По умолчанию после установки Linux папка `/sys/class/backlight/` оказывалась пустой. Система не видела устройство управления подсветкой экрана. Экран всегда работал на 100% яркости.

В отличие от обычных ноутбуков, где яркостью напрямую управляет видеокарта, в MacBookPro11,5 физическое питание и ШИМ-сигнал на матрицу экрана подаёт отдельный аппаратный микроконтроллер — **Apple GMUX (Graphics Multiplexer)**. Стандартные методы управления через видеодрайвер или `acpi_video` здесь не работают.

## 2. Попытка №1: Параметр ядра
Изначально мы обнаружили, что драйвер `apple-gmux` требует явного указания через параметры ядра. Мы добавили в `/boot/refind_linux.conf` параметр:
```text
acpi_backlight=apple_gmux
```
**Результат:** Драйвер загрузился, и папка `/sys/class/backlight/gmux_backlight` появилась, однако изменение значений в файле `brightness` ни к чему не приводило. Устройство не реагировало на команды.

## 3. Главная засада: Блокировка I/O портов мостом AMD
Причина оказалась в аппаратной маршрутизации. PCI-мост дискретной видеокарты AMD (`00:01.00`) перехватывал (декодировал) диапазон VGA I/O портов. Из-за этого команды, отправляемые ядром Linux на порты микроконтроллера Apple GMUX, блокировались мостом AMD и просто не доходили до чипа.

Чтобы разблокировать I/O порты GMUX, нужно было снять флаг VGA I/O декодирования с PCI-моста AMD с помощью команды `setpci`:
```bash
sudo setpci -v -H1 -s 00:01.00 BRIDGE_CONTROL=0
```
Сразу после выполнения этой команды регулировка яркости (через `/sys/class/backlight/gmux_backlight/brightness`) оживала, и матрица дисплея физически меняла свою яркость.

## 4. Проблема с порядком загрузки (Timing Issue)
Мы создали systemd-сервис (`gmux-backlight-fix.service`), чтобы команда `setpci` выполнялась автоматически при каждой загрузке. Сначала мы настроили сервис на запуск `After=multi-user.target`. 

**Что пошло не так:**
После перезагрузки папка `gmux_backlight` вообще исчезла! В логах ядра (`dmesg`) драйвер `apple_gmux` писал:
```text
apple_gmux: gmux device not present
```
Оказалось, что `systemd-modules-load` (или `udev`) загружает модуль ядра `apple_gmux` **очень рано**, еще до того, как загружается `multi-user.target`. В момент загрузки модуля мост AMD все еще был заблокирован. Драйвер `apple_gmux` пытался прочитать версию чипа через I/O порт, получал в ответ ошибку (I/O blocked) и молча отключался, так и не зарегистрировав устройство подсветки.

## 5. Итоговое и полностью рабочее решение

Мы переписали systemd-сервис так, чтобы он выполнялся в самую первую секунду старта системы, **до загрузки любых модулей ядра**. 

**Файл `/etc/systemd/system/gmux-backlight-fix.service`:**
```ini
[Unit]
Description=Fix Apple GMUX backlight I/O routing on MacBookPro11,5
DefaultDependencies=no
Before=sysinit.target systemd-modules-load.service

[Service]
Type=oneshot
ExecStart=/usr/bin/setpci -v -H1 -s 00:01.00 BRIDGE_CONTROL=0
RemainAfterExit=yes

[Install]
WantedBy=sysinit.target
```

### 6. Вторая проблема: Динамический сброс PCI от vgaarb
После того как драйвер `apple_gmux` успешно проинициализировался при загрузке, выяснилось, что при запуске графического сервера (Wayland/X11), ядро (подсистема `vgaarb` — VGA Arbiter) заново переоценивает маршрутизацию VGA и **снова включает флаг VGA Forwarding (`0008`) на мосту AMD**. 
Из-за этого порты снова блокировались, и регулировка переставала работать прямо во время работы системы.

**Решение:** Мы модифицировали скрипт `change-brightness`, чтобы он принудительно открывал мост перед каждой регулировкой яркости. Чтобы это работало без запроса пароля, мы создали точечное правило в `sudoers`:

1. Создан хелпер `/usr/local/bin/unlock-gmux`:
```bash
#!/bin/bash
/usr/bin/setpci -H1 -s 00:01.00 BRIDGE_CONTROL=0
```
2. Создано правило `/etc/sudoers.d/gmux-backlight`:
```text
michael ALL=(root) NOPASSWD: /usr/local/bin/unlock-gmux
```

### Настройка управления (Горячие клавиши)
Скрипт `/usr/local/bin/change-brightness` (сохранён в `dotfiles/scripts/change-brightness`) был обновлён:
```bash
#!/bin/bash
DIR="$1"
STEP="${2:-5%}"

# Принудительно открываем порты (если vgaarb их закрыл)
sudo /usr/local/bin/unlock-gmux

for dev in /sys/class/backlight/*; do
    if [ -e "$dev/brightness" ]; then
        bname="$(basename "$dev")"
        brightnessctl -d "$bname" set "${STEP}${DIR}" 2>/dev/null
    fi
done
```

В конфигурацию Hyprland (`hyprland.lua`) добавлены бинды для стандартных кнопок MacBook:
```lua
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("/home/michael/dotfiles/scripts/change-brightness + 5%"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("/home/michael/dotfiles/scripts/change-brightness - 5%"))
hl.bind("F2",                    hl.dsp.exec_cmd("/home/michael/dotfiles/scripts/change-brightness + 5%"))
hl.bind("F1",                    hl.dsp.exec_cmd("/home/michael/dotfiles/scripts/change-brightness - 5%"))
```

### Итог
Подсветка регулируется аппаратно (меняется мощность питания матрицы, что экономит батарею). Система надежно инициализирует чип Apple GMUX при загрузке (через systemd-сервис), а скрипт с `sudoers` гарантирует, что I/O порты открыты в момент изменения яркости, обходя любые динамические сбросы от драйверов видеокарт. Никакие программные фильтры или костыли с гаммой больше не используются.
