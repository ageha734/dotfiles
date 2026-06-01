# lsd — modern ls replacement with icons
if not status is-interactive; or not type -q lsd
    exit
end

alias ls lsd
alias l 'lsd -l'
alias ll 'lsd -l'
alias la 'lsd -a'
alias lla 'lsd -la'
alias lt 'lsd --tree'
alias tree 'lsd --tree'

# Tell autols plugin to use lsd
set -U autols_cmd lsd
