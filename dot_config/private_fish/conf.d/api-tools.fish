# API / Redis / DB tools (interactive only)
if not status is-interactive
    exit
end

# ── HTTP API testing (curl wrapper) ───────────────────────────
function api --description "Quick API request with pretty output"
    set -l method (string upper $argv[1])
    set -l url $argv[2]
    set -l body $argv[3]

    if test -z "$url"
        echo "usage: api <GET|POST|PUT|DELETE> <url> [body]"
        return 1
    end

    set -l curl_args -s -w "\n---\nHTTP %{http_code} | %{time_total}s | %{size_download}B\n"
    set -a curl_args -X $method
    set -a curl_args -H "Content-Type: application/json"

    if test -n "$body"
        set -a curl_args -d $body
    end

    curl $curl_args "$url" | jq . 2>/dev/null || curl $curl_args "$url"
end

# ── Redis helpers ─────────────────────────────────────────────
function rkeys --description "Redis: search keys by pattern"
    set -l pattern (test -n "$argv[1]"; and echo $argv[1]; or echo "*")
    redis-cli --no-auth-warning KEYS "$pattern"
end

function rget --description "Redis: get key value (auto-detect type)"
    if test -z "$argv[1]"
        echo "usage: rget <key>"
        return 1
    end
    set -l key_type (redis-cli --no-auth-warning TYPE "$argv[1]" | string trim)
    switch $key_type
        case string
            redis-cli --no-auth-warning GET "$argv[1]"
        case list
            redis-cli --no-auth-warning LRANGE "$argv[1]" 0 -1
        case set
            redis-cli --no-auth-warning SMEMBERS "$argv[1]"
        case zset
            redis-cli --no-auth-warning ZRANGE "$argv[1]" 0 -1 WITHSCORES
        case hash
            redis-cli --no-auth-warning HGETALL "$argv[1]"
        case '*'
            echo "type: $key_type"
            redis-cli --no-auth-warning GET "$argv[1]"
    end
end

function rmon --description "Redis: monitor commands in real-time"
    redis-cli --no-auth-warning MONITOR
end

# ── DB quick connect ──────────────────────────────────────────
function pgc --description "Quick psql connect"
    if test -n "$argv[1]"
        psql "$argv[1]"
    else if test -n "$DATABASE_URL"
        psql "$DATABASE_URL"
    else
        echo "usage: pgc <connection-string> or set DATABASE_URL"
    end
end

# ── .http file runner (curl-based) ────────────────────────────
function http-run --description "Run a .http file request block"
    if test -z "$argv[1]"
        echo "usage: http-run <file.http>"
        return 1
    end
    # 最初のリクエストブロックを実行
    set -l method (head -1 "$argv[1]" | awk '{print $1}')
    set -l url (head -1 "$argv[1]" | awk '{print $2}')
    set -l headers
    set -l body ""
    set -l in_body false

    for line in (tail -n +2 "$argv[1]")
        if test -z "$line"; and test "$in_body" = false
            set in_body true
            continue
        end
        if test "$in_body" = true
            set body "$body$line"
        else
            set -a headers -H "$line"
        end
    end

    set -l curl_args -s -X $method $headers
    if test -n "$body"
        set -a curl_args -d "$body"
    end
    curl $curl_args "$url" | jq . 2>/dev/null || curl $curl_args "$url"
end
