#!/bin/bash
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE:-$0}")" || exit; pwd)
DOT_DIRECTORY="${HOME}/dotfiles"
DOT_CONFIG_DIRECTORY="config"
DOT_CONFIG_HOST_DIRECTORY="config"
DOT_HOME_DIRECTORY="home"
DOT_HOST_DIRECTORY="host"
DOT_URL="https://github.com/smngs/dotfiles.git"

source "${SCRIPT_DIR}/shell-logger.sh"

dotfiles_logo='
     _       _    __ _ _           
  __| | ___ | |_ / _(_) | ___  ___ 
 / _` |/ _ \| __| |_| | |/ _ \/ __|
| (_| | (_) | |_|  _| | |  __/\__ \
 \__,_|\___/ \__|_| |_|_|\___||___/
'

backup () {
	# Backup home directory dotfiles.
	cd "${DOT_DIRECTORY}" || exit
	if [ -e "${HOME}/dotfiles-backup" ]; then
    notice "dotfiles-backup is already exist. Do you want to overwrite? [Y/n]:"
		read -r answer
		case $answer in
			"" | [Yy]* )
				rm -rf "${HOME}/dotfiles-backup/*"
				mkdir "${HOME}/dotfiles-backup/*"
        info "Rewrite ${HOME}/dotfiles-backup."
				;;
			* )
        err "Backup Cancelled"
				exit 1
				;;
		esac
	else
		mkdir "${HOME}/dotfiles-backup"
    info "Make ${HOME}/dotfiles-backup."
	fi

	for f in .??*
	do
		[ "$f" = ".git" ] && continue
		[ "$f" = "bin" ] && continue
		if [ -e "${HOME}/$f" ]; then
			sudo cp -r "${HOME}/$f" "${HOME}/dotfiles-backup/" 
			if [ ! $? == 0 ]; then
        err "Backup aborted!"
				exit 1
			fi
		fi
	done

  info "Backup dotfiles completed!"
}

download () {
	if [ -d "${DOT_DIRECTORY}" ]; then
    err "dotfiles already exists. -> $DOT_DIRECTORY"
  else
    info "Downloading dotfiles..."
    
    if [ -x "$(which git)" ]; then
      git clone --recursive "$DOT_URL" "$DOT_DIRECTORY"
      info "Download dotfiles completed."
    else
      err "Require Git."
      exit 1
    fi
	fi

  info "Pull dotfiles submodules..."
  git submodule update --init --recursive
  info "pull dotfiles submodules completed."
}

deploy () {
	# Deploy home directory dotfiles.
    cd "${DOT_DIRECTORY}/${DOT_HOME_DIRECTORY}" || exit
    for f in .??*
    do
        [ "$f" = ".git" ] && continue
        [ "$f" = "bin" ] && continue
        [ "$f" = ".config" ] && continue
        [ "$f" = "host" ] && continue

        ln -snfv "${DOT_DIRECTORY}"/${DOT_HOME_DIRECTORY}/"${f}" "${HOME}"/"${f}"
    done
    info "Deploy home directory dotfiles complete."

    # Deploy .config directory dotfiles.
    cd "${DOT_DIRECTORY}/${DOT_CONFIG_DIRECTORY}" || exit
    for file in $(\find . -maxdepth 1 -type d | sed '1d'); do
        # make .config directory if not exists.
        [ "$file" = ".config" ] && continue

        if [ ! -e "${HOME}/${DOT_CONFIG_DIRECTORY}" ]; then
            mkdir "${HOME}/${DOT_CONFIG_DIRECTORY}"
        fi

        ln -snfv "${DOT_DIRECTORY}"/${DOT_CONFIG_DIRECTORY}/"${file:2}" "${HOME}"/.${DOT_CONFIG_HOST_DIRECTORY}/"${file:2}"
    done
    info "Deploy .config dotfiles complete."

    if [ -d "${DOT_DIRECTORY}"/${DOT_HOST_DIRECTORY}/"$(hostname -s)" ]; then
    warn "hostname == $(hostname -s), Install depended dotfiles."
        cd "${DOT_DIRECTORY}"/${DOT_HOST_DIRECTORY}/"$(hostname -s)" || exit
        for file in $(\find . -maxdepth 1 | sed '1d'); do
            ln -snfv "${DOT_DIRECTORY}"/${DOT_HOST_DIRECTORY}/"$(hostname -s)"/"${file:2}" "${HOME}"/.${DOT_CONFIG_HOST_DIRECTORY}/"${file:2}"
        done
    fi
    info "Deploy .config depended dotfiles complete."
}

init () {
	echo -e "$dotfiles_logo"
  notice "Are you sure you want to install dotfiles? [Y/n]:"
	read -r answer

	case $answer in
		"" | [Yy]* )
      download
      update
      deploy
      install
			;;
		* )
      err "Install cancelled."
			;;
	esac
}

install () {
  if [ "$(uname)" == 'Darwin' ]; then
    echo "Your platform: MacOS"
    "${SCRIPT_DIR}"/homebrew_install.sh
  elif [ "$(expr substr "$(uname -s)" 1 5)" == 'Linux' ]; then
    echo "Your platform: Linux"
    "${SCRIPT_DIR}"/arch_install.sh
  else
    echo "Your platform ($(uname -a)) is not supported. Skipping..."
  fi
}
		
update () {
  info "Start dotfiles update."
  git pull origin master
  git submodule update
  info "Finish dotfiles update."
}

help () {
	cat <<EOF
$(basename "${0}") is a tool for deploy dotfiles.
Usage:
	$(basename "${0}") [<options>]
Options:
	--install (default)     Run Backup, Update, Deploy, Init
	--help, -h              Show helpfile
	--deploy, -d            Create symlink to home directory 
	--backup, -b            Backup dotfiles
	--update, -u            Update dotfiles
	--init, -i              Setup environment settings
EOF
}

case $1 in
	"deploy" ) deploy ;;
	"--deploy" ) deploy ;;
	"-d" ) deploy ;;
	"backup" ) backup ;;
	"--backup" ) backup ;;
	"-b" ) backup ;;
  "update" ) update ;;
  "--update" ) update ;;
  "-u" ) update ;;
	"init" ) init ;;
	"--init" ) init ;;
	"-i" ) init ;;
	"help" ) help ;;
	"--help" ) help ;;
	"-h" ) help ;;
	"install" ) install ;;
	"--install" ) install ;;
	* ) init ;;
esac
