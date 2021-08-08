#            _
#    _______| |__  _ __ ___
#   |_  / __| '_ \| '__/ __|
#  _ / /\__ \ | | | | | (__
# (_)___|___/_| |_|_|  \___|

# zplug の設定読み込み．
source ~/.zplugrc

# 補完を有効化．
autoload -Uz compinit && compinit
setopt auto_list
setopt auto_menu
setopt auto_cd
setopt correct

export LANG=ja_JP.UTF-8
# 256 色表示できるように．
export TERM=screen-256color

# anyframe の設定．
zstyle ":anyframe:selector:" use fzf-tmux
zstyle ":anyframe:selector:fzf-tmux:" command 'fzf-tmux -p'
export FZF_TMUX=1
export FZF_TMUX_OPTS='-p'

# enhancd の設定．
export ENHANCD_FILTER="fzf-tmux -p"
export ENHANCD_DISABLE_DOT=1

zstyle ':completion:*:default' menu select=1
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
# export PATH="/usr/local/bin:\
#   /usr/local/sbin:\
#   $HOME/.gem/ruby/2.7.0/bin:\
#   $PATH"

if type hyper > /dev/null 2>&1; then
    export TERMINAL='hyper'
fi
if type nvim > /dev/null 2>&1; then
  export EDITOR='nvim'
fi

HISTFILE=$HOME/.zsh-history
HISTSIZE=1000000
SAVEHIST=1000000
setopt share_history

# ----------------- alias --------------------

if [[ $(command -v exa) ]]; then
  alias l='exa --icons'
  alias ls='exa --icons'
  alias la='exa --icons -a'
  alias ll='ls --icons -lh'
  alias lla='ls --icons -lah'
fi

if [[ $(command -v bat) ]]; then
  alias cat='bat'
fi

if [[ $(command -v hexyl) ]]; then
  alias od='hexyl'
fi

if [[ $(command -v procs) ]]; then
  alias ps='procs'
fi

alias tree='tree -C'
alias rm='rm -i'
alias mv='mv -i'
alias df='df -h'
alias q='exit'
alias c='clear'

alias ..='cd ..'
alias ..2='cd ../..'
alias ..3='cd ../../..'
alias ..4='cd ../../../..'
alias ..5='cd ../../../../..'

# tmux
alias t='tmuximum'

# git
alias g='anyframe-source-ghq-repository \
  | anyframe-selector-fzf-tmux \
  | cd'
alias gs='git status --short --branch'
alias gd='git diff'
alias ga='git add -A'
alias gpl='git pull'
alias gc='git commit'
alias gch='git checkout'
alias gps='git push'
alias gb='git branch'
alias gf='git fetch'

# vim
alias n='nvim'
alias v='nvim'

# ranger
alias r='ranger'

# --------------------------------------------

# ----------------- function -----------------
# tmuximum
if [ -z $TMUX ]; then
  tmuximum
fi

# do_enter (pwd, ls, git status)
function do_enter() {
    if [ -n "$BUFFER" ]; then
        zle accept-line
        return 0
    fi
    echo
    echo -e "\e[0;33m--- pwd ---\e[0m"
    pwd
    echo
    echo -e "\e[0;33m--- ls ---\e[0m"
#    if type colorls > /dev/null 2>&1; then
#        colorls
#    else
        ls
#    fi
    if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = 'true' ]; then
        echo
        echo -e "\e[0;33m--- git status ---\e[0m"
        git status -sb
    fi
    echo
    echo
    zle reset-prompt
    return 0
}

zle -N do_enter
bindkey '^m' do_enter
# --------------------------------------------
