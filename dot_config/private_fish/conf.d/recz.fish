function recz -d 新しいZellijセッションをasciinemaで記録開始します
    if set -q ASCIINEMA_REC
        echo "既に asciinema の記録セッション内にいます。Zellij の記録を開始できません。"
        echo "現在の記録セッションを終了してから再度実行してください。"
        return 1
    end

    set -l session_name_arg $argv[1]
    set -l zellij_options $argv[2..-1] # Zellijへの追加オプションを取得

    set -l session_name
    if test -n "$session_name_arg"
        set session_name "zellij-$session_name_arg"
    else
        set session_name "zellij-$(date +%Y%m%d-%H%M%S)"
    end

    set -l log_dir "$HOME/asciinema_logs"
    mkdir -p "$log_dir" # 念のためディレクトリ作成
    set -l filename "$log_dir/$session_name.cast"

    set -l zellij_cmd zellij
    if test (count $zellij_options) -gt 0
        set zellij_cmd $zellij_cmd $zellij_options
    end

    echo "Zellij セッションの asciinema での記録を開始します..."
    echo "ログファイル: $filename"
    echo "Zellij を終了すると記録も停止します。"
    asciinema rec "$filename" -c "$zellij_cmd"
end
