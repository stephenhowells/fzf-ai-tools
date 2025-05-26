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

# Tool functions
fzf-ai-history() {
  local _selected _cmd
  # Interactive picker with live AI preview
  _selected=$(history | fzf --no-clear --preview "echo {} | sed 's/^ *[0-9]* *//' | xargs -I % sh -c 'aichat \"Tersely and concisely explain this cli command: %\" | fmt -w ${FZF_PREVIEW_COLUMNS:-80}'") || return

  # Print explanation again after the picker so it is easy to copy
  _cmd=$(echo "$_selected" | sed 's/^ *[0-9]* *//')
  [[ -n "$_cmd" ]] && aichat "Tersely and concisely explain this cli command: $_cmd" | fmt -w ${COLUMNS:-80}
}

fzf-ai-aliases() {
  local _selected _expansion
  _selected=$(alias | fzf --no-clear --preview "echo {} | cut -d'=' -f2 | tr -d \"'\" | xargs -I % sh -c 'aichat \"The following text is a shell alias definition. On the left side of the '=' sign is the alias. On the right side is the cli command. Tersely and concisely explain what the cli command will do in the shell: %\" | fmt -w ${FZF_PREVIEW_COLUMNS:-80}'") || return

  _expansion=$(echo "$_selected" | cut -d'=' -f2 | tr -d "'")
  [[ -n "$_expansion" ]] && aichat "The following text is a shell alias definition. On the left side of the '=' sign is the alias. On the right side is the cli command. Tersely and concisely explain what the cli command will do in the shell: $_expansion" | fmt -w ${COLUMNS:-80}
}

fzf-ai-files() {
  local _selected
  _selected=$(find . -type f -not -path '*/\.*' | fzf --no-clear --preview "head -n 100 {} | aichat 'Tersely and concisely explain the file content:' | fmt -w ${FZF_PREVIEW_COLUMNS:-80}") || return

  [[ -n "$_selected" ]] && head -n 100 "$_selected" | aichat 'Tersely and concisely explain the file content:' | fmt -w ${COLUMNS:-80}
}

fzf-ai-input() {
  local _out _query
  _out=$(echo "" | fzf --print-query --no-sort --preview-window=wrap --no-clear --preview 'sh -c '\''q="$1"; if [ -z "$q" ]; then echo "Type a question or comment to get started."; else aichat "Tersely and concisely explain: $q" | fmt -w ${FZF_PREVIEW_COLUMNS:-80}; fi'\'' _ {q}') || return

  _query=$(echo "$_out" | head -n1)
  if [[ -n "$_query" ]]; then
    BUFFER="$_query"
    zle reset-prompt
    echo
    aichat "Tersely and concisely explain: $_query" | fmt -w ${COLUMNS:-80}
  fi
}

# Only register ZLE widget in interactive shells
if [[ -o interactive ]]; then
  # Ensure ZLE is available
  if [[ -n "${ZLE_VERSION:-}" ]] || zmodload zsh/zle 2>/dev/null; then
    zle -N fzf-ai-input

    # Optional keybinding
    if [[ -z "${FZF_AI_TOOLS_BINDKEY}" ]]; then
      FZF_AI_TOOLS_BINDKEY='^A'
    fi

    if [[ "${FZF_AI_TOOLS_BINDKEY}" != "none" ]]; then
      bindkey "${FZF_AI_TOOLS_BINDKEY}" fzf-ai-input
    fi
  fi
fi

# Aliases
alias ai:h='fzf-ai-history'
alias ai:a='fzf-ai-aliases'
alias ai:f='fzf-ai-files'
alias ai:i='fzf-ai-input'
