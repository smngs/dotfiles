
#!/bin/sh

DOT_DIRECTORY="${HOME}/dotfiles"
DOT_CONFIG_DIRECTORY=".config"
DOT_URL="https://git.mine-313.com/syota/dotfiles.git"

dotfiles_logo='
     _       _    __ _ _           
  __| | ___ | |_ / _(_) | ___  ___ 
 / _` |/ _ \| __| |_| | |/ _ \/ __|
| (_| | (_) | |_|  _| | |  __/\__ \
 \__,_|\___/ \__|_| |_|_|\___||___/
'

backup () {
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
}

download () {
	if [ -d "$DOT_DIRECTORY" ]; then
		echo "[ERROR] $DOTPATH: Already exists."
		exit 1
	fi

	echo "Downloading dotfiles ..."
	
	if [ -x "`which git`" ]; then
		git clone --recursive "$DOT_URL" "DOT_DIRECTORY"
	else
		echo "[ERROR] Please install Git."
		exit 1
	fi
}

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

clean () {
	# Delete home directory dotfiles.
	cd ${DOT_DIRECTORY}
	for f in .??*
	do
		[ "$f" = ".git" ] && continue
		[ "$f" = "bin" ] && continue
		[ "$f" = ".config" ] && continue
		[ "$f" = "host" ] && continue

		rm -rf "${HOME}/${f}"
	done

	# Delete .config directory dotfiles.
	cd ${DOT_DIRECTORY}/${DOT_CONFIG_DIRECTORY}
	for file in `\find . -maxdepth 1 -type d`; do
		[ -n "$f" ] && continue
		rm -rf "${HOME}/${DOT_CONFIG_DIRECTORY}/${file:2}"
	done

	rm -rf ${HOME}/.Xresources
	rm -rf ${HOME}/${DOT_CONFIG_DIRECTORY}/i3
	rm -rf ${HOME}/${DOT_CONFIG_DIRECTORY}/polybar

	echo "Deleted dotfiles complete!"
}

install () {
	echo "$dotfiles_logo"
	echo -n "Are you sure install dotfile? [Y/n]:"
	read answer

	case $answer in
		"" | [Yy]* )
			download
			deploy
			init
			;;
		* )
			echo "[ERROR] Install cancelled."
			;;
	esac
}
		
help () {
	echo "<usage> -d -dm -b -c"
}

if [[ $1 == "-d" ]]; then
	deploy
elif [[ $1 == "-dm" ]]; then
	deploy_minimum
elif [[ $1 == "-b" ]]; then
	backup
elif [[ $1 == "-c" ]]; then
	clean
elif [[ $1 == "-i" ]]; then
	install
else
	help
fi
