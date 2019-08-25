#!/bin/sh

set -u
DOT_DIRECTORY="${HOME}/dotfiles"
DOT_CONFIG_DIRECTORY=".config"

# Backup home directory dotfiles.
cd ${DOT_DIRECTORY}
for f in .??*
do
    [ "$f" = ".git" ] && continue
    [ "$f" = "bin" ] && continue

    if [ -e "${HOME}/$f" ]; then
    	if [ ! -e "${HOME}/dotfiles-backup" ]; then
	    	mkdir "${HOME}/dotfiles-backup"
	    fi
        cp -r "${HOME}/$f" "${HOME}/dotfiles-backup" 
    fi
done

echo "Backup dotfiles complete!"

