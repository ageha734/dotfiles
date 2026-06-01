# TUI tool aliases (interactive only)
if not status is-interactive
    exit
end

# htop
if type -q htop
    alias top htop
end

# gh dash (GitHub dashboard TUI)
if type -q gh
    alias ghd "gh dash"
end
