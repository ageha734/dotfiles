#!/bin/bash

if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew install fish

if [ -n "${CI:-}" ]; then
    exit 0
fi

if [ "$(uname -m)" = "arm64" ]; then
    grep -qxF '/opt/homebrew/bin/fish' /etc/shells || sudo sh -c 'echo /opt/homebrew/bin/fish >> /etc/shells'
    chsh -s /opt/homebrew/bin/fish
fi

if [ "$(uname -m)" = "x86_64" ]; then
    grep -qxF '/usr/local/bin/fish' /etc/shells || sudo sh -c 'echo /usr/local/bin/fish >> /etc/shells'
    chsh -s /usr/local/bin/fish
fi
