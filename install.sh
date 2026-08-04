#!/usr/bin/env bash
#
# Dotfiles Unified Entry Point Bootstrap Script
# Usage: ./install.sh
#

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

echo "======================================================"
echo "         Deploying Dotfiles via GNU Stow              "
echo "======================================================"
echo "Root directory: $DOTFILES_DIR"

# 1. Ensure stow is installed
if ! command -v stow &>/dev/null; then
    echo "[!] GNU Stow is not installed. Installing via pacman..."
    sudo pacman -S --noconfirm stow
fi

# 2. Package sync option
if [ -f "$DOTFILES_DIR/pkglist/pkglist.txt" ]; then
    read -p "[?] Do you want to check and install missing official packages from pkglist.txt? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "[*] Installing official pacman packages..."
        sudo pacman -S --needed --noconfirm - < "$DOTFILES_DIR/pkglist/pkglist.txt" || true
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
            $AUR_HELPER -S --needed --noconfirm - < "$DOTFILES_DIR/pkglist/aurpkglist.txt" || true
        else
            echo "[!] No AUR helper (yay/paru) found. Please install AUR packages manually from pkglist/aurpkglist.txt."
        fi
    fi
fi

# 3. Stow Packages Execution
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
    "wofi"
    "zed"
    "zsh"
)

echo "[*] Stowing modules to $HOME_DIR..."
cd "$DOTFILES_DIR"

for pkg in "${PACKAGES[@]}"; do
    if [ -d "$DOTFILES_DIR/$pkg" ]; then
        echo "  -> Stowing $pkg..."
        stow -R -v -t "$HOME_DIR" "$pkg"
    fi
done

# 4. SDDM Theme Setup
if [ -f "$DOTFILES_DIR/sddm/etc/sddm.conf.d/90-theme.conf" ]; then
    echo "[*] Setting up SDDM theme configuration..."
    sudo mkdir -p /etc/sddm.conf.d
    sudo cp "$DOTFILES_DIR/sddm/etc/sddm.conf.d/90-theme.conf" /etc/sddm.conf.d/90-theme.conf
fi

# 5. JetBrains Helper Script Execution
if [ -f "$HOME_DIR/jetbra/scripts/install.sh" ]; then
    echo "[*] Initializing JetBrains VM options helper (jetbra)..."
    bash "$HOME_DIR/jetbra/scripts/install.sh" || true
fi

# 6. Clash Verge Subscription Check
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

echo "======================================================"
echo "   [✓] Dotfiles deployment finished successfully!     "
echo "======================================================"
