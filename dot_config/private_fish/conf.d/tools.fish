# General CLI tools setup (interactive only)
if not status is-interactive
    exit
end

# bat as cat
if type -q bat
    alias cat bat
end

# neovim
if type -q nvim
    alias v nvim
    alias vi nvim
    alias vim nvim
end

# rip (safe rm → Trash)
if type -q rip
    set -gx GRAVEYARD $HOME/.Trash
    alias rm rip
end

# thefuck
if type -q thefuck
    thefuck --alias | source
end

# fzf — catppuccin-frappe colors
if type -q fzf
    set -gx FZF_DEFAULT_OPTS "\
--color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
--color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
--color=marker:#babbf1,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284 \
--color=selected-bg:#51576d \
--border rounded \
--prompt '∷ ' \
--pointer '' \
--marker ''"
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
    set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
end

# ghq + fzf: repo jump
if type -q ghq; and type -q fzf
    function repo --description "Jump to a ghq-managed repository"
        set -l root (ghq root)
        set -l selected (ghq list | fzf \
            --prompt "  repo > " \
            --preview "lsd --tree --depth 2 $root/{} 2>/dev/null || ls $root/{}")
        if test -n "$selected"
            cd $root/$selected
        end
    end
end

# sshs — SSH host picker with fzf
if type -q sshs
    alias s sshs
end

# jq / yq: pretty print
if type -q jq
    alias jqp 'jq -C . | less -R'
end

# delta: pager
if type -q delta
    set -gx DELTA_PAGER 'less -R'
end

# navi: interactive cheatsheet (ctrl+g)
if type -q navi
    navi widget fish | source
end

# yazi: file manager alias
if type -q yazi
    # y function is in functions/y.fish
    set -gx YAZI_CONFIG_HOME $HOME/.config/yazi
end

# fastfetch: system info
if type -q fastfetch
    alias ff fastfetch
end
