#!/bin/bash
set -euo pipefail

DOT_DIRECTORY="${HOME}/dotfiles"
BREWFILE="${DOT_DIRECTORY}/Brewfile"

if ! command -v brew >/dev/null 2>&1; then
    echo "installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Make brew available in this shell right after a fresh install
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

echo "run brew update..."
brew update

if [ ! -f "${BREWFILE}" ]; then
    echo "Brewfile not found: ${BREWFILE}" >&2
    exit 1
fi

echo "run brew bundle..."
brew bundle install --file="${BREWFILE}"

echo "run brew upgrade..."
brew upgrade

brew cleanup

cat << END
**************************************************
HOMEBREW INSTALLED! bye.
**************************************************
END
