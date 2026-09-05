#!/usr/bin/env bash
# Hide unwanted/clutter CLI, TUI, administrative, and test .desktop files from Fuzzel and app launchers

mkdir -p "$HOME/.local/share/applications"

HIDDEN_APPS=(
    # CLI / TUI Console Programs
    "vim.desktop"
    "micro.desktop"
    "btop.desktop"
    "nvtop.desktop"
    "qemu.desktop"
    "wine.desktop"
    "java-java-openjdk.desktop"
    "mpv.desktop"
    "btrfs-assistant.desktop"

    # Avahi network browsers
    "avahi-discover.desktop"
    "bssh.desktop"
    "bvnc.desktop"

    # Test / Dev GUIs & Handlers
    "cmake-gui.desktop"
    "lstopo.desktop"
    "qv4l2.desktop"
    "qvidcap.desktop"
    "google-maps-geo-handler.desktop"
    "openstreetmap-geo-handler.desktop"
    "wheelmap-geo-handler.desktop"
    "docker-desktop-uri-handler.desktop"

    # Background Daemons & Prompters (should not be in menu)
    "gcr-prompter.desktop"
    "gcr-viewer.desktop"
    "ktelnetservice6.desktop"
    "org.freedesktop.Xwayland.desktop"
    "org.gnome.Zenity.desktop"
    "org.gnupg.pinentry-qt.desktop"
    "org.kde.kiod6.desktop"
    "org.kde.ksecretd.desktop"
    "org.kde.polkit-kde-authentication-agent-1.desktop"
    "xdg-desktop-portal-gtk.desktop"

    # System & Hardware Settings not needed in Wofi daily
    "org.cachyos.KernelManager.desktop"
    "org.cachyos.scx-manager.desktop"
    "nvidia-settings.desktop"
    "xfce4-about.desktop"
    "thunar-bulk-rename.desktop"
    "thunar-settings.desktop"
    "thunar-volman-settings.desktop"
    "org.gnome.gThumb.Import.desktop"
    "system-config-printer.desktop"
)

for app in "${HIDDEN_APPS[@]}"; do
    if [ -f "/usr/share/applications/$app" ]; then
        cp "/usr/share/applications/$app" "$HOME/.local/share/applications/" 2>/dev/null
        if ! grep -q "NoDisplay=true" "$HOME/.local/share/applications/$app"; then
            echo "NoDisplay=true" >> "$HOME/.local/share/applications/$app"
        fi
    fi
done

echo "Cleaned up Wofi launcher icons successfully! (${#HIDDEN_APPS[@]} apps hidden)"
