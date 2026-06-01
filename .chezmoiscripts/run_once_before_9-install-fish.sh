#!/bin/bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install fish

if [ "$(uname -m)" = "arm64" ]; then
    sudo sh -c 'echo /opt/homebrew/bin/fish >> /etc/shells'
    echo "chsh -s /opt/homebrew/bin/fish"
    chsh -s /opt/homebrew/bin/fish
fi

if [ "$(uname -m)" = "x86_64" ]; then
    sudo sh -c 'echo /usr/local/bin/fish >> /etc/shells'
    echo "chsh -s /usr/local/bin/fish"
    chsh -s /usr/local/bin/fish
fi
