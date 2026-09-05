#!/usr/bin/env bash
#
# Dotfiles Unified Entry Point Bootstrap Script (Multi-Host Enabled)
# ATTENTION: This script is intended ONLY for initial system bootstrapping on fresh installs.
# DO NOT run this on an already configured system during normal synchronization.
# Usage: ./bootstrap.sh
#

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

echo "======================================================"
echo "    Initial System Bootstrap via GNU Stow (FRESH ONLY)"
echo "======================================================"
echo "Root directory: $DOTFILES_DIR"

# 1. Ensure stow is installed
if ! command -v stow &>/dev/null; then
    echo "[!] GNU Stow is not installed. Installing via pacman..."
    sudo pacman -S --noconfirm stow
fi

# 2. Host Profile Detection & Selection
HOSTNAME_CURRENT="$(hostname 2>/dev/null || cat /etc/hostname 2>/dev/null || echo "")"
HOST_TYPE=""

if [ "$HOSTNAME_CURRENT" = "cachyos-pc" ]; then
    echo "[*] Auto-detected hostname: $HOSTNAME_CURRENT -> Desktop Profile"
    HOST_TYPE="desktop"
else
    echo "------------------------------------------------------"
    echo "       Select Host Environment Profile Target         "
    echo "------------------------------------------------------"
    echo "1) Desktop (Dual Monitor, Nvidia GTX 1060, full effects)"
    echo "2) MacBook Pro / Laptop (Retina 2880x1800, AMD/Intel iGPU, power save, touch gestures)"
    read -p "[?] Choice [1/2, default=1]: " CHOICE
    if [ "$CHOICE" = "2" ]; then
        HOST_TYPE="laptop"
    else
        HOST_TYPE="desktop"
    fi
fi

echo "[*] Applying profile: $HOST_TYPE"
ln -sf "$DOTFILES_DIR/hypr/.config/hypr/hosts/${HOST_TYPE}.lua" "$DOTFILES_DIR/hypr/.config/hypr/host.lua"
ln -sf "$DOTFILES_DIR/waybar/.config/waybar/hosts/${HOST_TYPE}.json" "$DOTFILES_DIR/waybar/.config/waybar/config"
ln -sf "$DOTFILES_DIR/alacritty/.config/alacritty/hosts/${HOST_TYPE}.toml" "$DOTFILES_DIR/alacritty/.config/alacritty/local.toml"
ln -sf "$DOTFILES_DIR/zed/.config/zed/hosts/${HOST_TYPE}.json" "$DOTFILES_DIR/zed/.config/zed/settings.json"

# Remove default CachyOS desktop bloat (noctua-shell) on fresh laptop install
if [ "$HOST_TYPE" = "laptop" ]; then
    if pacman -Qs "noctua-shell" &>/dev/null; then
        echo "[*] Removing CachyOS default Noctua Shell bloat..."
        sudo pacman -Rns --noconfirm noctua-shell cachyos-hyprland-settings 2>/dev/null || true
    fi
fi

# Resolve qt6ct vs qt6ct-kde package conflict
if pacman -Qs "^qt6ct$" &>/dev/null; then
    echo "[*] Resolving package conflict: removing standard qt6ct in favor of qt6ct-kde..."
    sudo pacman -Rdd --noconfirm qt6ct 2>/dev/null || true
fi

# 3. Package sync option
if [ -f "$DOTFILES_DIR/pkglist/pkglist.txt" ]; then
    read -p "[?] Do you want to check and install missing official packages from pkglist.txt? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "[*] Installing official pacman packages..."
        if [ "$HOST_TYPE" = "laptop" ]; then
            echo "[*] Laptop host detected: Filtering out Nvidia-specific drivers..."
            grep -v -E "nvidia|cuda|egl-wayland" "$DOTFILES_DIR/pkglist/pkglist.txt" > /tmp/pkglist_laptop.txt
            sudo pacman -S --needed --noconfirm - < /tmp/pkglist_laptop.txt || true
            rm -f /tmp/pkglist_laptop.txt
        else
            sudo pacman -S --needed --noconfirm - < "$DOTFILES_DIR/pkglist/pkglist.txt" || true
        fi
    fi
fi

if [ -f "$DOTFILES_DIR/pkglist/aurpkglist.txt" ]; then
    read -p "[?] Do you want to check and install missing AUR packages from aurpkglist.txt? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        AUR_HELPER=""
        if command -v yay &>/dev/null; then
            AUR_HELPER="yay"
        elif command -v paru &>/dev/null; then
            AUR_HELPER="paru"
        fi

        if [ -n "$AUR_HELPER" ]; then
            echo "[*] Installing AUR packages using $AUR_HELPER..."
            if [ "$HOST_TYPE" = "laptop" ]; then
                grep -v -E "nvidia|cuda|egl-wayland" "$DOTFILES_DIR/pkglist/aurpkglist.txt" > /tmp/aurpkglist_laptop.txt
                $AUR_HELPER -S --needed --noconfirm - < /tmp/aurpkglist_laptop.txt || true
                rm -f /tmp/aurpkglist_laptop.txt
            else
                $AUR_HELPER -S --needed --noconfirm - < "$DOTFILES_DIR/pkglist/aurpkglist.txt" || true
            fi
        else
            echo "[!] No AUR helper (yay/paru) found. Please install AUR packages manually from pkglist/aurpkglist.txt."
        fi
    fi
fi

# 4. Stow Packages Execution with Conflict Adoption
PACKAGES=(
    "alacritty"
    "autostart"
    "btop"
    "clash-verge"
    "dunst"
    "git"
    "gtk"
    "hypr"
    "jetbra"
    "kvantum"
    "lazydocker"
    "mpv"
    "nwg-look"
    "qt6ct"
    "scripts"
    "wallpapers"
    "waybar"
    "wlogout"
    "fuzzel"
    "gsimplecal"
    "swayosd"
    "zed"
    "zsh"
)

echo "[*] Stowing modules to $HOME_DIR..."
cd "$DOTFILES_DIR"

for pkg in "${PACKAGES[@]}"; do
    if [ -d "$DOTFILES_DIR/$pkg" ]; then
        echo "  -> Stowing $pkg..."
        stow --adopt -R -v -t "$HOME_DIR" "$pkg" || true
    fi
done

# Ensure dotfiles repo files are clean after adopt
git checkout .

# 5. SDDM Theme Setup
if [ -f "$DOTFILES_DIR/sddm/etc/sddm.conf.d/90-theme.conf" ]; then
    echo "[*] Setting up SDDM theme configuration..."
    sudo mkdir -p /etc/sddm.conf.d
    sudo cp "$DOTFILES_DIR/sddm/etc/sddm.conf.d/90-theme.conf" /etc/sddm.conf.d/90-theme.conf
fi

if [ "$HOST_TYPE" = "laptop" ] && [ -f "$DOTFILES_DIR/sddm/etc/sddm.conf.d/hidpi.conf" ]; then
    echo "[*] Laptop detected: Setting up SDDM HiDPI configuration..."
    sudo mkdir -p /etc/sddm.conf.d
    sudo cp "$DOTFILES_DIR/sddm/etc/sddm.conf.d/hidpi.conf" /etc/sddm.conf.d/hidpi.conf
fi

# 6. JetBrains Helper Script Execution
if [ -f "$HOME_DIR/jetbra/scripts/install.sh" ]; then
    echo "[*] Initializing JetBrains VM options helper (jetbra)..."
    bash "$HOME_DIR/jetbra/scripts/install.sh" || true
fi

# 7. Clash Verge Subscription Check
CLASH_PROFILE_DIR="$HOME_DIR/.local/share/io.github.clash-verge-rev.clash-verge-rev/profiles"
if [ -d "$CLASH_PROFILE_DIR" ] && [ ! -f "$CLASH_PROFILE_DIR/RPJ7NUqSGvZM.yaml" ]; then
    echo "------------------------------------------------------"
    echo "[!] Clash Verge subscription server list not found."
    read -p "[?] Enter your VPN Subscription URL (or press Enter to skip): " SUB_URL
    if [ -n "$SUB_URL" ]; then
        echo "[*] Downloading Clash subscription profile..."
        curl -sL "$SUB_URL" -o "$CLASH_PROFILE_DIR/RPJ7NUqSGvZM.yaml" || true
        echo "[+] Subscription saved to $CLASH_PROFILE_DIR/RPJ7NUqSGvZM.yaml"
    fi
fi

# 8. Reload Hyprland if running
if command -v hyprctl &>/dev/null; then
    hyprctl reload 2>/dev/null || true
fi

echo "======================================================"
echo "   [✓] Dotfiles deployment finished successfully!     "
echo "======================================================"
