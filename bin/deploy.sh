#!/bin/sh

DOT_DIRECTORY="${HOME}/dotfiles"
DOT_CONFIG_DIRECTORY=".config"

deploy () {
	# Link home directory dotfiles.
	cd ${DOT_DIRECTORY}
	for f in .??*
	do
		[ "$f" = ".git" ] && continue
		[ "$f" = "bin" ] && continue
		[ "$f" = ".config" ] && continue
		[ "$f" = "host" ] && continue

		ln -snfv ${DOT_DIRECTORY}/${f} ${HOME}/${f}
	done

	# Link .config directory dotfiles.
	cd ${DOT_DIRECTORY}/${DOT_CONFIG_DIRECTORY}
	for file in `\find . -maxdepth 1 -type d`; do
		# make .config directory if not exists.
		[ "$file" = ".config" ] && continue

		if [ ! -e "${HOME}/${DOT_CONFIG_DIRECTORY}" ]; then
			mkdir "${HOME}/${DOT_CONFIG_DIRECTORY}"
		fi

		ln -snfv ${DOT_DIRECTORY}/${DOT_CONFIG_DIRECTORY}/${file:2} ${HOME}/${DOT_CONFIG_DIRECTORY}/${file:2}
	done

	# Link home directory dotfiles and .config directory dotfiles which is enviroment dependent.
	case `hostname -s` in
		"arcturus") 
			ln -snfv ${DOT_DIRECTORY}/host/arcturus/.Xresources ${HOME}/.Xresources
			ln -snfv ${DOT_DIRECTORY}/host/arcturus/i3 ${HOME}/${DOT_CONFIG_DIRECTORY}/i3
			ln -snfv ${DOT_DIRECTORY}/host/arcturus/polybar ${HOME}/${DOT_CONFIG_DIRECTORY}/polybar
		;;
		"spica") 
			ln -snfv ${DOT_DIRECTORY}/host/spica/.Xresources ${HOME}/.Xresources
			ln -snfv ${DOT_DIRECTORY}/host/spica/i3 ${HOME}/${DOT_CONFIG_DIRECTORY}/i3
			ln -snfv ${DOT_DIRECTORY}/host/spica/polybar ${HOME}/${DOT_CONFIG_DIRECTORY}/polybar
		;;
		*)
		;;
	esac

	echo "linked dotfiles complete!"
}

deploy_minimum () {
	ln -snfv ${DOT_DIRECTORY}/.zshrc ${HOME}/.zshrc
	ln -snfv ${DOT_DIRECTORY}/.emacs.d ${HOME}/.emacs.d
}

if [[ $1 == "-m" ]]; then
	deploy_minimum
else
	deploy
fi
