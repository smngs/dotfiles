# zplug
source ~/.zplug/init.zsh
autoload -Uz compinit && compinit

setopt auto_list
setopt auto_menu
setopt auto_cd
setopt correct
eval `tset -s xterm-24bits`

zstyle ':completion:*:default' menu select=1
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
export TERMINAL='hyper'
export EDITOR='emacsclient -nw' 

HISTFILE=$HOME/.zsh-history
HISTSIZE=1000000
SAVEHIST=1000000

if [[ ! -d ~/.zplug ]];then
  git clone https://github.com/zplug/zplug ~/.zplug
fi

source ~/.zplug/init.zsh

zplug

zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "chrissicool/zsh-256color"
zplug "docker/cli", use:"contrib/completion/zsh/_docker"

zplug mafredri/zsh-async, from:github
zplug sindresorhus/pure, use:pure.zsh, from:github, as:theme

if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi
zplug load

# alias
# terminal
alias ls='colorls --color=auto'
alias la='colorls -a'
alias ll='colorls -la'
alias tree='tree -C'
alias rm='rm -i'
alias mv='mv -i'
alias df='df -h'
alias ..='cd ..'
alias q='exit'
alias c='clear'

# tmux
alias t='tmux'
alias tl='tmux list-sessions'
alias ta='tmux attach -t'

# git
alias gs='git status --short --branch'
alias gd='git diff'
alias ga='git add -A'
alias gpl='git pull'
alias gc='git commit'
alias gch='git checkout'
alias gps='git push'

# emacs
alias e='emacsclient -nw -a ""'
alias emacs='emacsclient -nw -a ""'
alias ekill="emacsclient -e '(kill-emacs)'"

function is_exists() { type "$1" >/dev/null 2>&1; return $?; }
function is_osx() { [[ $OSTYPE == darwin* ]]; }
function is_screen_running() { [ ! -z "$STY" ]; }
function is_tmux_runnning() { [ ! -z "$TMUX" ]; }
function is_screen_or_tmux_running() { is_screen_running || is_tmux_runnning; }
function shell_has_started_interactively() { [ ! -z "$PS1" ]; }
function is_ssh_running() { [ ! -z "$SSH_CONECTION" ]; }

function tmux_automatically_attach_session()
{
    if is_screen_or_tmux_running; then
        ! is_exists 'tmux' && return 1

        if is_tmux_runnning; then
            :
        elif is_screen_running; then
            echo "This is on screen."
        fi
    else
        if shell_has_started_interactively && ! is_ssh_running; then
            if ! is_exists 'tmux'; then
                echo 'Error: tmux command not found' 2>&1
                return 1
            fi

            if tmux has-session >/dev/null 2>&1 && tmux list-sessions | grep -qE '.*]$'; then
                # detached session exists
                tmux list-sessions
                echo -n "Tmux: attach? (y/N/num) "
                read
                if [[ "$REPLY" =~ ^[Yy]$ ]] || [[ "$REPLY" == '' ]]; then
                    tmux attach-session
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                elif [[ "$REPLY" =~ ^[0-9]+$ ]]; then
                    tmux attach -t "$REPLY"
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                fi
            fi

            if is_osx && is_exists 'reattach-to-user-namespace'; then
                # on OS X force tmux's default command
                # to spawn a shell in the user's namespace
                tmux_config=$(cat $HOME/.tmux.conf <(echo 'set-option -g default-command "reattach-to-user-namespace -l $SHELL"'))
                tmux -f <(echo "$tmux_config") new-session && echo "$(tmux -V) created new session supported OS X"
            else
                tmux new-session && echo "tmux created new session"
            fi
        fi
    fi
}
tmux_automatically_attach_session

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
    colorls
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

