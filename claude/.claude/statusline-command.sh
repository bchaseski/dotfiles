#!/usr/bin/env bash
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

dir=$(basename "$cwd")

parts=()

[ -n "$dir" ] && parts+=("$(printf '\033[34m%s\033[0m' "$dir")")
[ -n "$model" ] && parts+=("$(printf '\033[33m%s\033[0m' "$model")")
[ -n "$used" ] && parts+=("$(printf '\033[32mctx: %s%%\033[0m' "$(printf '%.0f' "$used")")")

printf '%s' "$(IFS=' | '; echo "${parts[*]}")"
