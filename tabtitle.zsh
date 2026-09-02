autoload -Uz add-zsh-hook

_tt_set() { printf '\e]0;%s\a' "${1//[[:cntrl:]]}" }

_tt_dir() {
  case $PWD in
    $HOME) print -rn -- '~' ;;
    /) print -rn -- '/' ;;
    *) print -rn -- ${PWD:t} ;;
  esac
}

# Directory first so it survives tab truncation; the command is only a hint.
_tt_preexec() {
  local -a words=("${(z)1}")
  while [[ -n ${words[2]} && ${words[1]} == (*=*|sudo|env|command|time|nice|doas) ]]; do
    shift words
  done
  _tt_set "$(_tt_dir) · ${words[1]:t}"
}

_tt_precmd() { _tt_set "$(_tt_dir)" }

add-zsh-hook preexec _tt_preexec
add-zsh-hook precmd  _tt_precmd
