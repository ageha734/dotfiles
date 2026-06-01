# Auto-dump Brewfile after install/uninstall
if not status is-interactive
    exit
end

function __brew_postexec --on-event fish_postexec
    switch "$argv"
        case "brew install*" "brew uninstall*" "brew remove*" "brew tap*" "brew untap*" "brew cask*"
            brew bundle dump --global --force 2>/dev/null &
    end
end
