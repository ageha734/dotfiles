function recf -d 現在のfishセッションをasciinemaで記録開始します
    if set -q ASCIINEMA_REC
        echo "既に asciinema の記録セッション内です。"
        return 1
    end

    set -l session_name
    if test -n "$argv[1]"
        set session_name "$argv[1]"
    else
        set session_name "fish-$(date +%Y%m%d-%H%M%S)"
    end

    set -l log_dir "$HOME/asciinema_logs"
    mkdir -p "$log_dir" # 念のためディレクトリ作成
    set -l filename "$log_dir/$session_name.cast"

    echo "asciinema での記録を開始します..."
    echo "ログファイル: $filename"
    echo "記録を停止するには、このシェルを 'exit' するか Ctrl-D を押してください。"
    # 現在のシェルをasciinemaプロセスに置き換える
    exec asciinema rec "$filename" -c fish
end
