#!/bin/bash

echo "installing homebrew..."
which brew >/dev/null 2>&1 || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "run brew doctor..."
which brew >/dev/null 2>&1 && brew doctor

echo "run brew update..."
which brew >/dev/null 2>&1 && brew update

echo "run brew upgrade..."
brew upgrade

formulas=(
    git
    wget
    curl
    tree
    openssl
    peco
    gh
    tig
    node
    python3
    neovim
    mysql
    postgresql
    sqlite
    ctags
    ssh-copy-id
    mecab
    diff-so-fancy
)

echo "start brew install formulas..."
for formula in "${formulas[@]}"; do
    brew install "$formula" || brew upgrade "$formula"
done

casks=(
    google-chrome
    google-japanese-ime
    slack
    visual-studio-code
    iterm2
    zoom
)

echo "start brew install casks..."
for cask in "${casks[@]}"; do
    brew install --cask "$cask"
done

brew cleanup

cat << END
**************************************************
HOMEBREW INSTALLED! bye.
**************************************************
END
