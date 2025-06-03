# ------------------------------------------------------------------------------
# fzf-ai-tools.zsh - AI-enhanced shell tools using fzf and aichat
# ------------------------------------------------------------------------------

# Dependency check
missing=()
command -v fzf >/dev/null 2>&1 || missing+=("fzf (https://github.com/junegunn/fzf)")
command -v aichat >/dev/null 2>&1 || missing+=("aichat (https://github.com/sigoden/aichat)")

if (( ${#missing[@]} > 0 )); then
  echo "[fzf-ai-tools] Missing required dependencies:"
  for dep in "${missing[@]}"; do
    echo "  - $dep"
  done
  echo "Please install the missing tools and restart your shell."
  return 1
fi

# Helper functions for common patterns
_fzf_ai_display_result() {
  local title="$1"
  local cache_file="$2"
  local query="$3"
  local prompt="$4"

  echo
  echo "$title"
  echo "$(printf '%.0s-' {1..50})"

  if [[ -f "$cache_file" ]] && [[ "$(head -n1 "$cache_file")" = "$query" ]]; then
    tail -n +2 "$cache_file"
  else
    aichat "$prompt $query" | fmt -w ${COLUMNS:-80}
  fi
  echo
}

_fzf_ai_create_preview() {
  local cache_file="$1"
  local extract_cmd="$2"
  local prompt="$3"

  cat << EOF
    query=\$($extract_cmd)
    cache_file="$cache_file"
    if [ -f "\$cache_file" ] && [ "\$(head -n1 "\$cache_file")" = "\$query" ]; then
      tail -n +2 "\$cache_file"
    else
      response=\$(aichat "$prompt \$query" | fmt -w \${FZF_PREVIEW_COLUMNS:-80})
      echo "\$query" > "\$cache_file"
      echo "\$response" >> "\$cache_file"
      echo "\$response"
    fi
EOF
}

# Tool functions
fzf-ai-history() {
  local _selected _cmd _cache_file
  _cache_file="/tmp/fzf-ai-history-$$"

  _selected=$(history | fzf --preview "$(_fzf_ai_create_preview "$_cache_file" "echo {} | sed 's/^ *[0-9]* *//'" "Tersely and concisely explain this cli command:")" ) || { rm -f "$_cache_file"; return; }

  _cmd=$(echo "$_selected" | sed 's/^ *[0-9]* *//')
  [[ -n "$_cmd" ]] && _fzf_ai_display_result "Command: $_cmd" "$_cache_file" "$_cmd" "Tersely and concisely explain this cli command:"
  rm -f "$_cache_file"
}

fzf-ai-aliases() {
  local _selected _alias _expansion _cache_file
  _cache_file="/tmp/fzf-ai-aliases-$$"

  _selected=$(alias | fzf --preview "$(_fzf_ai_create_preview "$_cache_file" "echo {} | cut -d'=' -f2 | tr -d \"'\"" "Tersely and concisely explain this shell command:")" ) || { rm -f "$_cache_file"; return; }

  if [[ -n "$_selected" ]]; then
    _alias=$(echo "$_selected" | cut -d'=' -f1)
    _expansion=$(echo "$_selected" | cut -d'=' -f2 | tr -d "'")
    _fzf_ai_display_result "Alias: $_alias -> $_expansion" "$_cache_file" "$_expansion" "Tersely and concisely explain this shell command:"
  fi
  rm -f "$_cache_file"
}

fzf-ai-files() {
  local _selected _cache_file
  _cache_file="/tmp/fzf-ai-files-$$"

  _selected=$(find . -type f -not -path '*/\.*' | fzf --preview "
    cache_file=\"$_cache_file\"
    if [ -f \"\$cache_file\" ] && [ \"\$(head -n1 \"\$cache_file\")\" = \"{}\" ]; then
      tail -n +2 \"\$cache_file\"
    else
      response=\$(head -n 100 '{}' | aichat 'Tersely and concisely explain the file content:' | fmt -w \${FZF_PREVIEW_COLUMNS:-80})
      echo '{}' > \"\$cache_file\"
      echo \"\$response\" >> \"\$cache_file\"
      echo \"\$response\"
    fi
  ") || { rm -f "$_cache_file"; return; }

  if [[ -n "$_selected" ]]; then
    echo
    echo "File: $_selected"
    echo "$(printf '%.0s-' {1..50})"
    if [[ -f "$_cache_file" ]] && [[ "$(head -n1 "$_cache_file")" = "$_selected" ]]; then
      tail -n +2 "$_cache_file"
    else
      head -n 100 "$_selected" | aichat 'Tersely and concisely explain the file content:' | fmt -w ${COLUMNS:-80}
    fi
    echo
  fi
  rm -f "$_cache_file"
}

fzf-ai-input() {
  local _out _query _cache_dir _query_hash _placeholder _answer_cache
  _cache_dir="/tmp/fzf-ai-input-$$"
  mkdir -p "$_cache_dir"
  _placeholder="[ Press ENTER to accept query ]"

  _out=$(printf "%s\n" "$_placeholder" | fzf --phony --print-query --no-sort --preview-window=wrap --preview "
    q=\"{q}\"
    cache_dir=\"$_cache_dir\"
    echo \"Query: \$q\"
    echo \"\"
    if [ -n \"\$q\" ] && [ \${#q} -gt 2 ]; then
      query_hash=\$(echo \"\$q\" | cksum | cut -d' ' -f1)
      preview_cache=\"\$cache_dir/i_\$query_hash\"
      if [ -f \"\$preview_cache\" ]; then
        cat \"\$preview_cache\"
      else
        response=\$(aichat \"Tersely and concisely restate what the user is asking (do NOT answer): \$q\" | fmt -w \${FZF_PREVIEW_COLUMNS:-80})
        echo \"\$response\" > \"\$preview_cache\"
        echo \"\$response\"
      fi
    else
      echo \"Start typing your question above (3+ characters) to see AI interpretation...\"
    fi
  ") || { rm -rf "$_cache_dir"; return; }

  _query=$(echo "$_out" | head -n1)
  if [[ -n "$_query" ]]; then
    echo
    echo "Query: $_query"
    echo "$(printf '%.0s-' {1..50})"

    _query_hash=$(echo "$_query" | cksum | cut -d' ' -f1)
    _answer_cache="$_cache_dir/a_$_query_hash"

    if [[ -f "$_answer_cache" ]]; then
      cat "$_answer_cache"
    else
      aichat "Tersely and concisely explain: $_query" | fmt -w ${COLUMNS:-80} | tee "$_answer_cache"
    fi
    echo
  fi
  rm -rf "$_cache_dir"
}

# Aliases
alias ai:h='fzf-ai-history'
alias ai:a='fzf-ai-aliases'
alias ai:f='fzf-ai-files'
alias ai:i='fzf-ai-input'
