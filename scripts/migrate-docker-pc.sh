#!/usr/bin/env bash
set -e

echo "=== [1/6] Проверка прав sudo ==="
sudo -v

echo "=== [2/6] Удаление Docker Desktop и GitHub Desktop ==="
if pacman -Qq docker-desktop &>/dev/null; then
    systemctl --user stop docker-desktop.service 2>/dev/null || true
    systemctl --user disable docker-desktop.service 2>/dev/null || true
    sudo pacman -Rns --noconfirm docker-desktop || sudo pacman -R --noconfirm docker-desktop
    echo "Docker Desktop успешно удален."
else
    echo "Docker Desktop не установлен, пропускаем."
fi
flatpak uninstall -y io.github.shiftey.Desktop 2>/dev/null || true

echo "=== [3/6] Установка нативного Docker, Compose, Buildx, LazyDocker, LazyGit и Satty ==="
sudo pacman -S --needed --noconfirm docker docker-compose docker-buildx lazydocker lazygit satty

echo "=== [4/6] Настройка проксирования через Mihomo (127.0.0.1:7897) ==="
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf > /dev/null << 'PROXY_EOF'
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:7897"
Environment="HTTPS_PROXY=http://127.0.0.1:7897"
Environment="NO_PROXY=localhost,127.0.0.1,docker"
PROXY_EOF

mkdir -p "$HOME/.docker"
cat > "$HOME/.docker/config.json" << 'DOCKER_CFG'
{
	"auths": {},
	"currentContext": "default",
	"plugins": {
		"-x-cli-hints": {
			"enabled": "true"
		}
	}
}
DOCKER_CFG

# Удаляем контекст Desktop, если он остался
docker context rm desktop-linux 2>/dev/null || true
docker context use default 2>/dev/null || true

echo "=== [5/6] Настройка прав пользователя и запуск сервиса Docker ==="
sudo usermod -aG docker "$USER"
sudo systemctl daemon-reload
sudo systemctl enable --now docker

echo "=== [6/6] Проверка работы ==="
if sudo docker info &>/dev/null; then
    echo "✓ Демон Docker успешно запущен и работает!"
else
    echo "⚠ Проверьте статус службы: systemctl status docker"
fi

echo ""
echo "================================================================"
echo "🎉 Миграция на нативный Docker успешно завершена!"
echo "Чтобы запускать docker/lazydocker без sudo в текущей сессии, выполните:"
echo "    newgrp docker"
echo "(или просто перезайдите в систему / перезагрузите ПК)."
echo "Горячая клавиша для запуска в Hyprland: Super + Shift + D"
echo "================================================================"
