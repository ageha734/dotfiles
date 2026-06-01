# vim: ft=fish ts=4 sw=4 et
# ======================================================
# Fish Shell Configuration — Optimized for speed & security
# ======================================================

# =====================================================
# SECTION 1: Greeting & universal vars
# =====================================================
set fish_greeting ""

# =====================================================
# SECTION 2: XDG Base Directories
# =====================================================
set -q XDG_CONFIG_HOME || set -gx XDG_CONFIG_HOME $HOME/.config
set -q XDG_DATA_HOME || set -gx XDG_DATA_HOME $HOME/.local/share
set -q XDG_CACHE_HOME || set -gx XDG_CACHE_HOME $HOME/.cache

set -g FISH_CONFIG_DIR $XDG_CONFIG_HOME/fish
set -g FISH_CACHE_DIR $XDG_CACHE_HOME/fish

# =====================================================
# SECTION 3: Locale
# =====================================================
set -gx LC_ALL "en_US.UTF-8"
set -gx BASH_SILENCE_DEPRECATION_WARNING 1

# =====================================================
# SECTION 4: PATH (static only — no subshells)
# =====================================================
set -gx HOMEBREW_PREFIX /opt/homebrew
set -gx HOMEBREW_BUNDLE_FILE $HOME/.Brewfile
set -gx HOMEBREW_NO_AUTO_UPDATE 1
fish_add_path --global $HOMEBREW_PREFIX/bin $HOMEBREW_PREFIX/sbin
fish_add_path --global /usr/local/bin
fish_add_path --global $HOME/.local/bin
fish_add_path --global $HOME/.authz/bin

# Rust/Cargo
set -gx RUSTUP_HOME $HOME/.rustup
set -gx CARGO_HOME $HOME/.cargo
fish_add_path --global $CARGO_HOME/bin

# Go
set -gx GOPATH $HOME/.go
fish_add_path --global $GOPATH/bin

# Node.js
set -gx NPM_CONFIG_PREFIX $HOME/.node_modules
fish_add_path --global $NPM_CONFIG_PREFIX/bin

# Python (static path, version detection deferred)
set -gx PYTHONUSERBASE $HOME/.python
fish_add_path --global $PYTHONUSERBASE/bin

# Proto (shims path first, activate deferred to interactive)
fish_add_path --global $HOME/.proto/shims
fish_add_path --global $HOME/.proto/bin

# Platform tools
fish_add_path --global $HOME/.ticloud/bin
fish_add_path --global $HOME/.tiup/bin
fish_add_path --global $HOMEBREW_PREFIX/opt/mysql-client/bin
fish_add_path --global $HOMEBREW_PREFIX/opt/sqlite/bin
fish_add_path --global $HOME/.nix-profile/bin

# libxml2 build flags
set -gx LDFLAGS "-L$HOMEBREW_PREFIX/opt/libxml2/lib"
set -gx CPPFLAGS "-I$HOMEBREW_PREFIX/opt/libxml2/include"
set -gx PKG_CONFIG_PATH "$HOMEBREW_PREFIX/opt/libxml2/lib/pkgconfig"

# =====================================================
# SECTION 5: Security — SSH Agent (1Password)
# =====================================================
set -gx SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# =====================================================
# SECTION 6: Editor
# =====================================================
type -q nvim; and begin
    set -gx EDITOR nvim
    set -gx GIT_EDITOR nvim
    set -gx VISUAL nvim
    set -gx MANPAGER "nvim -c ASMANPAGER -"
end

# =====================================================
# SECTION 7: Tool global configs
# =====================================================
# Bat
set -gx BAT_THEME "Catppuccin Frappe"
set -gx BAT_TABS 4
set -gx BAT_STYLE plain
set -gx BAT_PAGER "less -R"

# Less
set -gx LESSKEY $HOME/.config/less/less

# Misc
set -gx TMPDIR $HOME/.tmp

# Atuin (env only — init deferred to conf.d/atuin.fish)
set -gx ATUIN_NOBIND true

# Done plugin threshold
set -U __done_min_cmd_duration 5000

# SECTION 8: AI tools → functions/ ディレクトリで定義

# =====================================================
# SECTION 9: Cached initializations (expensive tools)
# =====================================================
set -l CACHED_INIT $FISH_CACHE_DIR/init.fish

if not test -f $CACHED_INIT; or test $FISH_CONFIG_DIR/config.fish -nt $CACHED_INIT
    mkdir -p $FISH_CACHE_DIR
    set -l tmp (mktemp)

    echo "# Auto-generated: "(date) >$tmp

    # direnv
    if type -q direnv
        echo 'direnv hook fish | source' >>$tmp
    end

    # starship
    if type -q starship
        echo 'starship init fish | source' >>$tmp
    end

    # gh copilot alias
    if test -f ~/.local/share/gh/extensions/gh-fish/gh-copilot-alias.fish
        echo 'source ~/.local/share/gh/extensions/gh-fish/gh-copilot-alias.fish' >>$tmp
    end

    # gcloud
    if test -f /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc
        echo 'source /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc' >>$tmp
    end

    mv $tmp $CACHED_INIT
    set_color green --bold
    echo "Fish: cache updated"
    set_color normal
end

# =====================================================
# SECTION 10: Interactive-only setup
# =====================================================
if not status is-interactive
    exit
end

# stty: disable flow control
stty stop undef 2>/dev/null
stty start undef 2>/dev/null

# proto activate (interactive only)
if type -q proto
    proto activate fish | source
end

# tmux auto-start (Ghostty のみ、未接続時)
if test "$TERM" = xterm-ghostty; and not set -q TMUX; and not set -q NVIM; and not set -q VSCODE_PID
    exec tmux new-session
end

# Source cached init (starship, direnv, gcloud, etc.)
if test -f $CACHED_INIT
    source $CACHED_INIT
end

# Transience (requires starship with transience enabled)
enable_transience

# at2-token: AT2_TOKEN を 1Password から取得して直接 export
function at2-token
    set -gx AT2_TOKEN (at2 token --raw)
    and echo '✓ AT2_TOKEN をセットしました'
end
