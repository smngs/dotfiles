#!/bin/bash
set -euo pipefail

DOT_DIRECTORY="${HOME}/dotfiles"
PKG_DIRECTORY="${DOT_DIRECTORY}/packages"

if [ ! -f /etc/arch-release ]; then
    echo "Not an Arch Linux system. Skipping..."
    exit 0
fi

echo "run pacman -Syu..."
sudo pacman -Syu --noconfirm

if ! command -v paru >/dev/null 2>&1; then
    echo "installing paru..."
    sudo pacman -S --needed --noconfirm base-devel git
    tmp_dir="$(mktemp -d)"
    git clone https://aur.archlinux.org/paru.git "${tmp_dir}/paru"
    (cd "${tmp_dir}/paru" && makepkg -si --noconfirm)
    rm -rf "${tmp_dir}"
fi

paru --version

if [ -f "${PKG_DIRECTORY}/arch-repo.txt" ]; then
    echo "installing official repository packages..."
    paru -S --needed --noconfirm - < "${PKG_DIRECTORY}/arch-repo.txt"
fi

if [ -f "${PKG_DIRECTORY}/arch-aur.txt" ]; then
    echo "installing AUR packages..."
    paru -S --needed --noconfirm - < "${PKG_DIRECTORY}/arch-aur.txt"
fi

# Arch's deno links against the system libsqlite3, which collides with the
# library @db/sqlite dlopens over FFI and segfaults (this breaks zeno, and
# with it the Enter key). The upstream build bundles its own SQLite.
if [ ! -x "${HOME}/.deno/bin/deno" ]; then
    echo "installing the official deno build..."
    DENO_INSTALL="${HOME}/.deno" sh -c "$(curl -fsSL https://deno.land/install.sh)" -- -y
fi

if pacman -Qq deno >/dev/null 2>&1; then
    echo "removing the distro deno in favour of the official build..."
    sudo pacman -Rns --noconfirm deno || true
fi

cat << END
**************************************************
ARCH PACKAGES INSTALLED! bye.
**************************************************
END
