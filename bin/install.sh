
#!/bin/sh

DOT_DIRECTORY="${HOME}/dotfiles"
DOT_CONFIG_DIRECTORY=".config"
DOT_URL="https://git.mine-313.com/syota/dotfiles.git"

var1=$1
var2=$2
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
	if [ -e "${HOME}/dotfiles-backup" ]; then
		echo -e -n "\033[0;33mWARN:\033[0;39m ${HOME}/dotfiles-backup is already exist. Do you want to overwrite? [Y/n]:"
		read answer
		case $answer in
			"" | [Yy]* )
				rm -rf "${HOME}/dotfiles-backup/*"
				mkdir "${HOME}/dotfiles-backup/*"
				echo -e "\033[0;32mINFO:\033[0;39m Rewrite ${HOME}/dotfiles-backup."
				;;
			* )
				echo -e "\033[0;31mERROR:\033[0;39m Backup cancelled."
				exit 0
				;;
		esac
	else
		mkdir "${HOME}/dotfiles-backup"
		echo -e "\033[0;32mINFO:\033[0;39m Make ${HOME}/dotfiles-backup."
	fi

	for f in .??*
	do
		[ "$f" = ".git" ] && continue
		[ "$f" = "bin" ] && continue
		if [ -e "${HOME}/$f" ]; then
			sudo cp -r "${HOME}/$f" "${HOME}/dotfiles-backup/" 
			if [ ! $? == 0 ]; then
				echo -e "\033[0;31mERROR:\033[0;39m Backup aborted!"
				exit 1
			fi
		fi
	done

	echo -e "\033[0;32mINFO:\033[0;39m Backup dotfiles complete!"
}

download () {
	if [ -d "$DOT_DIRECTORY" ]; then
		echo -e "\033[0;31mERROR:\033[0;39m dotfiles already exists. -> $DOT_DIRECTORY"
		exit 1
	fi

	echo -e "\033[0;32mINFO:\033[0;39m Downloading dotfiles..."
	
	if [ -x "`which git`" ]; then
		git clone --recursive "$DOT_URL" "DOT_DIRECTORY"
		echo -e "\033[0;32mINFO:\033[0;39m Download dotfiles complete!"
	else
		echo -e "\033[0;31mERROR:\033[0;39m Require Git."
		exit 1
	fi
}

deploy () {
	# Deploy home directory dotfiles.
	case "$var2" in
		"-m" )
			ln -snfv ${DOT_DIRECTORY}/.zshrc ${HOME}/.zshrc
			ln -snfv ${DOT_DIRECTORY}/.emacs.d ${HOME}/.emacs.d
			echo -e "\033[0;32mINFO:\033[0;39m Deploy .zshrc and .emacs.d complete!"
			exit 0
		;;

		* )
			cd ${DOT_DIRECTORY}
			for f in .??*
			do
				[ "$f" = ".git" ] && continue
				[ "$f" = "bin" ] && continue
				[ "$f" = ".config" ] && continue
				[ "$f" = "host" ] && continue

				ln -snfv ${DOT_DIRECTORY}/${f} ${HOME}/${f}
			done
			echo -e "\033[0;32mINFO:\033[0;39m Deploy home directory dotfiles complete!"

			# Deploy .config directory dotfiles.
			cd ${DOT_DIRECTORY}/${DOT_CONFIG_DIRECTORY}
			for file in `\find . -maxdepth 1 -type d`; do
				# make .config directory if not exists.
				[ "$file" = ".config" ] && continue

				if [ ! -e "${HOME}/${DOT_CONFIG_DIRECTORY}" ]; then
					mkdir "${HOME}/${DOT_CONFIG_DIRECTORY}"
				fi

				ln -snfv ${DOT_DIRECTORY}/${DOT_CONFIG_DIRECTORY}/${file:2} ${HOME}/${DOT_CONFIG_DIRECTORY}/${file:2}
			done
			echo -e "\033[0;32mINFO:\033[0;39m Deploy .config dotfiles complete!"

			# Deploy home directory dotfiles and .config directory dotfiles which is enviroment dependent.
			case `hostname -s` in
				"arcturus") 
					echo -e "\033[0;32mINFO:\033[0;39m hostname == arcturus, Install depended dotfiles."
					ln -snfv ${DOT_DIRECTORY}/host/arcturus/.Xresources ${HOME}/.Xresources
					ln -snfv ${DOT_DIRECTORY}/host/arcturus/i3 ${HOME}/${DOT_CONFIG_DIRECTORY}/i3
					ln -snfv ${DOT_DIRECTORY}/host/arcturus/polybar ${HOME}/${DOT_CONFIG_DIRECTORY}/polybar
					echo -e "\033[0;32mINFO:\033[0;39m Deploy depended dotfiles complete!"
				;;
				"spica") 
					echo -e "\033[0;32mINFO:\033[0;39m hostname == spica, Install depended dotfiles."
					ln -snfv ${DOT_DIRECTORY}/host/spica/.Xresources ${HOME}/.Xresources
					ln -snfv ${DOT_DIRECTORY}/host/spica/i3 ${HOME}/${DOT_CONFIG_DIRECTORY}/i3
					ln -snfv ${DOT_DIRECTORY}/host/spica/polybar ${HOME}/${DOT_CONFIG_DIRECTORY}/polybar
					echo -e "\033[0;32mINFO:\033[0;39m Deploy depended dotfiles complete!"
				;;
				*)
				;;
			esac
			;;
		esac
}

clean () {
	# Delete home directory dotfiles.
	echo -e -n "\033[0;33mWARN:\033[0;39m DEPRECATED!! Are you sure you want to clean dotfiles? [y/N]:"
	read answer
	
	case $answer in
		[Yy]* )
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
				[ "$f" == "./" ] && continue
				rm -rf "${HOME}/${DOT_CONFIG_DIRECTORY}/${file:2}"
			done

			rm -rf ${HOME}/.Xresources
			rm -rf ${HOME}/${DOT_CONFIG_DIRECTORY}/i3
			rm -rf ${HOME}/${DOT_CONFIG_DIRECTORY}/polybar

			echo -e "\033[0;32mINFO:\033[0;39m Clean dotfiles complete!"
			;;
		* )
			echo -e "\033[0;31mERROR:\033[0;39m Clean cancelled."
			;;
	esac
}

init () {
	:
}

install () {
	echo -e "$dotfiles_logo"
	echo -e -n "\033[0;33mWARN:\033[0;39m Are you sure you want to install dotfiles? [Y/n]:"
	read answer

	case $answer in
		"" | [Yy]* )
			download
			if [[ $var2 == "-m" ]]; then
				deploy_minimam
			else
				deploy
			fi
			init
			;;
		* )
			echo -e "\033[0;31mERROR:\033[0;39m Install cancelled."
			;;
	esac
}
		
help () {
	cat <<EOF
$(basename ${0}) is a tool for deploy dotfiles.

Usage:
	$(basename ${0}) [<options>] [-m]

Options:
	--install (default)     Run Backup, Update, Deploy, Init
	--help, -h              Show helpfile
	--deploy, -d            Create symlink to home directory 
	--backup, -b            Backup dotfiles
	--clean, -c             Cleanup dotfiles
	--init, -i              Setup environment settings

	-m                      Install and Deploy minimal (only .zshrc and .emacs.d)
EOF
}
case $var1 in
	"--deploy" ) deploy ;;
	"-d" ) deploy ;;
	"--backup" ) backup ;;
	"-b" ) backup ;;
	"--clean" ) clean ;;
	"-c" ) clean ;;
	"--init" ) init ;;
	"-i" ) init ;;
	"--help" ) help ;;
	"-h" ) help ;;
	"--install" ) install ;;
	* ) install ;;
esac
