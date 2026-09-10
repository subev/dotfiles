# Tools this config shells out to.
#
#   brew bundle --file=Brewfile     # or: ./install.sh --deps
#
# On macOS, Treesitter parsers and telescope-fzf-native also need a C
# toolchain: xcode-select --install

# Editor
brew "neovim"
brew "ripgrep"      # fzf-lua, blink-ripgrep, search_context
brew "fzf"          # fzf.vim, .fzf.zsh
brew "node"         # custom_functions.lua runs `node -e`
brew "zellij"       # the ,t keymap and the Sidekick scrollback tests

# git — load-bearing, not conveniences. A missing external diff binary makes
# `git diff` fail outright rather than degrade.
brew "git"
brew "difftastic"   # provides `difft`; .gitconfig sets diff.external = difft
brew "git-lfs"      # .gitconfig declares filter.lfs with required = true
brew "gh"           # workflows.sh gitpr(); octo.nvim and gh.nvim

# Shell
brew "fnm"          # node versions; see .zshrc and .bashrc
brew "direnv"       # .zshrc hook
brew "jq"           # workflows.sh
brew "autojump"     # the `jump` shell function
brew "broot"
brew "coreutils"    # gls, used by the `ll` alias
brew "asdf"         # .bash_profile sources asdf.sh
brew "make"         # Treesitter/fzf-native builds; .zshrc adds gnubin to PATH

# Installed for interactive use; nothing in the config invokes them
brew "tmux"         # .tmux.conf is installed as a component
brew "bat"
brew "git-delta"
brew "python3"
