#!/bin/bash

if [[ $(uname -r) =~ ARCH$ ]]; then
    sudo pacman -Syu --noconfirm
    mkdir /tmp/yay
    cd /tmp/yay || exit
    curl -OJ 'https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yay'
    makepkg -si --noconfirm
    cd || exit
    rm -rf /tmp/yay
    yay --version
fi
