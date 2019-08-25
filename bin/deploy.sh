#!/bin/sh

set -u
DOT_DIRECTORY="${HOME}/dotfiles"
DOT_CONFIG_DIRECTORY=".config"

# Link home directory dotfiles.
cd ${DOT_DIRECTORY}
for f in .??*
do
    [ "$f" = ".git" ] && continue
    [ "$f" = "bin" ] && continue
    [ "$f" = ".config" ] && continue
    [ "$f" = ".Xresources" ] && continue

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
    [ "$file" = "i3" ] && continue
    [ "$file" = "polybar" ] && continue

    ln -snfv ${DOT_DIRECTORY}/${DOT_CONFIG_DIRECTORY}/${file:2} ${HOME}/${DOT_CONFIG_DIRECTORY}/${file:2}
done

# Link home directory dotfiles and .config directory dotfiles which is enviroment dependent.
case `hostname -s` in
    "arcturus") 
        ln -snfv ${DOT_DIRECTORY}/arcturus/.Xresources ${HOME}/.Xresources
        ln -snfv ${DOT_DIRECTORY}/arcturus/i3 ${HOME}/${DOT_CONFIG_DIRECTORY}/i3
        ln -snfv ${DOT_DIRECTORY}/arcturus/polybar ${HOME}/${DOT_CONFIG_DIRECTORY}/polybar
    ;;
    "spica") 
        ln -snfv ${DOT_DIRECTORY}/spica/.Xresources ${HOME}/.Xresources
        ln -snfv ${DOT_DIRECTORY}/spica/i3 ${HOME}/${DOT_CONFIG_DIRECTORY}/i3
        ln -snfv ${DOT_DIRECTORY}/spica/polybar ${HOME}/${DOT_CONFIG_DIRECTORY}/polybar
    ;;
    *)
    ;;
esac

echo "linked dotfiles complete!"
