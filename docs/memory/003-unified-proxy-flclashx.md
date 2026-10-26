# ADR 003: Единая маршрутизация прокси через FlClashX / Mihomo (Порт 7890)

> **Дата:** Октябрь 2026 г.  
> **Статус:** Принято / Внедрено  
> **Затронутые хосты:** `desktop` (`cachyos-pc`), `laptop`  
> **Компоненты:** FlClashX, Mihomo Core, Docker Daemon, Zsh, Hyprland Autostart

---

## 1. Контекст и проблема
Ранее в системе использовался клиент `koala-clash` и локальный смешанный прокси-порт `7897`. При этом часть конфигураций (например, Docker демон, скрипты сборки, переменные среды в zsh) периодически рассинхронизировались между `7890`, `7897` и `1080`, из-за чего:
* `docker pull` и сборка образов зависали без доступа к внешним реестрам.
* Терминальные утилиты (`curl`, `git`, `cargo`, `go`) требовали ручного указания прокси.
* При смене клиента на `FlClashX` требовалось централизовать порт и поведение автозапуска.

---

## 2. Принятое решение

1. **Единый порт прокси:**
   - Для всех локальных служб, Docker и терминала зафиксирован стандартный порт смешанного прокси (HTTP/SOCKS5):
     ```text
     127.0.0.1:7890
     ```

2. **Автозапуск в Hyprland:**
   - В [hypr/.config/hypr/hyprland.lua](file:///home/michael/dotfiles/hypr/.config/hypr/hyprland.lua) при старте графического окружения вызывается бинарник `flclashx` как для профиля `desktop`, так и для `laptop`:
     ```lua
     hl.exec_cmd("flclashx")
     ```

3. **Служба Docker Daemon:**
   - В `/etc/systemd/system/docker.service.d/http-proxy.conf` настроены переменные:
     ```ini
     [Service]
     Environment="HTTP_PROXY=http://127.0.0.1:7890"
     Environment="HTTPS_PROXY=http://127.0.0.1:7890"
     Environment="NO_PROXY=localhost,127.0.0.1,docker"
     ```
   - Зафиксировано в скрипте [scripts/migrate-docker-pc.sh](file:///home/michael/dotfiles/scripts/migrate-docker-pc.sh).

4. **Терминальные переменные и псевдонимы:**
   - В [zsh/.zshrc](file:///home/michael/dotfiles/zsh/.zshrc) используются функции/алиасы `proxy_on` и `proxy_off`, указывающие на `127.0.0.1:7890`.

---

## 3. Последствия и правила для агента
* При настройке любых новых инструментов (CLI утилит, пакетов, SDK, контейнеров) **всегда** использовать порт `7890` для доступа через прокси.
* Не возвращаться к порту `7897` и не использовать `koala-clash`.
