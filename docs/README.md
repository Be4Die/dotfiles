# База знаний и документация окружения (docs/)

Добро пожаловать в структурированную базу знаний репозитория `dotfiles`. Этот каталог служит единым источником правды об оборудовании пользователя и принятых инженерных решениях.

---

## 🗂 Структура каталога

```text
docs/
├── README.md                      # Данный путеводитель
├── devices/                       # Спецификации оборудования конкретных устройств
│   ├── README.md                  # Обзор устройств и мультихостовой логики
│   ├── desktop/README.md          # Рабочая станция cachyos-pc (Nvidia, 2 монитора, Limine)
│   ├── macbook/README.md          # MacBook Pro 15" Retina Mid-2015 (GMUX, dual-GPU)
│   └── future-xiaomi-book-pro-14/ # Будущий ультрабук на замену двум текущим
└── memory/                        # Заметки о принятых решениях и предпочтениях (ADR)
    ├── README.md                  # Реестр и правила ведения заметок
    ├── 001-apple-gmux-backlight.md# Аппаратная подсветка Apple GMUX
    ├── 002-limine-snapper-btrfs.md# Загрузчик Limine и Btrfs снапшоты Snapper
    ├── 003-unified-proxy-flclashx.md# Единый порт прокси 7890 (FlClashX / Mihomo)
    ├── 004-flameshot-screenshot-flow.md# Скриншотер Flameshot + Grim
    └── 005-multi-host-architecture.md# Архитектура хост-профилей и миграции
```

---

## 🧭 Навигация для пользователя и агента

* **Хочешь узнать спецификацию железа или порты?**  
  $\to$ Смотри [docs/devices/](file:///home/michael/dotfiles/docs/devices/README.md).
* **Хочешь понять, почему что-то настроено именно так, или добавить новое решение?**  
  $\to$ Смотри [docs/memory/](file:///home/michael/dotfiles/docs/memory/README.md).
* **Главные правила поведения и рабочий процесс агента?**  
  $\to$ Смотри [AGENTS.md](file:///home/michael/dotfiles/AGENTS.md) в корне репозитория.
