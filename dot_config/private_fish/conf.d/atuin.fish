# Atuin — shell history (interactive only, initialized once)
if not status is-interactive; or not type -q atuin
    exit
end

atuin init fish --disable-up-arrow | source

# Ctrl+H for history search
bind \ch _atuin_search
bind -M insert \ch _atuin_search
