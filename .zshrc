# zplug
source ~/.zplug/init.zsh
autoload -Uz compinit && compinit

setopt auto_list
setopt auto_menu
setopt auto_cd
setopt correct

export TERM=screen-256color

zstyle ':completion:*:default' menu select=1
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
if type hyper > /dev/null 2>&1; then
    export TERMINAL='hyper'
fi
export EDITOR='nvim'

HISTFILE=$HOME/.zsh-history
HISTSIZE=1000000
SAVEHIST=1000000

# Install zplug
if [[ ! -d ~/.zplug ]];then
  git clone https://github.com/zplug/zplug ~/.zplug
fi

source ~/.zplug/init.zsh

zplug
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"

zplug "arks22/tmuximum", as:command
zplug "supercrabtree/k"
zplug "chrissicool/zsh-256color"
zplug "docker/cli", use:"contrib/completion/zsh/_docker"

zplug "mafredri/zsh-async", from:github
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme

if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi
zplug load

# alias
# terminal
#if type colorls > /dev/null 2>&1; then
#    alias ls='colorls --color=auto'
#    alias la='colorls -a'
#    alias ll='colorls -la'
#fi

alias ls='ls --color=auto'
alias la='ls --color=auto -a'
alias ll='ls --color=auto -lh'
alias lla='ls --color=auto -lah'

alias tree='tree -C'
alias rm='rm -i'
alias mv='mv -i'
alias df='df -h'
alias q='exit'
alias c='clear'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# tmux
alias t='tmuximum'

# git
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

alias r='ranger'

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
