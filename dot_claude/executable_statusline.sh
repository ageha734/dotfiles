#!/bin/bash

input=$(cat)

cwd=$(echo "$input" | jq -r '.cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
version=$(echo "$input" | jq -r '.version // ""')

line1=""

if [ -n "$cwd" ]; then
  git_toplevel=$(timeout 1 git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
  if [ -n "$git_toplevel" ]; then
    repo_name=$(basename "$git_toplevel")
    line1="╭─ 📁 ${repo_name}"

    if [ "$cwd" != "$git_toplevel" ]; then
      rel_path="${cwd#"${git_toplevel}"}"
      line1="${line1}  ${rel_path}"
    fi

    git_branch=$(timeout 1 git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
    if [ -n "$git_branch" ]; then
      line1="${line1}  🌿 ${git_branch}"
    fi

    shortstat=$(timeout 1 git -C "$cwd" --no-optional-locks diff HEAD --shortstat 2>/dev/null)
    if [ -n "$shortstat" ]; then
      added=$(echo "$shortstat" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+')
      removed=$(echo "$shortstat" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+')
      files=$(echo "$shortstat" | grep -oE '[0-9]+ file' | grep -oE '[0-9]+')
      added=${added:-0}
      removed=${removed:-0}
      files=${files:-0}
      if [ "$added" -gt 0 ] || [ "$removed" -gt 0 ]; then
        line1="${line1}  ↕ +${added} -${removed} (${files} files)"
      else
        line1="${line1}  ✓ clean"
      fi
    else
      line1="${line1}  ✓ clean"
    fi
  fi
fi

line2="│  🤖 ${model}"
if [ -n "$version" ]; then
  line2="${line2} v${version}"
fi

used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used_pct" ]; then
  filled=$(echo "$used_pct" | awk '{n=int($1/10+0.5); if(n>10)n=10; print n}')
  empty_count=$((10 - filled))
  progress_bar=""
  i=0
  while [ "$i" -lt "$filled" ]; do progress_bar="${progress_bar}█"; i=$((i+1)); done
  i=0
  while [ "$i" -lt "$empty_count" ]; do progress_bar="${progress_bar}░"; i=$((i+1)); done
  pct_display=$(printf "%.0f%%" "$used_pct")
  line2="${line2}  │  ${progress_bar} ${pct_display}"

  exceeds=$(echo "$input" | jq -r 'if .context_window.current_usage != null then (.context_window.current_usage.input_tokens // 0) > 200000 else false end')
  if [ "$exceeds" = "true" ]; then
    line2="${line2}  ⚠ ctx exceeded"
  fi
fi

total_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$total_cost" ]; then
  cost_display=$(printf "%.2f" "$total_cost")
  line2="${line2}  │  💰 \$${cost_display}"
fi

total_lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
total_lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
if [ "$total_lines_added" -gt 0 ] || [ "$total_lines_removed" -gt 0 ]; then
  line2="${line2}  │  ✏ +${total_lines_added} -${total_lines_removed}"
fi

agent_name=$(echo "$input" | jq -r '.agent.name // empty')
if [ -n "$agent_name" ]; then
  line2="${line2}  │  🔧 ${agent_name}"
fi

worktree_name=$(echo "$input" | jq -r '.worktree.name // empty')
if [ -n "$worktree_name" ]; then
  line2="${line2}  │  🪵 ${worktree_name}"
fi

line3=""

if [ -n "$cwd" ]; then
  if [ -f "${cwd}/go.mod" ]; then
    go_ver=$(timeout 1 go version 2>/dev/null | grep -oE 'go[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1 | sed 's/go//')
    if [ -n "$go_ver" ]; then
      if [ -n "$line3" ]; then
        line3="${line3}  │  🐹 Go ${go_ver}"
      else
        line3="│  🐹 Go ${go_ver}"
      fi
    fi
  fi

  if [ -f "${cwd}/package.json" ]; then
    node_ver=$(timeout 1 node -v 2>/dev/null | sed 's/v//')
    if [ -n "$node_ver" ]; then
      if [ -n "$line3" ]; then
        line3="${line3}  │  📦 Node ${node_ver}"
      else
        line3="│  📦 Node ${node_ver}"
      fi
    fi
  fi

  if [ -f "${cwd}/requirements.txt" ] || [ -f "${cwd}/pyproject.toml" ]; then
    python_ver=$(timeout 1 python3 --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [ -n "$python_ver" ]; then
      if [ -n "$line3" ]; then
        line3="${line3}  │  🐍 Python ${python_ver}"
      else
        line3="│  🐍 Python ${python_ver}"
      fi
    fi
  fi

  if [ -f "${cwd}/Cargo.toml" ]; then
    rust_ver=$(timeout 1 rustc --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    if [ -n "$rust_ver" ]; then
      if [ -n "$line3" ]; then
        line3="${line3}  │  🦀 Rust ${rust_ver}"
      else
        line3="│  🦀 Rust ${rust_ver}"
      fi
    fi
  fi
fi

line4=""

transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
start_time=""
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  epoch=$(stat -f %m "$transcript_path" 2>/dev/null)
  if [ -n "$epoch" ]; then
    start_time=$(date -r "$epoch" +%H:%M 2>/dev/null)
  fi
fi

total_duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')
elapsed_display=""
if [ -n "$total_duration_ms" ]; then
  total_sec=$(echo "$total_duration_ms" | awk '{printf "%d", $1/1000}')
  if [ "$total_sec" -ge 3600 ]; then
    hours=$((total_sec / 3600))
    mins=$(((total_sec % 3600) / 60))
    elapsed_display="${hours}h ${mins}m"
  else
    mins=$((total_sec / 60))
    secs=$((total_sec % 60))
    elapsed_display="${mins}m ${secs}s"
  fi

  if [ -z "$start_time" ]; then
    now_epoch=$(date +%s)
    start_epoch=$((now_epoch - total_sec))
    start_time=$(date -r "$start_epoch" +%H:%M 2>/dev/null)
  fi
fi

now_time=$(date +%H:%M)

if [ -n "$start_time" ]; then
  line4="╰─ ⏱ ${start_time}→${now_time}"
  if [ -n "$elapsed_display" ]; then
    line4="${line4} (${elapsed_display})"
  fi
else
  line4="╰─ ⏱ ${now_time}"
  if [ -n "$elapsed_display" ]; then
    line4="${line4} (${elapsed_display})"
  fi
fi

five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_hour_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_day_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

if [ -n "$five_hour_pct" ]; then
  five_pct_fmt=$(printf "%.0f" "$five_hour_pct")
  rate_entry="📊 5h ${five_pct_fmt}%"
  if [ -n "$five_hour_reset" ]; then
    reset_time=$(date -r "$five_hour_reset" +%H:%M 2>/dev/null)
    [ -n "$reset_time" ] && rate_entry="${rate_entry} ↺${reset_time}"
  fi
  line4="${line4}  │  ${rate_entry}"
fi

if [ -n "$seven_day_pct" ]; then
  seven_pct_fmt=$(printf "%.0f" "$seven_day_pct")
  rate_entry="7d ${seven_pct_fmt}%"
  if [ -n "$seven_day_reset" ]; then
    reset_time=$(date -r "$seven_day_reset" +%H:%M 2>/dev/null)
    [ -n "$reset_time" ] && rate_entry="${rate_entry} ↺${reset_time}"
  fi
  line4="${line4}  │  ${rate_entry}"
fi

output=""
[ -n "$line1" ] && output="${line1}"
if [ -n "$output" ]; then
  output="${output}\n${line2}"
else
  output="${line2}"
fi
[ -n "$line3" ] && output="${output}\n${line3}"
[ -n "$line4" ] && output="${output}\n${line4}"

printf "%b\n" "$output"
