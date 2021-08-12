#!/bin/sh

DOT_DIRECTORY="${HOME}/dotfiles"
DOT_CONFIG_DIRECTORY="config"
DOT_HOME_DIRECTORY="home"
DOT_URL="https://github.com/smngs/dotfiles.git"

var1=$1
var2=$2
dotfiles_logo='
     _       _    __ _ _           
  __| | ___ | |_ / _(_) | ___  ___ 
 / _` |/ _ \| __| |_| | |/ _ \/ __|
| (_| | (_) | |_|  _| | |  __/\__ \
 \__,_|\___/ \__|_| |_|_|\___||___/
'

readonly LOGFILE="/tmp/${0##*/}.log"
readonly PROCNAME=${0##*/}

function log_warn() {
    local fname=${BASH_SOURCE[1]##*/}
    echo -e "\033[0;33mWARN:\033[0;39m $(date '+%Y-%m-%dT%H:%M:%S') ${PROCNAME} (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $@" | tee -a ${LOGFILE}
}

function log_question() {
    local fname=${BASH_SOURCE[1]##*/}
    echo -e "\033[0;33mQUESTION:\033[0;39m $(date '+%Y-%m-%dT%H:%M:%S') ${PROCNAME} (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $@" | tee -a ${LOGFILE}
}

function log_info() {
    local fname=${BASH_SOURCE[1]##*/}
    echo -e "\033[0;32mINFO:\033[0;39m $(date '+%Y-%m-%dT%H:%M:%S') ${PROCNAME} (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $@" | tee -a ${LOGFILE}
}

function log_error() {
    local fname=${BASH_SOURCE[1]##*/}
    echo -e "\033[0;31mERROR:\033[0;39m $(date '+%Y-%m-%dT%H:%M:%S') ${PROCNAME} (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $@" | tee -a ${LOGFILE}
}

backup () {
	# Backup home directory dotfiles.
	cd ${DOT_DIRECTORY}
	if [ -e "${HOME}/dotfiles-backup" ]; then
    log_question "dotfiles-backup is already exist. Do you want to overwrite? [Y/n]:"
		read answer
		case $answer in
			"" | [Yy]* )
				rm -rf "${HOME}/dotfiles-backup/*"
				mkdir "${HOME}/dotfiles-backup/*"
        log_info "Rewrite ${HOME}/dotfiles-backup."
				;;
			* )
        log_error "Backup Cancelled"
				exit 1
				;;
		esac
	else
		mkdir "${HOME}/dotfiles-backup"
    log_info "Make ${HOME}/dotfiles-backup."
	fi

	for f in .??*
	do
		[ "$f" = ".git" ] && continue
		[ "$f" = "bin" ] && continue
		if [ -e "${HOME}/$f" ]; then
			sudo cp -r "${HOME}/$f" "${HOME}/dotfiles-backup/" 
			if [ ! $? == 0 ]; then
        log_error "Backup aborted!"
				exit 1
			fi
		fi
	done

  log_info "Backup dotfiles completed!"
}

download () {
	if [ -d "$DOT_DIRECTORY" ]; then
    log_error "dotfiles already exists. -> $DOT_DIRECTORY"
		exit 1
	fi

  log_info "Downloading dotfiles..."
	
	if [ -x "`which git`" ]; then
		git clone --recursive "$DOT_URL" "$DOT_DIRECTORY"
    log_info "Download dotfiles completed."
	else
    log_error "Require Git."
		exit 1
	fi

  log_info "Pull dotfiles submodules..."
  git submodule update --init --recursive
  log_info "pull dotfiles submodules completed."
}

deploy () {
	# Deploy home directory dotfiles.
    cd ${DOT_DIRECTORY}/${DOT_HOME_DIRECTORY}
    for f in .??*
    do
        [ "$f" = ".git" ] && continue
        [ "$f" = "bin" ] && continue
        [ "$f" = ".config" ] && continue
        [ "$f" = "host" ] && continue

        ln -snfv ${DOT_DIRECTORY}/${DOT_HOME_DIRECTORY}/${f} ${HOME}/${f}
    done
    log_info "Deploy home directory dotfiles complete!"

    # Deploy .config directory dotfiles.
    cd ${DOT_DIRECTORY}/${DOT_CONFIG_DIRECTORY}
    for file in `\find . -maxdepth 1 -type d | sed '1d'`; do
        # make .config directory if not exists.
        [ "$file" = ".config" ] && continue

        if [ ! -e "${HOME}/${DOT_CONFIG_DIRECTORY}" ]; then
            mkdir "${HOME}/${DOT_CONFIG_DIRECTORY}"
        fi

        ln -snfv ${DOT_DIRECTORY}/${DOT_CONFIG_DIRECTORY}/${file:2} ${HOME}/${DOT_CONFIG_DIRECTORY}/${file:2}
    done
    log_info "Deploy .config dotfiles complete."

    if [ -d ${DOT_DIRECTORY}/host/`hostname -s` ]; then
    log_warn "hostname == `hostname -s`, Install depended dotfiles."
        cd ${DOT_DIRECTORY}/host/`hostname -s`
        for file in `\find . -maxdepth 1 | sed '1d'`; do
            ln -snfv ${DOT_DIRECTORY}/host/`hostname -s`/${file:2} ${HOME}/${DOT_CONFIG_DIRECTORY}/${file:2}
        done
    fi
    log_info "Deploy .config depended dotfiles complete!" 
}

init () {
	:
}

install () {
	echo -e "$dotfiles_logo"
  log_question "Are you sure you want to install dotfiles? [Y/n]:"
	read answer

	case $answer in
		"" | [Yy]* )
			download
      deploy
			init
			;;
		* )
      log_error "Install cancelled."
			;;
	esac
}
		
update () {
  log_info "Start dotfiles update."
  git pull origin master
  git submodule update
  log_info "Finish dotfiles update."
}

help () {
	cat <<EOF
$(basename ${0}) is a tool for deploy dotfiles.

Usage:
	$(basename ${0}) [<options>]

Options:
	--install (default)     Run Backup, Update, Deploy, Init
	--help, -h              Show helpfile
	--deploy, -d            Create symlink to home directory 
	--backup, -b            Backup dotfiles
	--update, -u            Update dotfiles
	--init, -i              Setup environment settings
EOF
}

case $var1 in
	"--deploy" ) deploy ;;
	"-d" ) deploy ;;
	"--backup" ) backup ;;
	"-b" ) backup ;;
  "--update" ) update ;;
  "-u" ) update ;;
	"--init" ) init ;;
	"-i" ) init ;;
	"--help" ) help ;;
	"-h" ) help ;;
	"--install" ) install ;;
	* ) install ;;
esac
