# Show fastfetch on first tmux pane only (avoid spam on splits/new tabs)
if status is-interactive
    and not set -q FASTFETCH_SHOWN
    and not set -q GHOSTTY_QUICK_TERMINAL
    and type -q fastfetch
    set -gx FASTFETCH_SHOWN 1
    fastfetch
end
