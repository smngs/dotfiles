#            _
#    _______| |__  _ __ ___
#   |_  / __| '_ \| '__/ __|
#  _ / /\__ \ | | | | | (__
# (_)___|___/_| |_|_|  \___|

# ----------------- PATH --------------------

# TBD
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8
export TERM=xterm-256color
# EDITOR は .zshrc.lazy で設定

# ----------------- setup zinit --------------------

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

# ----------------- setopt --------------------

setopt auto_list
setopt auto_menu
setopt auto_cd
setopt correct
setopt share_history

# ----------------- history --------------------

HISTFILE=$HOME/.zsh-history
HISTSIZE=1000000
SAVEHIST=1000000

# ----------------- theme --------------------

zinit light-mode for \
    zsh-users/zsh-autosuggestions \
    sindresorhus/pure \
    romkatv/zsh-defer

## -> .zshrc-lazy (lazy-loading)

zsh-defer source $HOME/.zshrc.lazy

fpath+=~/.zfunc; autoload -Uz compinit; compinit

zstyle ':completion:*' menu select

# ----------------- aliases --------------------

alias diff='delta'

# Claude Code
export CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=75
