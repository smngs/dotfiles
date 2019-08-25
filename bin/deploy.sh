#!/bin/sh

set -u
DOT_DIRECTORY="${HOME}/dotfiles"
DOT_CONFIG_DIRECTORY=".config"

# Backup and Link home directory dotfiles.
cd ${DOT_DIRECTORY}
for f in .??*
do
    [ "$f" = ".git" ] && continue
    [ "$f" = "bin" ] && continue
    [ "$f" = ".config" ] && continue

    ln -snfv ${DOT_DIRECTORY}/${f} ${HOME}/${f}
done

# Link .config directory dotfiles.
cd ${DOT_DIRECTORY}/${DOT_CONFIG_DIRECTORY}
for file in `\find . -maxdepth 1 -type d`; do
    # make .config directory if not exists.
    if [ ! -e "${HOME}/${DOT_CONFIG_DIRECTORY}" ]; then
    	mkdir "${HOME}/${DOT_CONFIG_DIRECTORY}"
    fi

    [ "$file" = ".config" ] && continue
    ln -snfv ${DOT_DIRECTORY}/${DOT_CONFIG_DIRECTORY}/${file:2} ${HOME}/${DOT_CONFIG_DIRECTORY}/${file:2}
done

echo "linked dotfiles complete!"

