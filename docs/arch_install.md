## Network

```
$ sudo nvim /etc/systemd/network/20-wired.network
> [Match]
> Name=<nwdevice>
> [Network]
> DHCP=yes

$ sudo nvim /etc/resolv.conf
> nameserver 8.8.8.8
$ sudo networkctl up <nwdevice>

$ paru -S openssh net-tools inetutils
$ systemctl start sshd && systemctl enable sshd
```

## Install paru (AUR manager)

```
$ git clone https://aur.archlinux.org/paru-git
$ cd paru-git && makepkg -si
```

## NVIDIA

```
$ paru -S nvidia nvidia-utils dkms linux-headers
$ nvim /etc/mkinitcpio.conf
> HOOKS から kms を削除
$ sudo mkinitcpio -P
```

## Sway

```
$ paru -S sway-git xorg-xwayland qt5-wayland xorg lightdm lightdm-gtk-greeter
$ cp ~/dotfiles/bin/swayon.sh /usr/local/bin/swayon
$ cp /usr/share/wayland-sessions/sway.desktop /usr/share/wayland-sessions/sway-nvidia.desktop
$ sudo nvim /usr/share/wayland-sessions/sway-nvidia.desktop
> Name=Sway-Desktop
> Exec=/usr/local/bin/swayon.sh
$ systemctl enable lightdm && systemctl start lightdm
```

## Packages

```
$ paru -S archlinux-wallpaper firefox \
    mako wofi \
    fcitx5 fcitx5-im fcitx5-mozc \
    networkmanager network-manager-applet bluez bluez-tools system-config-printer \
    pipewire pavucontrol pipewire-pulse \
    slack discord discord-canary \
    ttf-cica ttf-migu \
    yazi

$ fcitx-configtool

$ systemctl --user --now enable pipewire{,-pulse}.{socket,service}
> Available Input Method から mozc を追加

$ nvim .config/fcitx5/config
> [Hotkey/ActivateKeys]
> 0=Super_R
> [Hotkey/DeactivateKeys]
> 0=Super_L
```

## npm/textlint

```
$ paru -S npm eslint typescript textlint remark-language-server
$ npm install -g textlint textlint-plugin-latex2e textlint-rule-preset-ja-technical-writing

```

## Shell Tools (Rust)

```
$ paru -S exa bat hexyl procs
```

## Smartcard

```
$ paru -S ccid opensc
$ systemctl restart pcscd.servide
```

## Docker
```
$ paru -S docker docker-compose 
$ systemctl restart docker $$ systemctl enable docker
```
