#!/bin/bash
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE:-$0}")" || exit; pwd)
DOT_DIRECTORY="${HOME}/dotfiles"
DOT_CONFIG_DIRECTORY="config"
DOT_CONFIG_HOST_DIRECTORY="config"
DOT_HOME_DIRECTORY="home"
DOT_HOST_DIRECTORY="host"
DOT_URL="https://github.com/smngs/dotfiles.git"
CLAUDE_URL="https://github.com/smngs/claude.git"
CLAUDE_DIR="${HOME}/.claude"
NOTE_URL="https://github.com/smngs/note.git"
NOTE_DIR="${HOME}/note"

# shellcheck source=shell-logger.sh
source "${SCRIPT_DIR}/shell-logger.sh" 2>/dev/null || {
  info()   { echo "[INFO] $*"; }
  notice() { echo "[NOTICE] $*"; }
  warn()   { echo "[WARNING] $*"; }
  err()    { echo "[ERROR] $*"; }
}

dotfiles_logo='
     _       _    __ _ _           
  __| | ___ | |_ / _(_) | ___  ___ 
 / _` |/ _ \| __| |_| | |/ _ \/ __|
| (_| | (_) | |_|  _| | |  __/\__ \
 \__,_|\___/ \__|_| |_|_|\___||___/
'

backup () {
	# Backup home directory dotfiles.
	cd "${DOT_DIRECTORY}/${DOT_HOME_DIRECTORY}" || exit
	if [ -e "${HOME}/dotfiles-backup" ]; then
    notice "dotfiles-backup is already exist. Do you want to overwrite? [Y/n]:"
		read -r answer
		case $answer in
			"" | [Yy]* )
				rm -rf "${HOME:?}/dotfiles-backup"
				mkdir -p "${HOME}/dotfiles-backup"
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
			if ! cp -r "${HOME}/$f" "${HOME}/dotfiles-backup/"; then
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
    
    if command -v git >/dev/null 2>&1; then
      git clone "$DOT_URL" "$DOT_DIRECTORY"
      info "Download dotfiles completed."
    else
      err "Require Git."
      exit 1
    fi
	fi

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
        [ "$f" = ".claude" ] && continue

        ln -snfv "${DOT_DIRECTORY}"/${DOT_HOME_DIRECTORY}/"${f}" "${HOME}"/"${f}"
    done
    info "Deploy home directory dotfiles complete."

    # Deploy .config directory dotfiles.
    mkdir -p "${HOME}/.${DOT_CONFIG_DIRECTORY}"
    cd "${DOT_DIRECTORY}/${DOT_CONFIG_DIRECTORY}" || exit
    for dir in */; do
        dir="${dir%/}"
        [ -e "$dir" ] || continue
        ln -snfv "${DOT_DIRECTORY}"/${DOT_CONFIG_DIRECTORY}/"${dir}" "${HOME}"/.${DOT_CONFIG_HOST_DIRECTORY}/"${dir}"
    done
    info "Deploy .config dotfiles complete."

    if [ -d "${DOT_DIRECTORY}"/${DOT_HOST_DIRECTORY}/"$(hostname -s)" ]; then
    warn "hostname == $(hostname -s), Install depended dotfiles."
        cd "${DOT_DIRECTORY}"/${DOT_HOST_DIRECTORY}/"$(hostname -s)" || exit
        for entry in * .??*; do
            [ -e "$entry" ] || continue
            ln -snfv "${DOT_DIRECTORY}"/${DOT_HOST_DIRECTORY}/"$(hostname -s)"/"${entry}" "${HOME}"/.${DOT_CONFIG_HOST_DIRECTORY}/"${entry}"
        done
    fi
    info "Deploy .config depended dotfiles complete."

    # Deploy Claude Code configuration.
    if [ -d "${CLAUDE_DIR}" ]; then
      info "Claude config already exists at ${CLAUDE_DIR}. Skipping clone."
    else
      info "Cloning Claude config..."
      git clone "${CLAUDE_URL}" "${CLAUDE_DIR}"
      info "Deploy Claude config complete."
    fi

    # Clone note repository if not already present.
    if [ -d "${NOTE_DIR}" ]; then
      info "Note repository already exists at ${NOTE_DIR}. Skipping clone."
    else
      info "Cloning note repository..."
      git clone "${NOTE_URL}" "${NOTE_DIR}"
      info "Clone note repository complete."
    fi

    # Create memory symlink to Obsidian vault if not already present.
    VAULT_MEMORY="${NOTE_DIR}/99_Claude/Memory"
    CLAUDE_MEMORY="${CLAUDE_DIR}/memory"
    if [ -d "${VAULT_MEMORY}" ] && [ ! -e "${CLAUDE_MEMORY}" ]; then
      ln -s "${VAULT_MEMORY}" "${CLAUDE_MEMORY}"
      info "Memory symlink created: ${CLAUDE_MEMORY} -> ${VAULT_MEMORY}"
    fi
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

install_skk_dict () {
  # skkeleton needs a plain SKK dictionary; it is not packaged by Homebrew
  SKK_DICT="${HOME}/.local/share/skk/SKK-JISYO.L"
  if [ -f "${SKK_DICT}" ]; then
    info "SKK dictionary already exists at ${SKK_DICT}. Skipping."
    return
  fi

  info "Downloading SKK-JISYO.L..."
  mkdir -p "$(dirname "${SKK_DICT}")"
  if curl -fsSL https://skk-dev.github.io/dict/SKK-JISYO.L.gz | gunzip > "${SKK_DICT}"; then
    info "SKK dictionary installed: ${SKK_DICT}"
  else
    rm -f "${SKK_DICT}"
    warn "Failed to download SKK-JISYO.L. Skipping."
  fi
}

install () {
  install_skk_dict

  case "$(uname -s)" in
    Darwin*)
      echo "Your platform: MacOS"
      "${SCRIPT_DIR}"/homebrew_install.sh
      ;;
    Linux*)
      echo "Your platform: Linux"
      "${SCRIPT_DIR}"/arch_install.sh
      ;;
    *)
      echo "Your platform ($(uname -a)) is not supported. Skipping..."
      ;;
  esac
}
		
update () {
  info "Start dotfiles update."
  cd "${DOT_DIRECTORY}" || exit
  git pull origin main
  if [ -d "${CLAUDE_DIR}/.git" ]; then
    info "Updating Claude config..."
    git -C "${CLAUDE_DIR}" pull
  fi
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
