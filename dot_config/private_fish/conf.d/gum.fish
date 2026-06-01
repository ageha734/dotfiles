function __ghq_cd_interactive
    set -l ghq_root (command ghq root)
    if test -z "$ghq_root"
        command gum style --foreground 196 --bold "⚠️  ghqのルートディレクトリが見つかりません。"
        return 1
    end

    set -l selected_project (command ghq list | command fzf --header "ghqプロジェクトを選択:")
    if test -n "$selected_project"
        cd "$ghq_root/$selected_project"
        command gum style --foreground 154 --bold "✅  移動しました: $ghq_root/$selected_project"
    else
        command gum style --foreground 196 --bold "⚠️  プロジェクトが選択されませんでした。"
    end
end

function __git_sw
    # 1. 現在のブランチ名を取得
    #    gitリポジトリでない場合やHEADが存在しない場合にエラー出力を抑制 (2>/dev/null)
    set -l current_branch (command git rev-parse --abbrev-ref HEAD 2>/dev/null)

    # 2. 直前のコマンドのステータスを確認し、エラーまたはカレントブランチが空なら処理を中断
    if test $status -ne 0 -o -z "$current_branch"
        command gum style --foreground 196 --bold "⚠️  ここはGitリポジトリではありません、またはブランチが存在しません。"
        return 1
    end

    # 3. 除外するブランチ名のパターン (正規表現)
    #    行頭(^)と行末($)を指定することで、部分一致ではなく完全一致するブランチ名を除外
    set -l excluded_patterns '^(main|development|master)$'

    # 4. ローカルブランチの一覧を取得し、指定されたパターンにマッチしないものだけをフィルタリング
    #    `git branch --list` はローカルブランチのみを対象とします
    #    `--format='%(refname:short)'` でブランチ名のみをクリーンに取得
    #    `grep -vE "$excluded_patterns"` で除外パターンに一致する行を除外
    set -l branches (command git branch --list --format='%(refname:short)' | command grep -vE "$excluded_patterns")

    # 5. フィルタリング後に切り替え可能なブランチがない場合
    if test (count $branches) -eq 0
        command gum style --foreground 196 --bold "⚠️  切り替え可能なブランチが見つかりません (Main, Development, Developer, Master を除外後)。"
        return 1
    end

    # 6. fzf を使ってブランチを選択
    #    `printf '%s\n' $branches` で各ブランチを改行区切りにして fzf に渡す
    #    `--header` でfzfのプロンプトに現在のブランチ情報を表示
    set -l selected_branch (printf '%s\n' $branches | command fzf --header "ブランチを選択してください (現在のブランチ: $current_branch):")

    # 7. fzf で何も選択されなかった場合 (Escキーなどでキャンセル)
    if test -z "$selected_branch"
        command gum style --foreground 196 --bold "⚠️  ブランチが選択されませんでした。"
        return 1
    end

    # 8. 既に選択したブランチにいる場合
    if test "$selected_branch" = "$current_branch"
        command gum style --foreground 196 --bold "⚠️  既にブランチ '$current_branch' にいます。"
        return 1
    end

    # 9. git switch を実行してブランチを切り替え
    if command git switch "$selected_branch"
        command gum style --foreground 154 --bold "✅  ブランチ '$selected_branch' に切り替えました。"
    else
        # git switch が失敗した場合
        command gum style --foreground 196 --bold "❌  ブランチ '$selected_branch' への切り替えに失敗しました。"
        return 1
    end

    return 0
end

function __fzf_open_file
    set -l file_to_open # Corrected: Use 'set -l' for local variables
    set -l list_files_cmd_str # String to build the command for listing files

    # Define the search directory (current directory ".")
    set -l search_dir "."

    if command -q fd
        # If fd is available, use it.
        # --type f: only files
        # --hidden: include hidden files (fd does this by default, but explicit if needed)
        # --no-ignore-vcs: do not respect VCS ignore files (.gitignore, etc.)
        set list_files_cmd_str "command fd --type f --hidden --no-ignore-vcs \"$search_dir\""
    else
        command gum style --foreground 220 --bold --padding "0 1" "ℹ️ 'fd' command not found. Falling back to 'find' (recursive in current dir)."
        # If fd is not available, use find.
        # This will search recursively in the current directory for files.
        # 'find' shows hidden files by default and doesn't use VCS ignore files.
        set list_files_cmd_str "command find \"$search_dir\" -type f"
    end

    set -l fzf_preview_options # This will be a list of options for fzf
    if command -q bat
        # If bat is available, set up the preview command.
        # Note: The preview command string itself is single-quoted to be passed as one argument to --preview.
        set fzf_preview_options --preview="command bat --color=always --style=numbers --line-range=:200 {}"
    else
        command gum style --foreground 220 --bold --padding "0 1" "ℹ️ 'bat' command not found. File preview will be disabled."
    end

    # Execute the file listing command, pipe to fzf, and capture the selection.
    # Add 2>/dev/null to suppress errors from fd/find (e.g., permission denied) during listing.
    set file_to_open (eval "$list_files_cmd_str 2>/dev/null" | command fzf $fzf_preview_options --preview-window=right:60%:wrap --header="ファイルを選択:" --height=40% --reverse)

    if test -z "$file_to_open"
        command gum style --foreground 196 --bold "⚠️  ファイルが選択されませんでした。"
        return 1
    end

    # Ensure the selected path is actually a file
    if not test -f "$file_to_open"
        command gum style --foreground 196 --bold "⚠️  選択されたパス '$file_to_open' は有効なファイルではありません。"
        return 1
    end

    # Determine the appropriate command to open the file based on OS
    set -l open_executable # Stores the actual open command like 'xdg-open' or 'open'
    set -l os_type (uname)
    switch $os_type
        case Linux
            if command -q xdg-open
                set open_executable xdg-open
            end
        case Darwin # macOS
            if command -q open
                set open_executable open
            end
            # Add other OS specific open commands if necessary
    end

    if test -n "$open_executable"
        # Execute the open command with the selected file
        "$open_executable" "$file_to_open"
        command gum style --foreground 154 --bold "✅  開きました (または開こうとしました): $file_to_open"
    else
        command gum style --foreground 196 --bold "⚠️  このOS ($os_type) でファイルを開く適切なコマンド (xdg-open, open 等) が見つかりません。"
        return 1
    end
    return 0
end

function __fzf_history_insert
    # 履歴をfzfで選択し、現在のコマンドラインに挿入
    # --tacで新しい履歴が上に、--no-sortで履歴の順序を維持、--tiebreak=indexで検索ヒット時の並び順を安定化
    local selected_command = (history | command fzf --tac --no-sort --tiebreak=index --height 40% --reverse --header "コマンド履歴を選択:")
    if test -n "$selected_command"
        commandline "$selected_command" # コマンドラインに挿入 (実行はしない)
        # __which-key の bind 設定で echo; commandline -f repaint されるので、ここで repaint は不要
    else
        command gum style --foreground 196 --bold "⚠️  履歴からコマンドが選択されませんでした。"
    end
end

function __fzf_kill_process
    # `ps aux` の結果を fzf でフィルタリング。ヘッダー行は sed 1d で削除
    # -m で複数選択を許可 (TABキーでマーク)
    local processes_to_kill_info=$(command ps aux | command sed 1d | command fzf -m --header "強制終了するプロセスを選択 (TABで複数選択、Enterで確定):" --height 60% --reverse)

    if test -z "$processes_to_kill_info"
        command gum style --foreground 196 --bold "⚠️  プロセスが選択されませんでした。"
        return 1
    end

    # 選択された各行からPIDを抽出
    echo "$processes_to_kill_info" | while read -l line
        set -l pid (echo "$line" | command awk '{print $2}')
        set -l process_name (echo "$line" | command awk '{$1=$2=$3=$4=$5=$6=$7=$8=$9=$10=""; print $0}' | command string trim) # プロセス名部分を抽出

        if command gum confirm --default=false "本当にプロセス $pid ($process_name) を強制終了しますか？"
            if command kill "$pid"
                command gum style --foreground 154 --bold "✅  プロセス $pid ($process_name) を強制終了しました。"
            else
                command gum style --foreground 196 --bold "❌  プロセス $pid ($process_name) の強制終了に失敗しました。"
            end
        else
            command gum style --foreground 220 --bold "ℹ️  プロセス $pid ($process_name) の強制終了をキャンセルしました。"
        end
    end
end

# 最近使ったGitブランチに切り替え
function __git_switch_recent
    set -l current_branch_name (command git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if test -z "$current_branch_name"
        command gum style --foreground 196 --bold "⚠️  Gitリポジトリではありません、またはブランチがありません。"
        return 1
    end

    # `git reflog show --pretty=%gs` で操作ログを取得
    # `grep 'checkout: moving from'` でブランチ切り替えのログのみフィルタリング
    # `sed 's/checkout: moving from .* to //g'` で切り替え先のブランチ名のみ抽出
    # `awk '!seen[$0]++'` で重複を除去しつつ、ある程度順序を保持（完全な履歴順ではない）
    # `grep -Fxv "$current_branch_name"` で現在のブランチを除外
    set -l recent_branches (command git reflog show --pretty=%gs | command grep 'checkout: moving from' | command sed 's/checkout: moving from .* to //g' | command awk '!seen[$0]++' | command grep -Fxv "$current_branch_name")

    if test (count $recent_branches) -eq 0
        command gum style --foreground 196 --bold "⚠️  最近切り替えた他のブランチが見つかりません。"
        return 1
    end

    set -l selected_branch (printf '%s\n' $recent_branches | command fzf --header "最近使ったブランチを選択 (現在のブランチ: $current_branch_name):" --tac) # --tacで新しいものが上に

    if test -z "$selected_branch"
        command gum style --foreground 196 --bold "⚠️  ブランチが選択されませんでした。"
        return 1
    end

    if command git switch "$selected_branch"
        command gum style --foreground 154 --bold "✅  ブランチ '$selected_branch' に切り替えました。"
    else
        command gum style --foreground 196 --bold "❌  ブランチ '$selected_branch' への切り替えに失敗しました。"
        return 1
    end
end

function __fzf_edit_config
    # 編集したい設定ファイルのリスト (適宜カスタマイズしてください)
    set -l config_files \
        "$HOME/.config/fish/config.fish" \
        "$HOME/.config/fish/functions/__which-key.fish" \
        "$HOME/.gitconfig" \
        "$HOME/.gitignore_global" \
        "$HOME/.config/nvim/init.lua" \
        "$HOME/.config/nvim/lua/plugins.lua" \
        "$HOME/.tmux.conf" \
        /etc/hosts # sudoが必要な場合あり

    # 存在しないファイルを除外
    set -l existing_config_files
    for file in $config_files
        if test -e "$file"
            set -a existing_config_files "$file"
        end
    end

    if test (count $existing_config_files) -eq 0
        command gum style --foreground 196 --bold "⚠️  設定ファイルリストが空か、指定されたファイルが存在しません。"
        return 1
    end

    set -l selected_file (printf '%s\n' $existing_config_files | command fzf --header "編集する設定ファイルを選択:")

    if test -n "$selected_file"
        set -l editor (command_or_default EDITOR nvim vi code) # $EDITOR を優先、なければ nvim, vi, code の順で試す
        if test -z "$editor"
            command gum style --foreground 196 --bold "⚠️  エディタが見つかりません (\$EDITOR 未設定)。"
            return 1
        end
        # sudo が必要なファイルを判定するのは難しいので、ユーザーが適宜 sudo をつけて実行することを想定
        # もしくは、特定のファイルに対して sudo を自動でつけるロジックを追加することも可能
        command $editor "$selected_file"
        command gum style --foreground 154 --bold "✅  $selected_file を $editor で開きました (または開こうとしました)。"
    else
        command gum style --foreground 196 --bold "⚠️  ファイルが選択されませんでした。"
    end
end

function command_or_default
    set -l var_name $argv[1]
    if set -q $var_name; and test -n (eval echo \$$var_name)
        eval echo \$$var_name
        return 0
    end
    for cmd_name in $argv[2..-1]
        if command -q $cmd_name
            echo $cmd_name
            return 0
        end
    end
    return 1
end

function __fzf_ssh
    if not test -f "$HOME/.ssh/config"
        command gum style --foreground 196 --bold "⚠️  SSH設定ファイル (~/.ssh/config) が見つかりません。"
        return 1
    end
    # `grep -v '*'` でワイルドカードホストを除外、`grep -v '^$'` で空行を除外
    set -l hosts (command awk '/^Host / && !seen[$2]++ {print $2}' "$HOME/.ssh/config" | command grep -vE '(\*|^$)')

    if test (count $hosts) -eq 0
        command gum style --foreground 196 --bold "⚠️  ~/.ssh/config に接続可能なホストが見つかりません。"
        return 1
    end

    set -l selected_host (printf '%s\n' $hosts | command fzf --header "接続するSSHホストを選択:")

    if test -n "$selected_host"
        command gum style --foreground 154 --bold " Attempting to connect to $selected_host..."
        command ssh "$selected_host"
    else
        command gum style --foreground 196 --bold "⚠️  ホストが選択されませんでした。"
    end
end

function __fzf_docker_manage
    if not command -q docker
        command gum style --foreground 196 --bold "⚠️  Dockerコマンドが見つかりません。"
        return 1
    end

    set -l container_info_lines (command docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}")
    if test (string length -q "$container_info_lines") -lt 2 # ヘッダー行のみ、または空の場合
        command gum style --foreground 196 --bold "⚠️  Dockerコンテナが見つかりません。"
        return 1
    end

    # fzfでヘッダーを表示しつつ、選択はデータ行から
    set -l selected_container_line (echo "$container_info_lines" | command fzf --header "管理するDockerコンテナを選択:" --header-lines=1 --height 60% --reverse)

    if test -z "$selected_container_line"
        command gum style --foreground 196 --bold "⚠️  コンテナが選択されませんでした。"
        return 1
    end

    set -l container_id (echo "$selected_container_line" | command awk '{print $1}')
    set -l container_name (echo "$selected_container_line" | command awk '{print $2}')

    set -l action (command gum choose "start" "stop" "restart" "logs" "logs -f (follow)" "inspect" "rm (remove)" --header "コンテナ '$container_name' に対する操作を選択:")

    if test -z "$action"
        command gum style --foreground 196 --bold "⚠️  操作が選択されませんでした。"
        return 1
    end

    switch "$action"
        case start stop restart inspect
            command docker "$action" "$container_id"
        case logs
            command docker logs "$container_id" | command less -R
        case "logs -f (follow)"
            command docker logs -f "$container_id"
        case "rm (remove)"
            if command gum confirm "本当にコンテナ '$container_name' ($container_id) を削除しますか？"
                command docker rm "$container_id"
            else
                command gum style --foreground 220 --bold "ℹ️  コンテナ削除をキャンセルしました。"
            end
        case '*'
            command gum style --foreground 196 --bold "⚠️  不明な操作です: $action"
    end
end

function __fzf_tmux_session
    if not command -q tmux
        command gum style --foreground 196 --bold "⚠️  Tmuxコマンドが見つかりません。"
        return 1
    end

    set -l sessions (command tmux list-sessions -F "#{session_name}" 2>/dev/null)
    set -l options

    if test (count $sessions) -gt 0
        for session in $sessions
            set -a options "Attach: $session"
        end
    end
    set -a options "New session"
    if test (count $sessions) -gt 0
        set -a options "Kill session"
    end

    set -l chosen_action (printf '%s\n' $options | command fzf --header "Tmuxアクションを選択:")

    if test -z "$chosen_action"
        command gum style --foreground 196 --bold "⚠️  アクションが選択されませんでした。"
        return 1
    end

    if string match -q "Attach: *" "$chosen_action"
        set -l session_to_attach (string replace "Attach: " "" "$chosen_action")
        command tmux attach-session -t "$session_to_attach"
    else if test "$chosen_action" = "New session"
        set -l new_session_name (command gum input --placeholder "新しいセッション名 (空なら自動):")
        if test $status -ne 0 # gum inputでEscなどが押された場合
            command gum style --foreground 196 --bold "⚠️  セッション作成がキャンセルされました。"
            return 1
        end
        if test -z "$new_session_name"
            command tmux new-session
        else
            command tmux new-session -s "$new_session_name"
        end
    else if test "$chosen_action" = "Kill session"
        set -l session_to_kill (printf '%s\n' $sessions | command fzf --header "終了するTmuxセッションを選択:")
        if test -n "$session_to_kill"
            if command gum confirm "本当にセッション '$session_to_kill' を終了しますか？"
                command tmux kill-session -t "$session_to_kill"
                command gum style --foreground 154 --bold "✅  セッション '$session_to_kill' を終了しました。"
            else
                command gum style --foreground 220 --bold "ℹ️  セッション終了をキャンセルしました。"
            end
        else
            command gum style --foreground 196 --bold "⚠️  終了するセッションが選択されませんでした。"
        end
    end
end

function __fzf_open_project_in_editor
    # プロジェクトディレクトリの検索方法を定義
    # 例1: ghq を使用する場合
    set -l projects
    if command -q ghq
        set -l ghq_root (command ghq root)
        set -l project_names (command ghq list)
        for name in $project_names
            set -a projects "$ghq_root/$name"
        end
    else
        # 例2: 特定のディレクトリ以下を検索 (深さ1)
        # set -l project_base_dir "$HOME/develop"
        # if test -d "$project_base_dir"
        #     set projects (command fd --type d --max-depth 1 . "$project_base_dir")
        # end
        command gum style --foreground 196 --bold "⚠️  ghqが見つかりません。プロジェクト検索方法を関数内で設定してください。"
        return 1
    end

    if test (count $projects) -eq 0
        command gum style --foreground 196 --bold "⚠️  プロジェクトが見つかりません。"
        return 1
    end

    set -l selected_project_path (printf '%s\n' $projects | command fzf --header "エディタで開くプロジェクトを選択:")

    if test -n "$selected_project_path"
        set -l editor (command_or_default EDITOR nvim vi code)
        if test -z "$editor"
            command gum style --foreground 196 --bold "⚠️  エディタが見つかりません (\$EDITOR 未設定)。"
            return 1
        end
        # エディタによってはカレントディレクトリを変更せずに開く方が良い場合もある
        # (例: `code "$selected_project_path"`)
        # ここではプロジェクトディレクトリに移動してからエディタを開く例
        # cd "$selected_project_path"
        # command $editor .
        command $editor "$selected_project_path" # 多くのエディタはパス指定でそのディレクトリを開ける
        command gum style --foreground 154 --bold "✅  $selected_project_path を $editor で開きました (または開こうとしました)。"
    else
        command gum style --foreground 196 --bold "⚠️  プロジェクトが選択されませんでした。"
    end
end

function __fzf_git_log_actions
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        command gum style --foreground 196 --bold "⚠️  Gitリポジトリではありません。"
        return 1
    end

    # カスタマイズ可能なGit logフォーマット
    set -l pretty_format "%C(yellow)%h%Creset %C(green)(%cr)%Creset %C(bold blue)<%an>%Creset%C(auto)%d%Creset %s"
    set -l git_log_cmd "command git log --graph --pretty=format:'$pretty_format' --all --date=short --color=always"

    # fzfでコミットを選択
    # Ctrl-Dでdiff, Ctrl-Sでshow, Enterでアクションメニュー
    set -l selected_commit_line (eval $git_log_cmd | command fzf --ansi \
        --header "Gitログ (Enter:アクション, Ctrl-D:diff, Ctrl-S:show)" \
        --height 70% --reverse \
        --preview "echo {} | command awk '{print \$1}' | xargs -I@ git show --color=always @" \
        --bind "ctrl-d:execute(echo {} | awk '{print \$1}' | xargs -I@ git diff --color=always @^! | less -R)+reload(eval $git_log_cmd)" \
        --bind "ctrl-s:execute(echo {} | awk '{print \$1}' | xargs -I@ git show --color=always @ | less -R)+reload(eval $git_log_cmd)")

    if test -z "$selected_commit_line"
        command gum style --foreground 196 --bold "⚠️  コミットが選択されませんでした。"
        return 1
    end

    set -l commit_hash (echo "$selected_commit_line" | command awk '{print $1}')

    set -l action (command gum choose \
        "show (詳細表示)" \
        "diff (親と比較)" \
        "diff --staged (ステージング状態と比較)" \
        "checkout (このコミットをチェックアウト)" \
        "cherry-pick (このコミットを取り込む)" \
        "revert (このコミットを打ち消すコミットを作成)" \
        "reset --hard (このコミットまで戻す - 注意!)" \
        "copy hash (ハッシュをコピー)" \
        "copy message (メッセージをコピー)" \
        --header "コミット '$commit_hash' に対する操作を選択:")

    if test -z "$action"
        command gum style --foreground 196 --bold "⚠️  操作が選択されませんでした。"
        return 1
    end

    switch "$action"
        case "show (詳細表示)"
            command git show --color=always "$commit_hash" | command less -R
        case "diff (親と比較)"
            command git diff --color=always "$commit_hash^!" | command less -R
        case "diff --staged (ステージング状態と比較)"
            command git diff --staged --color=always "$commit_hash" | command less -R
        case "checkout (このコミットをチェックアウト)"
            if command gum confirm "本当にコミット '$commit_hash' をチェックアウトしますか？ (HEADがデタッチ状態になります)"
                command git checkout "$commit_hash"
            end
        case "cherry-pick (このコミットを取り込む)"
            if command gum confirm "本当にコミット '$commit_hash' をcherry-pickしますか？"
                command git cherry-pick "$commit_hash"
            end
        case "revert (このコミットを打ち消すコミットを作成)"
            if command gum confirm "本当にコミット '$commit_hash' をrevertしますか？"
                command git revert "$commit_hash"
            end
        case "reset --hard (このコミットまで戻す - 注意!)"
            if command gum confirm --default=false "【警告】本当に '$commit_hash' まで reset --hard しますか？ 未コミットの変更とこれ以降のコミットは失われます！"
                if command gum confirm --default=false "【最終確認】'$commit_hash' まで reset --hard します。よろしいですか？"
                    command git reset --hard "$commit_hash"
                end
            end
        case "copy hash (ハッシュをコピー)"
            echo "$commit_hash" | command pbcopy # macOS. Linuxなら xclip -selection clipboard など
            command gum style --foreground 154 --bold "✅  ハッシュ '$commit_hash' をクリップボードにコピーしました。"
        case "copy message (メッセージをコピー)"
            command git log -n 1 --pretty=%B "$commit_hash" | command tr -d '\n' | command pbcopy # macOS
            command gum style --foreground 154 --bold "✅  コミットメッセージをクリップボードにコピーしました。"
        case '*'
            command gum style --foreground 196 --bold "⚠️  不明な操作です: $action"
    end
end

function __fzf_terraform_actions
    if not command -q terraform
        command gum style --foreground 196 --bold "⚠️ Terraform CLIが見つかりません。"
        return 1
    end

    # Check if the current directory contains .tf files.
    # This is a basic check; a more robust check might involve `terraform workspace show` or looking for a `.terraform` directory.
    if not test (count *.tf) -gt 0
        command gum style --foreground 220 --bold --padding "0 1" "ℹ️  現在のディレクトリに .tf ファイルが見つかりません。Terraformプロジェクトを検索します..."
        set -l selected_tf_project_dir # Variable to store the chosen project directory

        # Common fzf options
        set -l fzf_options --prompt="Search TF Dirs> " --height=40% --reverse

        if command -q fd
            # Use fd to find directories named '.terraform', then get their parent directory.
            # fd's regex '^\.terraform$' ensures the directory name is exactly '.terraform'.
            # sed removes the '/.terraform' part to get the parent path.
            set selected_tf_project_dir (command fd --type d --hidden --absolute-path '^\.terraform$' "$HOME" 2>/dev/null | command sed 's|/\.terraform$||' | command fzf --header="Terraformプロジェクトを選択 (using fd):" $fzf_options)
        else
            command gum style --foreground 220 --bold --padding "0 1" "ℹ️ 'fd' command not found. Falling back to 'find' to locate Terraform projects (this may be slower)."
            # Use find to locate directories named ".terraform", then get their parent path using dirname.
            # -print0 and xargs -0 handle filenames with special characters safely.
            # sort -u ensures unique project directories.
            set selected_tf_project_dir (find "$HOME" -type d -name ".terraform" -print0 2>/dev/null | command xargs -0 -I {} dirname {} | command sort -u | command fzf --header="Terraformプロジェクトを選択 (using find):" $fzf_options)
        end

        if test -z "$selected_tf_project_dir"
            command gum style --foreground 196 --bold "⚠️ Terraformプロジェクトが見つからないか、選択されませんでした。"
            return 1
        end

        cd "$selected_tf_project_dir"
        command gum style --foreground 154 --bold "✅  移動しました: $selected_tf_project_dir"
    end

    # --- Rest of the Terraform actions (init, plan, apply, etc.) ---
    set terraform_version (command terraform version -json 2>/dev/null | command jq -r .terraform_version 2>/dev/null; or echo "unknown")
    set current_workspace (command terraform workspace show 2>/dev/null; or echo "default") # Ensure this doesn't error if not in a TF dir yet
    set header_text "Terraform v$terraform_version | Workspace: $current_workspace | Actions:"

    set -l action (command gum choose \
        "init" \
        "validate" \
        "fmt (format)" \
        "plan" \
        "apply" \
        "destroy" \
        "workspace list" \
        "workspace select" \
        "output (show outputs)" \
        "state list" \
        --header "$header_text" --height 15)

    if test -z "$action"
        command gum style --foreground 196 --bold "⚠️ 操作が選択されませんでした。"
        return 1
    end

    switch "$action"
        case init
            command terraform init
        case validate
            command terraform validate
        case "fmt (format)"
            command terraform fmt -recursive
        case plan
            set plan_options (command gum input --placeholder "追加のplanオプション (例: -out=tfplan):")
            command terraform plan $plan_options
        case apply
            set apply_options (command gum input --placeholder "追加のapplyオプション (例: tfplan または -auto-approve):")
            if string match -q -- -auto-approve "$apply_options"
                command terraform apply -auto-approve $apply_options # Ensure -auto-approve is correctly handled
            else if command gum confirm "Terraform apply を実行しますか？ ($apply_options)"
                command terraform apply $apply_options
            else
                command gum style --foreground 220 --bold "ℹ️  Applyをキャンセルしました。"
            end
        case destroy
            set destroy_options (command gum input --placeholder "追加のdestroyオプション (例: -target=...):")
            if command gum confirm --default=false "【警告】Terraform destroy を実行しますか？ ($destroy_options)"
                command terraform destroy $destroy_options
            else
                command gum style --foreground 220 --bold "ℹ️  Destroyをキャンセルしました。"
            end
        case "workspace list"
            command terraform workspace list
        case "workspace select"
            set -l ws_to_select (command terraform workspace list | command sed -e 's/\*//g' -e 's/^[ \t]*//;s/[ \t]*$//' | command fzf --header "切り替えるワークスペースを選択:") # Clean up workspace list a bit
            if test -n "$ws_to_select"
                command terraform workspace select "$ws_to_select"
            end
        case "output (show outputs)"
            command terraform output | command gum pager --soft-wrap
        case "state list"
            # Previewing terraform state show can be slow for large states/resources
            command terraform state list | command fzf --multi --header "state list (Enterで選択リソースの詳細表示)" --preview "echo {} | xargs -I@ terraform state show @" --preview-window=down:70% | command xargs -I@ terraform state show @ | command gum pager --soft-wrap
        case '*'
            command gum style --foreground 196 --bold "⚠️ 不明なTerraform操作です: $action"
    end
    return 0
end

function __fzf_kubernetes_menu
    if not command -q kubectl
        command gum style --foreground 196 --bold "⚠️ kubectl CLIが見つかりません。"
        return 1
    end

    set current_context (kubectl config current-context)
    set current_ns (kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null; or echo "default")
    set header_text "K8s: $current_context | Namespace: $current_ns | Operations:"

    set -l category (command gum choose \
        "Context / Namespace" \
        "Workloads (Pods, Deployments, etc.)" \
        "Network (Services, Ingresses)" \
        "Config (ConfigMaps, Secrets)" \
        "Nodes" \
        "Events" \
        "Helm Charts" \
        --header "$header_text" --height 12)

    if test -z "$category"
        command gum style --foreground 196 --bold "⚠️ カテゴリが選択されませんでした。"
        return 1
    end

    switch "$category"
        case "Context / Namespace"
            __fzf_kube_context_namespace
        case "Workloads (Pods, Deployments, etc.)"
            __fzf_kube_workloads
        case "Network (Services, Ingresses)"
            __fzf_kube_network
        case "Config (ConfigMaps, Secrets)"
            __fzf_kube_config
        case Nodes
            __fzf_kube_nodes
        case Events
            kubectl get events --sort-by=.metadata.creationTimestamp -A | command gum pager
        case "Helm Charts"
            __fzf_helm_charts # Placeholder for Helm function
        case '*'
            command gum style --foreground 196 --bold "⚠️ 不明なカテゴリです: $category"
    end
end

function __fzf_kube_context_namespace
    set -l action (gum choose "View Current" "Set Context" "Set Namespace (for current context)" --header "Context/Namespace Actions:" --height 7)
    switch $action
        case "View Current"
            gum style --padding "1 2" --border normal "Current Context: (kubectl config current-context)\nCurrent Namespace: (kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null; or echo "default")"
        case "Set Context"
            set -l ctx (kubectl config get-contexts -o name | fzf --header "Select Kubernetes Context:")
            if test -n "$ctx"
                kubectl config use-context "$ctx"
            end
        case "Set Namespace (for current context)"
            set -l ns (kubectl get namespaces -o custom-columns=NAME:.metadata.name --no-headers | fzf --header "Select Namespace:")
            if test -n "$ns"
                kubectl config set-context --current --namespace="$ns"
            end
    end
end

function __fzf_kube_workloads
    set -l ns_arg "-n (kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null; or echo "default")"
    set -l all_ns_opt (gum choose "Current Namespace" "All Namespaces")
    if test "$all_ns_opt" = "All Namespaces"
        set ns_arg -A
    end

    set -l type (gum choose "pods" "deployments" "statefulsets" "daemonsets" "jobs" "cronjobs" --header "Select Workload Type:" --height 10)
    if test -z "$type"
        return 1
    end

    set -l resource_line (eval "kubectl get $type $ns_arg -o wide | fzf --header-lines=1 --header \"Select $type:\"")
    if test -z "$resource_line"
        return 1
    end
    set -l resource_name (echo "$resource_line" | awk '{print $1}')
    set -l resource_namespace (eval "echo \"$ns_arg\" | string replace -- '-n ' '' | string replace -- '-A' ''") # Simplistic, needs refinement if -A
    if test "$ns_arg" = -A
        set resource_namespace (echo "$resource_line" | awk '{print $1}')
        set resource_name (echo "$resource_line" | awk '{print $2}')
    end # if -A, first col is ns

    set -l op (gum choose "logs" "describe" "delete" "edit" "exec (shell - pods only)" "port-forward (pods only)" --header "Actions for $type '$resource_name':" --height 10)
    switch $op
        case logs
            kubectl logs -f "$resource_name" $ns_arg # For deployments, etc., might need -l selector
        case describe
            kubectl describe "$type" "$resource_name" $ns_arg | gum pager
        case delete
            if gum confirm "Really delete $type '$resource_name'?"
                kubectl delete "$type" "$resource_name" $ns_arg
            end
        case edit
            kubectl edit "$type" "$resource_name" $ns_arg
        case "exec (shell - pods only)"
            if test "$type" = pods
                kubectl exec -it "$resource_name" $ns_arg -- sh
            else
                gum style --foreground 196 "⚠️ Exec only available for pods."
            end
        case "port-forward (pods only)"
            if test "$type" = pods
                set ports (gum input --placeholder "local_port:remote_port (e.g., 8080:80)")
                if test -n "$ports"
                    kubectl port-forward "$resource_name" "$ports" $ns_arg
                end
            else
                gum style --foreground 196 "⚠️ Port-forward only available for pods."
            end
    end
end

function __fzf_helm_charts
    if not command -q helm
        gum style --foreground 196 "⚠️ Helm CLI not found."
        return 1
    end
    set -l chart_info (helm list -A -o json | jq -r '.[] | "\(.name)\t\(.namespace)\t\(.chart)\t\(.status)\t\(.updated)"' | fzf --header "Helm Releases (Name Namespace Chart Status Updated)")
    if test -z "$chart_info"
        return 1
    end
    # Add actions for selected chart (history, rollback, uninstall, etc.)
    echo "Selected: $chart_info" && gum spin --title "Further actions TBD..." sleep 2
end

function __fzf_nmap_scan
    if not command -q nmap
        command gum style --foreground 196 --bold "⚠️ Nmapが見つかりません。"
        return 1
    end

    set -l target (command gum input --placeholder "ターゲットIP/ホスト名/ドメイン (例: 192.168.1.1, scanme.nmap.org):")
    if test -z "$target"
        command gum style --foreground 196 --bold "⚠️ ターゲットが指定されませんでした。"
        return 1
    end

    set -l scan_type (command gum choose \
        "Quick Scan (-T4 -F)" \
        "Intense Scan (-T4 -A -v)" \
        "Ping Scan (-sn -PE -PP -PS80,443 -PA3389 -PU40125 -T4)" \
        "TCP Full Connect Scan (-sT)" \
        "UDP Scan (-sU --top-ports 20)" \
        "Vulnerability Scan (--script vuln)" \
        "Custom Options" \
        --header "Nmapスキャンタイプを選択 ($target):" --height 10)

    if test -z "$scan_type"
        command gum style --foreground 196 --bold "⚠️ スキャンタイプが選択されませんでした。"
        return 1
    end

    set -l nmap_options
    switch "$scan_type"
        case "Quick Scan (-T4 -F)"
            set nmap_options "-T4 -F"
        case "Intense Scan (-T4 -A -v)"
            set nmap_options "-T4 -A -v"
        case "Ping Scan (-sn -PE -PP -PS80,443 -PA3389 -PU40125 -T4)"
            set nmap_options "-sn -PE -PP -PS80,443 -PA3389 -PU40125 -T4"
        case "TCP Full Connect Scan (-sT)"
            set nmap_options -sT
        case "UDP Scan (-sU --top-ports 20)"
            set nmap_options "-sU --top-ports 20"
        case "Vulnerability Scan (--script vuln)"
            set nmap_options "--script vuln"
        case "Custom Options"
            set nmap_options (command gum input --placeholder "Nmapオプションを入力:")
        case '*'
            command gum style --foreground 196 --bold "⚠️ 不明なスキャンタイプです。"
            return 1
    end

    set use_sudo no
    if string match -q -- "*(-sS|-sU|-O|--script vuln)*" "$nmap_options" # Common options needing sudo
        if command gum confirm "このスキャンタイプはsudo権限が必要な場合があります。sudoで実行しますか？"
            set use_sudo yes
        end
    end

    command gum style --foreground 154 --bold " Nmapスキャンを実行中: $nmap_options $target ..."
    if test "$use_sudo" = yes
        sudo nmap $nmap_options "$target" | command gum pager --soft-wrap
    else
        nmap $nmap_options "$target" | command gum pager --soft-wrap
    end
end

function __fzf_file_hash
    set -l file_to_hash
    set -l search_paths "." "$HOME" # Search current directory and home directory

    if command -q fd
        # Use fd: --type f (files), --hidden (include hidden), --no-ignore-vcs (don't use .gitignore etc.)
        set file_to_hash (command fd --type f --hidden --no-ignore-vcs $search_paths | command fzf --header "ハッシュを計算するファイルを選択 (using fd):" --height 40% --reverse)
    else
        command gum style --foreground 220 --bold --padding "0 1" "ℹ️ 'fd' command not found. Falling back to 'find'. This might be slower and less precise."
        # Use find: -type f (files). Searches current directory and home directory.
        # -maxdepth 5 is to prevent excessively deep searches in large directories. Adjust if needed.
        # 2>/dev/null suppresses 'Permission denied' errors from find.
        # Use begin...end to group find commands before piping to fzf
        set file_to_hash (begin
            find $search_paths[1] -maxdepth 5 -type f 2>/dev/null
            find $search_paths[2] -maxdepth 5 -type f 2>/dev/null
        end | command fzf --header "ハッシュを計算するファイルを選択 (using find):" --height 40% --reverse)
    end

    if test -z "$file_to_hash"
        command gum style --foreground 196 --bold "⚠️ ファイルが選択されませんでした。"
        return 1
    end

    if not test -f "$file_to_hash"
        command gum style --foreground 196 --bold "⚠️ 選択されたパスはファイルではありません: '$file_to_hash'"
        return 1
    end

    # OS detection for hash command
    set -l hash_cmd
    set -l os_type (uname)
    switch $os_type
        case Linux
            set hash_cmd sha256sum
        case Darwin # macOS
            set hash_cmd "shasum -a 256"
        case '*' # Add other OS like *BSD if needed
            if command -q sha256 # FreeBSD for example
                set hash_cmd sha256
            else
                command gum style --foreground 196 --bold "⚠️ サポートされていないOSです ($os_type)。ハッシュコマンドが見つかりません。"
                return 1
            end
    end

    set -l hash_output_full (eval $hash_cmd "$file_to_hash")
    if test $status -ne 0
        command gum style --foreground 196 --bold "⚠️ ハッシュの計算に失敗しました: $file_to_hash"
        # Optionally print the error from the hash command
        # echo "Error output: $hash_output_full" >&2
        return 1
    end

    set -l just_the_hash (echo "$hash_output_full" | awk '{print $1}')

    command gum style --padding "1 2" --border normal --align center \
        "File: $file_to_hash" \
        "SHA256: $just_the_hash"

    # OS detection for clipboard copy command
    set -l copy_cmd
    switch $os_type
        case Darwin # macOS
            if command -q pbcopy
                set copy_cmd pbcopy
            end
        case Linux
            if command -q xclip
                set copy_cmd "xclip -selection clipboard"

            else if command -q wl-copy
                set copy_cmd wl-copy
                # For Wayland
            end
    end

    if test -n "$copy_cmd"
        if command gum confirm "ハッシュ値をクリップボードにコピーしますか？"
            echo "$just_the_hash" | eval $copy_cmd
            command gum style --foreground 154 --bold "✅ ハッシュ値をコピーしました。"
        end
    else
        # Only show this message if a copy command was expected but not found
        if test "$os_type" = Darwin -o "$os_type" = Linux
            command gum style --foreground 220 --bold "ℹ️ クリップボードコマンド (pbcopy, xclip, wl-copy 等) が見つかりませんでした。"
        end
    end
    return 0
end

function command_or_default
    set -l var_name $argv[1]
    if set -q $var_name; and test -n (eval echo \$$var_name)
        eval echo \$$var_name
        return 0
    end
    for cmd_name in $argv[2..-1]
        if command -q $cmd_name
            echo $cmd_name
            return 0
        end
    end
    return 1
end

function __which-key
    # Create a list of menu items
    set -l menu_items
    set -a menu_items "c → ディレクトリ変更 (cdf)"
    set -a menu_items "f → ファイル検索 & 開く"
    set -a menu_items "h → コマンド履歴検索"
    set -a menu_items "t → Tmuxセッション管理"
    set -a menu_items "k → プロセス強制終了"
    set -a menu_items "e → 設定ファイル編集"
    set -a menu_items "--- Project ---"
    set -a menu_items "o → プロジェクトをエディタで開く"
    set -a menu_items "g → ghq プロジェクトへ移動"
    set -a menu_items "w → Gitブランチ切り替え (フィルタ済)"
    set -a menu_items "b → Gitブランチ切り替え (最近使用)"
    set -a menu_items "l → Gitログ表示 & アクション"
    set -a menu_items "--- Infra ---"
    set -a menu_items "S → SSH接続"
    set -a menu_items "T → Terraform Actions"
    set -a menu_items "D → Docker Operations"
    set -a menu_items "K → Kubernetes Operations"
    set -a menu_items "--- Web ---"
    set -a menu_items "c → cURLリクエスト"
    set -a menu_items "w → Webブラウザで開く"
    set -a menu_items "--- Mobile ---"
    set -a menu_items "a → Android Emulator"
    set -a menu_items "i → iOS Simulator"
    set -a menu_items "--- Security ---"
    set -a menu_items "N → Nmap Network Scan"
    set -a menu_items "H → Calculate File Hash (SHA256)"

    # Pipe the menu items to gum style
    printf '%s\n' $menu_items | command gum style \
        --border rounded \
        --margin "1 1" \
        --padding "1 2" \
        --align left \
        --bold

    read --nchars 1 choice

    switch $choice
        case c
            cdf
        case f
            __fzf_open_file
        case h
            __fzf_history_insert
        case t
            __fzf_tmux_session
        case k
            __fzf_kill_process
        case e
            __fzf_edit_config
        case o
            __fzf_open_project_in_editor
        case g
            __ghq_cd_interactive
        case w
            __git_sw
        case b
            __git_switch_recent
        case l
            __fzf_git_log_actions
        case S
            __fzf_ssh
        case T
            __fzf_terraform_actions
        case D
            __fzf_docker_manage
        case K
            __fzf_kubernetes_menu
        case c
            __fzf_curl_request
        case w
            __fzf_open_web_browser
        case a
            __android_emulator
        case i
            __xcode_simulator
        case N
            __fzf_nmap_scan
        case H
            __fzf_file_hash
        case '*'
            command gum style --foreground 196 --bold "⚠️  不明な選択肢: $choice"
    end
end

bind --mode insert \ce '__which-key; echo; commandline -f repaint'
