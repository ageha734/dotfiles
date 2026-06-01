function git-wt --description "git worktree manager (Claude Code / AI agent ready)"
    set -l subcmd $argv[1]
    set -l rest $argv[2..-1]

    switch $subcmd
        case new n
            __git_wt_new $rest
        case list ls l
            __git_wt_list
        case cd switch sw
            __git_wt_cd $rest
        case rm remove delete del
            __git_wt_remove $rest
        case clean
            __git_wt_clean
        case pr
            __git_wt_pr $rest
        case '*' ""
            __git_wt_interactive
    end
end

# ── subcommands ──────────────────────────────────────

function __git_wt_new -d "Create a new worktree"
    set -l branch $argv[1]
    set -l base (count $argv -ge 2 && echo $argv[2] || git symbolic-ref --short HEAD 2>/dev/null || echo "main")

    if test -z "$branch"
        echo "Usage: git-wt new <branch> [base-branch]"
        return 1
    end

    set -l repo_root (git rev-parse --show-toplevel 2>/dev/null)
    if test $status -ne 0
        echo "Error: not in a git repository"
        return 1
    end

    set -l repo_name (path basename $repo_root)
    set -l safe_branch (string replace --all / -- $branch)
    set -l wt_path (path dirname $repo_root)/$repo_name--$safe_branch

    if git show-ref --verify --quiet refs/heads/$branch
        git worktree add $wt_path $branch
    else
        git worktree add -b $branch $wt_path $base
    end

    if test $status -eq 0
        echo "Worktree: $wt_path"

        # Install git-secrets hooks in new worktree
        if type -q git-secrets
            git -C $wt_path secrets --install -f 2>/dev/null
            git -C $wt_path secrets --register-aws 2>/dev/null
        end

        # Copy .envrc if present
        if test -f $repo_root/.envrc; and type -q direnv
            cp $repo_root/.envrc $wt_path/.envrc
            echo "Copied .envrc"
        end

        cd $wt_path
    end
end

function __git_wt_list -d "List worktrees with fzf preview"
    set -l in_repo (git rev-parse --show-toplevel 2>/dev/null)
    if test $status -ne 0
        echo "Error: not in a git repository"
        return 1
    end

    if type -q fzf
        git worktree list | fzf \
            --prompt "  worktree > " \
            --preview "lsd --tree --depth 2 {1} 2>/dev/null || ls {1}"
    else
        git worktree list
    end
end

function __git_wt_cd -d "cd into a worktree"
    if test (count $argv) -ge 1
        set -l branch $argv[1]
        set -l repo_root (git rev-parse --show-toplevel 2>/dev/null)
        set -l repo_name (path basename $repo_root)
        set -l safe_branch (string replace --all / -- $branch)
        set -l wt_path (path dirname $repo_root)/$repo_name--$safe_branch

        if test -d $wt_path
            cd $wt_path
        else
            echo "Worktree not found: $wt_path"
            return 1
        end
    else if type -q fzf
        set -l selected (git worktree list | fzf --prompt "  worktree > " | awk '{print $1}')
        if test -n "$selected"
            cd $selected
        end
    else
        git worktree list
    end
end

function __git_wt_remove -d "Remove a worktree"
    set -l branch $argv[1]

    if test -z "$branch"; and type -q fzf
        set branch (git worktree list | tail -n +2 | fzf --prompt " remove > " | awk '{print $1}' | path basename)
    end

    if test -z "$branch"
        echo "Usage: git-wt rm <branch>"
        return 1
    end

    set -l repo_root (git rev-parse --show-toplevel 2>/dev/null)
    set -l repo_name (path basename $repo_root)
    set -l safe_branch (string replace --all / -- $branch)
    set -l wt_path (path dirname $repo_root)/$repo_name--$safe_branch

    if not test -d $wt_path
        set wt_path $branch
    end

    if type -q gum
        gum confirm "Remove worktree: $wt_path ?" || return 0
    else
        read -P "Remove worktree: $wt_path ? [y/N] " -l confirm
        test "$confirm" = y || return 0
    end

    git worktree remove --force $wt_path
    and echo "Removed: $wt_path"
end

function __git_wt_clean -d "Remove merged worktrees"
    set -l main_branch (git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | string replace 'origin/' '')
    or set main_branch main

    for wt in (git worktree list | tail -n +2 | awk '{print $1}')
        set -l wt_branch (git -C $wt rev-parse --abbrev-ref HEAD 2>/dev/null)
        if git merge-base --is-ancestor $wt_branch $main_branch 2>/dev/null
            echo "Merged: $wt ($wt_branch)"
            if type -q gum
                gum confirm "Remove?" && git worktree remove --force $wt
            else
                read -P "Remove? [y/N] " -l c
                test "$c" = y && git worktree remove --force $wt
            end
        end
    end
end

function __git_wt_pr -d "Push current worktree branch and create PR"
    if not type -q gh
        echo "Error: gh cli required"
        return 1
    end
    set -l branch (git rev-parse --abbrev-ref HEAD 2>/dev/null)
    git push -u origin $branch
    and gh pr create --fill
end

function __git_wt_interactive -d "Interactive mode (gum)"
    if not type -q gum
        echo "Usage: git-wt <new|list|cd|rm|clean|pr>"
        return 0
    end
    set -l action (gum choose "new" "list" "cd" "rm" "clean" "pr" --header "git worktree action")
    switch $action
        case new
            set -l branch (gum input --placeholder "branch name")
            __git_wt_new $branch
        case list
            __git_wt_list
        case cd
            __git_wt_cd
        case rm
            __git_wt_remove
        case clean
            __git_wt_clean
        case pr
            __git_wt_pr
    end
end
