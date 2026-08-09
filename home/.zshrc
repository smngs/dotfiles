#            _
#    _______| |__  _ __ ___
#   |_  / __| '_ \| '__/ __|
#  _ / /\__ \ | | | | | (__
# (_)___|___/_| |_|_|_|\___|

# ----------------- locale --------------------

# LANG only. LC_ALL would force every LC_* category, including collation.
export LANG=ja_JP.UTF-8

# TERM is left to the terminal emulator; overriding it here breaks
# truecolor / undercurl detection inside zellij and nvim.

# ----------------- PATH --------------------

# Only what is needed to find sheldon; the full PATH is built in .zshrc.lazy
[[ -d /opt/homebrew/bin ]] && export PATH="/opt/homebrew/bin:$PATH"

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

# ----------------- completion --------------------

# fpath must be complete before compinit, which runs in .zshrc.lazy
fpath+=~/.zfunc
zstyle ':completion:*' menu select

# ----------------- plugins --------------------

# zeno reads these while sheldon sources it below
export ZENO_HOME="$HOME/.config/zeno"
export ZENO_ENABLE_SOCK=1
export ZENO_DISABLE_EXECUTE_CACHE_COMMAND=1
export ZENO_DISABLE_BUILTIN_COMPLETION=1
export ZENO_GIT_CAT="bat --color=always"
export ZENO_GIT_TREE="eza --tree"

# Check for the config too: sheldon aborts when ~/.config/sheldon is missing,
# which happens on a machine that has the binary but has not run `make deploy`.
if (( ${+commands[sheldon]} )) && [[ -f ${XDG_CONFIG_HOME:-$HOME/.config}/sheldon/plugins.toml ]]; then
    eval "$(sheldon source)"
elif (( ${+commands[sheldon]} )); then
    print -P "%F{160}sheldon has no config; run 'make deploy'.%f"
else
    print -P "%F{160}sheldon is not installed. Run 'make install' or 'brew install sheldon'.%f"
fi

## -> .zshrc.lazy (lazy-loading)

# Queued after the plugins above, so zeno's widgets exist by the time it runs
if (( ${+functions[zsh-defer]} )); then
    zsh-defer source $HOME/.zshrc.lazy
else
    source $HOME/.zshrc.lazy
fi
