# AI Tools — Claude Code / Gemini CLI / GitHub Copilot
if not status is-interactive
    exit
end

# ── Claude Code ──────────────────────────────────────
function cc-wt --description "Create git worktree + open Claude Code"
    if test (count $argv) -lt 1
        echo "Usage: cc-wt <branch-name> [base-branch]"
        return 1
    end
    set -l branch $argv[1]
    set -l base (test (count $argv) -ge 2 && echo $argv[2] || echo "main")
    git-wt new $branch $base
    and claude
end

function ai-status --description "Show current AI model & auth status"
    echo "── AI Status ──────────────────────────"
    echo "ANTHROPIC_MODEL : "(set -q ANTHROPIC_MODEL && echo $ANTHROPIC_MODEL || echo "(default)")
    echo "GEMINI_MODEL    : "(set -q GEMINI_MODEL && echo $GEMINI_MODEL || echo "(default)")
    echo "SSH_AUTH_SOCK   : "(test -S $SSH_AUTH_SOCK && echo "OK ✓" || echo "MISSING ✗")
    echo "1Password agent : "(pgrep -q "1Password" && echo "running ✓" || echo "not running ✗")
    echo "────────────────────────────────────────"
end

# ── Gemini CLI ───────────────────────────────────────
if type -q gemini
    set -gx GEMINI_MODEL 'gemini-2.5-pro'

    function gem-flash --description "Switch to Gemini 2.5 Flash"
        set -gx GEMINI_MODEL 'gemini-2.5-flash'
        echo "Model: Gemini 2.5 Flash"
    end

    function gem-pro --description "Switch to Gemini 2.5 Pro"
        set -gx GEMINI_MODEL 'gemini-2.5-pro'
        echo "Model: Gemini 2.5 Pro"
    end
end

# ── GitHub Copilot CLI ───────────────────────────────
if type -q gh
    if gh extension list 2>/dev/null | grep -q copilot
        alias ghcop 'gh copilot suggest'
        alias ghexp 'gh copilot explain'
    end
end

# ── Session identification (cmux) ────────────────────
if set -q CMUX_WORKSPACE_ID
    set -gx AI_SESSION_ID (string sub -l 8 $CMUX_WORKSPACE_ID)
    set -gx AI_WORKTREE_ROOT $HOME/Repository
end
