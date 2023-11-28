# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/petur/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/Users/petur/.fzf/bin"
fi

# Auto-completion
# ---------------
source "/Users/petur/.fzf/shell/completion.zsh"

# Key bindings
# ------------
source "/Users/petur/.fzf/shell/key-bindings.zsh"
