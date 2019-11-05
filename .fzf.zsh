# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/petur/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/Users/petur/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/Users/petur/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/Users/petur/.fzf/shell/key-bindings.zsh"
