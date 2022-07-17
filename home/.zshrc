#            _
#    _______| |__  _ __ ___
#   |_  / __| '_ \| '__/ __|
#  _ / /\__ \ | | | | | (__
# (_)___|___/_| |_|_|  \___|

source ~/.zplugrc

# ----------------- setopt --------------------

autoload -Uz compinit && compinit
setopt auto_list
setopt auto_menu
setopt auto_cd
setopt correct
setopt share_history

HISTFILE=$HOME/.zsh-history
HISTSIZE=1000000

zstyle ':completion:*:default' menu select=1

# ----------------- path && env --------------------

export LANG=ja_JP.UTF-8
export TERM=screen-256color
export EDITOR=nvim

if type nvim > /dev/null 2>&1; then
  export EDITOR='nvim'
fi

case ${OSTYPE} in
    darwin*)
        export PATH=$PATH:/opt/homebrew:/usr/local/Homebrew/bin
        ;;
    linux*)
        ;;
esac

# ----------------- alias --------------------

if [[ $(command -v exa) ]]; then
  alias l='exa --icons'
  alias ls='exa --icons'
  alias la='exa --icons -a'
  alias ll='exa --icons -lh'
  alias lla='exa --icons -lah'
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

alias ..='\cd ..'
alias ..2='\cd ../..'
alias ..3='\cd ../../..'
alias ..4='\cd ../../../..'
alias ..5='\cd ../../../../..'

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

# fzf-tmux

export FZF_TMUX=1
export FZF_TMUX_OPTS="-p 80%"

export ENHANCD_FILTER='fzf-tmux -p'
# --------------------------------------------

# ----------------- function -----------------
if [ -z "$TMUX" ]; then
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

# Load rbenv automatically by appending
# the following to ~/.zshrc:


eval "$(rbenv init -)"
