# dotfiles

========

unix settings

```bash
brew install coreutils python3 grip jq ripgrep git-delta autojump bat thefuck nvm
brew install nvim --head

pip3 install --user neovim

npm i -g neovim

ln -s "$HOME/dotfiles/.bashrc" "$HOME/.bashrc"

ln -s "$HOME/dotfiles/.zshrc" "$HOME/.zshrc"

ln -s "$HOME/dotfiles/.fzf.zsh" "$HOME/.fzf.zsh"

ln -s "$HOME/dotfiles/.bash_profile" "$HOME/.bash_profile"

ln -s "$HOME/dotfiles/.tmux.conf" "$HOME/.tmux.conf"

ln -s "$HOME/dotfiles/.gitconfig" "$HOME/.gitconfig"

ln -s "$HOME/dotfiles/.gvimrc" "$HOME/.gvimrc"

ln -s "$HOME/dotfiles/.inputrc" "$HOME/.inputrc"

ln -s "$HOME/dotfiles/.screenrc" "$HOME/.screenrc"

ln -s "$HOME/dotfiles/.agignore" "$HOME/.agignore"

ln -s "$HOME/dotfiles/.agignore" "$HOME/.rgignore"

mkdir -p ~/.config/nvim/

ln -s "$HOME/dotfiles/init.lua" "$HOME/.config/nvim/init.lua"

ln -s "$HOME/dotfiles/.luarc.json" "$HOME/.config/nvim/.luarc.json"

ln -s "$HOME/dotfiles/coc-settings.json" "$HOME/.config/nvim/coc-settings.json"

ln -s "$HOME/dotfiles/karabiner.json" "$HOME/.config/karabiner/karabiner.json"

ln -s "$HOME/dotfiles/.ideavimrc" "$HOME/.ideavimrc"

mkdir -p ~/.config/bat/themes/

ln -s "$HOME/dotfiles/gruvbox.tmTheme" "$HOME/.config/bat/themes/gruvbox.tmTheme"

ln -s "$HOME/dotfiles/ultisnips/" "$HOME/.config/coc/"

for f in ~/dotfiles/lua/*; do ln -s "$f" ~/.config/nvim/lua; done

# tree-sitter for neovim
mkdir -p ~/.local/share/nvim/site/pack/nvim-treesitter/start
cd ~/.local/share/nvim/site/pack/nvim-treesitter/start
git clone https://github.com/nvim-treesitter/nvim-treesitter.git

git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

:PackerInstall
```

## OpenCode setup

Keep OpenCode config in this repo and symlink it into `~/.config/opencode`.

```bash
mkdir -p "$HOME/.config/opencode"

# backup existing files once
ts="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$HOME/.config/opencode/backup-$ts"
cp -v "$HOME/.config/opencode/opencode.json" "$HOME/.config/opencode/backup-$ts/" 2>/dev/null || true
cp -v "$HOME/.config/opencode/AGENTS.md" "$HOME/.config/opencode/backup-$ts/" 2>/dev/null || true

ln -sfn "$HOME/dotfiles/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"
ln -sfn "$HOME/dotfiles/opencode/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"
ln -sfn "$HOME/dotfiles/opencode/agents" "$HOME/.config/opencode/agents"
```

Notes:
- Credentials remain in `~/.local/share/opencode/auth.json` (not in git).
- Export `CONTEXT7_API_KEY` in your shell before running OpenCode.
