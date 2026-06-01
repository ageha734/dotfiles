# Terminal-first workflow helpers (interactive only)
if not status is-interactive
    exit
end

# ── Project session: tmux session per project ─────────────────
function proj --description "Open/switch to a tmux session for a ghq project"
    if not type -q ghq; or not type -q fzf
        echo "requires: ghq, fzf"
        return 1
    end

    set -l root (ghq root)
    set -l selected (ghq list | fzf --prompt " project > " --preview "lsd --tree --depth 2 $root/{} 2>/dev/null")
    test -z "$selected"; and return 0

    set -l session_name (basename $selected | string replace -a '.' '_')
    set -l project_path "$root/$selected"

    if set -q TMUX
        if not tmux has-session -t "$session_name" 2>/dev/null
            tmux new-session -d -s "$session_name" -c "$project_path"
            tmux send-keys -t "$session_name" nvim Enter
        end
        tmux switch-client -t "$session_name"
    else
        if not tmux has-session -t "$session_name" 2>/dev/null
            tmux new-session -s "$session_name" -c "$project_path"
        else
            tmux attach-session -t "$session_name"
        end
    end
end

# ── Quick edit: open file in nvim with preview ────────────────
function e --description "Fuzzy find and edit file in nvim"
    set -l file (fd --type f --hidden --exclude .git | fzf \
        --prompt " edit > " \
        --preview "bat --color=always --style=numbers --line-range=:300 {}" \
        --preview-window "right:60%")
    test -n "$file"; and nvim "$file"
end

# ── Live grep: ripgrep + fzf → nvim ──────────────────────────
function rg-edit --description "Live grep and open result in nvim"
    set -l result (rg --color=always --line-number --no-heading --smart-case . | \
        fzf --ansi --prompt " grep > " \
            --delimiter ':' \
            --preview 'bat --color=always --highlight-line {2} {1}' \
            --preview-window 'right:60%:+{2}-10')
    test -z "$result"; and return 0

    set -l file (echo $result | cut -d: -f1)
    set -l line (echo $result | cut -d: -f2)
    nvim "+$line" "$file"
end

# ── Git worktree workflow ─────────────────────────────────────
function gwt --description "Create worktree + tmux session for a branch"
    if test (count $argv) -lt 1
        echo "usage: gwt <branch-name> [base-branch]"
        return 1
    end

    set -l branch $argv[1]
    set -l base (test (count $argv) -ge 2; and echo $argv[2]; or echo "main")
    set -l repo_name (basename (git rev-parse --show-toplevel 2>/dev/null))
    set -l wt_path "../$repo_name-$branch"

    git worktree add -b "$branch" "$wt_path" "$base" 2>/dev/null
    or git worktree add "$wt_path" "$branch" 2>/dev/null
    or begin
        echo "worktree creation failed"
        return 1
    end

    set -l session_name "$repo_name-$branch"
    set -l abs_path (realpath "$wt_path")

    if set -q TMUX
        tmux new-session -d -s "$session_name" -c "$abs_path"
        tmux send-keys -t "$session_name" nvim Enter
        tmux switch-client -t "$session_name"
    else
        tmux new-session -s "$session_name" -c "$abs_path"
    end
end

# ── PR review in terminal ─────────────────────────────────────
function pr-review --description "Checkout and review a PR in terminal"
    set -l pr_number (gh pr list --state open --json number,title,author \
        --template '{{range .}}{{.number}} {{.title}} ({{.author.login}}){{"\n"}}{{end}}' | \
        fzf --prompt " PR > " | awk '{print $1}')
    test -z "$pr_number"; and return 0

    gh pr checkout $pr_number
    echo ---
    gh pr view $pr_number
    echo ---
    echo "Files changed:"
    gh pr diff $pr_number --stat
end

# ── Ports: show what's listening ──────────────────────────────
function ports --description "Show listening ports"
    lsof -iTCP -sTCP:LISTEN -P -n 2>/dev/null | awk 'NR==1 || /LISTEN/' | column -t
end

# ── Weather (compact) ─────────────────────────────────────────
function wttr --description "Quick weather"
    curl -s "wttr.in/?format=3" 2>/dev/null
end
