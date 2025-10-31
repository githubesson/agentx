typeset -gA __AI_AGENTS_COLORS=(
  [claude]="214"
  [codex]="33"
  [opencode]="51"
  [kimi]="201"
  [crush]="46"
  [cursor]="196"
  [droid]="255"
  [gemini]="39"
  [qwen]="87"
)

typeset -g __AI_AGENTS_BRACKET_COLOR="255"

typeset -g __AI_AGENTS_CURRENT=""
typeset -g __AI_AGENTS_PREFIX_ACTIVE=0
typeset -ga __AI_AGENTS_INSTALLED_CACHE=()
typeset -gA __AI_AGENTS_INSTALLED_MAP=()
typeset -g __AI_AGENTS_MENU_DISPLAY=""
typeset -g __AI_AGENTS_CACHE_VALID=0

setopt nonomatch

__ai_agents_build_cache() {
  emulate -L zsh
  
  __AI_AGENTS_INSTALLED_CACHE=()
  __AI_AGENTS_INSTALLED_MAP=()
  
  [[ -n "${commands[claude]}" ]] && __AI_AGENTS_INSTALLED_CACHE+=(claude) && __AI_AGENTS_INSTALLED_MAP[claude]=1
  [[ -n "${commands[codex]}" ]] && __AI_AGENTS_INSTALLED_CACHE+=(codex) && __AI_AGENTS_INSTALLED_MAP[codex]=1
  [[ -n "${commands[opencode]}" ]] && __AI_AGENTS_INSTALLED_CACHE+=(opencode) && __AI_AGENTS_INSTALLED_MAP[opencode]=1
  [[ -n "${commands[kimi]}" ]] && __AI_AGENTS_INSTALLED_CACHE+=(kimi) && __AI_AGENTS_INSTALLED_MAP[kimi]=1
  [[ -n "${commands[crush]}" ]] && __AI_AGENTS_INSTALLED_CACHE+=(crush) && __AI_AGENTS_INSTALLED_MAP[crush]=1
  [[ -n "${commands[cursor-agent]}" ]] && __AI_AGENTS_INSTALLED_CACHE+=(cursor) && __AI_AGENTS_INSTALLED_MAP[cursor]=1
  [[ -n "${commands[droid]}" ]] && __AI_AGENTS_INSTALLED_CACHE+=(droid) && __AI_AGENTS_INSTALLED_MAP[droid]=1
  [[ -n "${commands[gemini]}" ]] && __AI_AGENTS_INSTALLED_CACHE+=(gemini) && __AI_AGENTS_INSTALLED_MAP[gemini]=1
  [[ -n "${commands[qwen]}" ]] && __AI_AGENTS_INSTALLED_CACHE+=(qwen) && __AI_AGENTS_INSTALLED_MAP[qwen]=1
  
  local agent text_color names_line="" keys_line=""
  
  for agent in claude codex opencode kimi crush cursor droid gemini qwen; do
    if (( ${+__AI_AGENTS_INSTALLED_MAP[$agent]} )); then
      text_color="${__AI_AGENTS_COLORS[$agent]}"
      names_line+=" \033[38;5;${text_color}m$(printf '%-10s' $agent)\033[0m"
    fi
  done
  
  (( ${+__AI_AGENTS_INSTALLED_MAP[claude]} )) && keys_line+=" $(printf '%-10s' c)"
  (( ${+__AI_AGENTS_INSTALLED_MAP[codex]} )) && keys_line+=" $(printf '%-10s' x)"
  (( ${+__AI_AGENTS_INSTALLED_MAP[opencode]} )) && keys_line+=" $(printf '%-10s' o)"
  (( ${+__AI_AGENTS_INSTALLED_MAP[kimi]} )) && keys_line+=" $(printf '%-10s' k)"
  (( ${+__AI_AGENTS_INSTALLED_MAP[crush]} )) && keys_line+=" $(printf '%-10s' r)"
  (( ${+__AI_AGENTS_INSTALLED_MAP[cursor]} )) && keys_line+=" $(printf '%-10s' u)"
  (( ${+__AI_AGENTS_INSTALLED_MAP[droid]} )) && keys_line+=" $(printf '%-10s' d)"
  (( ${+__AI_AGENTS_INSTALLED_MAP[gemini]} )) && keys_line+=" $(printf '%-10s' g)"
  (( ${+__AI_AGENTS_INSTALLED_MAP[qwen]} )) && keys_line+=" $(printf '%-10s' q)"
  
  __AI_AGENTS_MENU_DISPLAY="\n${names_line}\n${keys_line}\n\n"
  __AI_AGENTS_CACHE_VALID=1
}

__ai_agents_highlight_prefix() {
  emulate -L zsh
  
  if (( ! __AI_AGENTS_PREFIX_ACTIVE )) || [[ -z "$__AI_AGENTS_CURRENT" ]]; then
    return
  fi
  
  local prefix_plain="[$__AI_AGENTS_CURRENT] "
  local prefix_len=${#prefix_plain}
  
  if [[ "$BUFFER" == "$prefix_plain"* ]]; then
    local -a new_highlight=()
    local entry
    for entry in "${region_highlight[@]}"; do
      if [[ ! "$entry" =~ "^0 [0-9]+ " ]]; then
        new_highlight+=("$entry")
      fi
    done
    region_highlight=("${new_highlight[@]}")
    
    local text_color="${__AI_AGENTS_COLORS[$__AI_AGENTS_CURRENT]}"
    
    region_highlight+=("0 1 fg=$__AI_AGENTS_BRACKET_COLOR")
    local close_pos=${#__AI_AGENTS_CURRENT}
    (( close_pos++ ))
    region_highlight+=("1 $close_pos fg=$text_color")
    region_highlight+=("$close_pos $((close_pos+1)) fg=$__AI_AGENTS_BRACKET_COLOR")
  fi
}

__ai_agents_menu_widget() {
  emulate -L zsh
  
  if (( __AI_AGENTS_PREFIX_ACTIVE )) && [[ -n "$__AI_AGENTS_CURRENT" ]]; then
    local prefix_plain="[$__AI_AGENTS_CURRENT] "
    local prefix_len=${#prefix_plain}
    if [[ "$BUFFER" == "$prefix_plain"* ]]; then
      BUFFER="${BUFFER#$prefix_plain}"
      if (( CURSOR > prefix_len )); then
        CURSOR=$(( CURSOR - prefix_len ))
      else
        CURSOR=0
      fi
    fi
    __AI_AGENTS_CURRENT=""
    __AI_AGENTS_PREFIX_ACTIVE=0
    zle reset-prompt
    return 0
  fi
  
  if (( ! __AI_AGENTS_CACHE_VALID )); then
    __ai_agents_build_cache
  fi
  
  if (( ${#__AI_AGENTS_INSTALLED_CACHE} == 0 )); then
    print -u2 "\nNo AI agents found"
    zle reset-prompt
    return 1
  fi
  
  print -n "$__AI_AGENTS_MENU_DISPLAY"
  
  typeset -A key_map=(
    [c]="claude"
    [x]="codex"
    [o]="opencode"
    [k]="kimi"
    [r]="crush"
    [u]="cursor"
    [d]="droid"
    [g]="gemini"
    [q]="qwen"
  )
  
  local selection
  read -k 1 selection
  
  local selected_agent="${key_map[$selection]}"
  
  if [[ -z "$selected_agent" ]] || (( ! ${+__AI_AGENTS_INSTALLED_MAP[$selected_agent]} )); then
    zle reset-prompt
    return 1
  fi
  
  if [[ "$__AI_AGENTS_CURRENT" == "$selected_agent" ]] && (( __AI_AGENTS_PREFIX_ACTIVE )); then
    local prefix_plain="[$__AI_AGENTS_CURRENT] "
    local prefix_len=${#prefix_plain}
    if [[ "$BUFFER" == "$prefix_plain"* ]]; then
      BUFFER="${BUFFER#$prefix_plain}"
      if (( CURSOR > prefix_len )); then
        CURSOR=$(( CURSOR - prefix_len ))
      else
        CURSOR=0
      fi
    fi
    __AI_AGENTS_CURRENT=""
    __AI_AGENTS_PREFIX_ACTIVE=0
    zle reset-prompt
    return 0
  fi
  
  if (( __AI_AGENTS_PREFIX_ACTIVE )) && [[ -n "$__AI_AGENTS_CURRENT" ]]; then
    local old_prefix="[$__AI_AGENTS_CURRENT] "
    if [[ "$BUFFER" == "$old_prefix"* ]]; then
      BUFFER="${BUFFER#$old_prefix}"
      if (( CURSOR > ${#old_prefix} )); then
        CURSOR=$(( CURSOR - ${#old_prefix} ))
      else
        CURSOR=0
      fi
    fi
  fi
  
  __AI_AGENTS_CURRENT="$selected_agent"
  __AI_AGENTS_PREFIX_ACTIVE=1
  
  local prefix_plain="[$__AI_AGENTS_CURRENT] "
  BUFFER="${prefix_plain}${BUFFER}"
  CURSOR=${#prefix_plain}
  
  __ai_agents_highlight_prefix
  zle reset-prompt
}

if (( $+functions[command_not_found_handler] )); then
  functions[__ai_agents_original_command_not_found_handler]=$functions[command_not_found_handler]
fi

command_not_found_handler() {
  emulate -L zsh
  
  local missing_command="$1"
  shift
  local -a remaining_args=("$@")
  
  if [[ -z "$missing_command" ]]; then
    if (( $+functions[__ai_agents_original_command_not_found_handler] )); then
      __ai_agents_original_command_not_found_handler "$missing_command" "$@"
      return $?
    fi
    return 127
  fi
  
  if [[ -z "$__AI_AGENTS_CURRENT" ]]; then
    if (( $+functions[__ai_agents_original_command_not_found_handler] )); then
      __ai_agents_original_command_not_found_handler "$missing_command" "$@"
      return $?
    fi
    print -u2 "zsh: command not found: ${missing_command}"
    return 127
  fi
  
  local prefix_plain="[$__AI_AGENTS_CURRENT]"
  
  if [[ "$missing_command" == "$prefix_plain" ]]; then
    local -a effective_cmd=("${remaining_args[@]}")
  elif [[ "$missing_command" == "${prefix_plain}"* ]]; then
    local stripped="${missing_command#$prefix_plain}"
    stripped="${stripped# }"
    if [[ -n "$stripped" ]]; then
      local -a effective_cmd=("$stripped" "${remaining_args[@]}")
    else
      local -a effective_cmd=("${remaining_args[@]}")
    fi
  else
    if (( $+functions[__ai_agents_original_command_not_found_handler] )); then
      __ai_agents_original_command_not_found_handler "$missing_command" "$@"
      return $?
    fi
    print -u2 "zsh: command not found: ${missing_command}"
    return 127
  fi
  
  if (( ${#effective_cmd[@]} == 0 )); then
    print -u2 "agentx: nothing to run"
    return 127
  fi
  
  local agent="$__AI_AGENTS_CURRENT"
  local full_query="${(j: :)effective_cmd}"
  
  case "$agent" in
    claude)
      claude "$full_query" --print --permission-mode=acceptEdits
      ;;
    codex)
      codex exec "$full_query" --ask-for-approval=never
      ;;
    opencode)
      opencode run "$full_query"
      ;;
    kimi)
      kimi -q "$full_query"
      ;;
    crush)
      crush run "$full_query"
      ;;
    cursor)
      cursor-agent "$full_query" -p
      ;;
    droid)
      droid exec --auto=medium "$full_query"
      ;;
    gemini)
      gemini --approval-mode=auto_edit -p "$full_query"
      ;;
    qwen)
      qwen --approval-mode=auto_edit -p "$full_query"
      ;;
  esac
  
  return $?
}

__ai_agents_line_init() {
  emulate -L zsh
  
  if (( __AI_AGENTS_PREFIX_ACTIVE )) && [[ -n "$__AI_AGENTS_CURRENT" ]]; then
    local prefix_plain="[$__AI_AGENTS_CURRENT] "
    BUFFER="${prefix_plain}"
    CURSOR=${#prefix_plain}
    __ai_agents_highlight_prefix
  fi
}

__ai_agents_line_pre_redraw() {
  emulate -L zsh
  
  if (( __AI_AGENTS_PREFIX_ACTIVE )) && [[ -n "$__AI_AGENTS_CURRENT" ]]; then
    local prefix_plain="[$__AI_AGENTS_CURRENT] "
    local prefix_len=${#prefix_plain}
    
    if (( CURSOR < prefix_len )); then
      CURSOR=$prefix_len
    fi
    
    __ai_agents_highlight_prefix
  fi
}

__ai_agents_guard_backward_action() {
  emulate -L zsh
  
  if (( ! __AI_AGENTS_PREFIX_ACTIVE )) || [[ -z "$__AI_AGENTS_CURRENT" ]]; then
    zle ".${WIDGET}"
    return
  fi
  
  local prefix_plain="[$__AI_AGENTS_CURRENT] "
  local prefix_len=${#prefix_plain}
  
  if [[ "$BUFFER" == "$prefix_plain"* ]] && (( CURSOR <= prefix_len )); then
    zle beep 2>/dev/null
    return
  fi
  
  zle ".${WIDGET}"
}

if [[ -o interactive ]]; then
  zle -N __ai_agents_menu_widget
  
  local -a __ai_agents_keymaps=("emacs" "viins")
  local keymap
  for keymap in "${__ai_agents_keymaps[@]}"; do
    bindkey -M "$keymap" '^X' __ai_agents_menu_widget 2>/dev/null
  done
  unset keymap __ai_agents_keymaps
  
  zle -N zle-line-init __ai_agents_line_init
  zle -N zle-line-pre-redraw __ai_agents_line_pre_redraw
  
  zle -N backward-delete-char __ai_agents_guard_backward_action
  zle -N backward-kill-word __ai_agents_guard_backward_action
  zle -N vi-backward-delete-char __ai_agents_guard_backward_action
  zle -N vi-backward-kill-word __ai_agents_guard_backward_action
fi

