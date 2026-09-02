zmodload zsh/datetime
autoload -Uz add-zsh-hook

typeset -ga _th_cmd _th_at _th_dur
typeset -gi _TH_MAX=2000

_th_preexec() { _th_cmd+=("$1"); _th_at+=($EPOCHREALTIME); _th_dur+=(-1) }

_th_precmd() {
  local -i i=$#_th_cmd
  (( i )) || return
  (( _th_dur[i] < 0 )) && _th_dur[i]=$(( EPOCHREALTIME - _th_at[i] ))
  if (( i > _TH_MAX )); then
    _th_cmd=("${_th_cmd[@]: -_TH_MAX}")
    _th_at=("${_th_at[@]: -_TH_MAX}")
    _th_dur=("${_th_dur[@]: -_TH_MAX}")
  fi
}

add-zsh-hook preexec _th_preexec
add-zsh-hook precmd  _th_precmd

_th_fmt() {
  local -F d=$1
  local -i s=$(( int(d) ))
  if (( d < 60 )); then
    printf '%.2fs' $d
  elif (( s < 3600 )); then
    printf '%dm%02ds' $(( s / 60 )) $(( s % 60 ))
  else
    printf '%dh%02dm' $(( s / 3600 )) $(( (s % 3600) / 60 ))
  fi
}

# this tab only, with wall-clock duration; share_history makes fc -l useless for this
th() {
  local -i n=${1:-30} i start=1
  (( $#_th_cmd )) || { print -u2 "th: nothing run in this tab yet"; return 1 }
  (( start = $#_th_cmd - n + 1 )); (( start < 1 )) && start=1
  for (( i = start; i <= $#_th_cmd; i++ )); do
    (( _th_dur[i] < 0 )) && continue
    printf '%s  %9s  %s\n' \
      "$(strftime '%H:%M:%S' ${_th_at[i]%%.*})" \
      "$(_th_fmt ${_th_dur[i]})" \
      "${_th_cmd[i]}"
  done
}
