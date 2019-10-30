# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/petur/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/Users/petur/.fzf/bin"
  export FZF_DEFAULT_OPTS='--height 80% --border --layout=reverse --preview "bat --color=always --line-range :100 {}"'
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/Users/petur/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/Users/petur/.fzf/shell/key-bindings.zsh"
