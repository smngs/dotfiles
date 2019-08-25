#!/bin/sh

set -u
DOT_DIRECTORY="${HOME}/dotfiles"
DOT_CONFIG_DIRECTORY=".config"

# Delete home directory dotfiles.
cd ${DOT_DIRECTORY}
for f in .??*
do
    [ "$f" = ".git" ] && continue
    [ "$f" = "bin" ] && continue
    [ "$f" = ".config" ] && continue
    [ "$f" = "host" ] && continue

    rm -rf ${HOME}/${f}
done

# Delete .config directory dotfiles.
cd ${DOT_DIRECTORY}/${DOT_CONFIG_DIRECTORY}
for file in `\find . -maxdepth 1 -type d`; do
    [ "$file" = ".config" ] && continue

    rm -rf ${HOME}/${DOT_CONFIG_DIRECTORY}/${file:2}
done

rm -rf ${HOME}/.Xresources
rm -rf ${HOME}/${DOT_CONFIG_DIRECTORY}/i3
rm -rf ${HOME}/${DOT_CONFIG_DIRECTORY}/polybar

echo "linked dotfiles complete!"
