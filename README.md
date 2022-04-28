# dotfiles

========

unix settings

```bash
brew install coreutils python3 grip jq ripgrep git-delta autojump bat thefuck nvm
brew install nvim --head

pip3 install --user neovim

ln -s "$HOME/dotfiles/.bashrc" "$HOME/.bashrc"

ln -s "$HOME/dotfiles/.zshrc" "$HOME/.zshrc"

ln -s "$HOME/dotfiles/.fzf.zsh" "$HOME/.fzf.zsh"

ln -s "$HOME/dotfiles/.bash_profile" "$HOME/.bash_profile"

ln -s "$HOME/dotfiles/.tmux.conf" "$HOME/.tmux.conf"

ln -s "$HOME/dotfiles/.gitconfig" "$HOME/.gitconfig"

ln -s "$HOME/dotfiles/.vimrc" "$HOME/.vimrc"

ln -s "$HOME/dotfiles/.gvimrc" "$HOME/.gvimrc"

ln -s "$HOME/dotfiles/.inputrc" "$HOME/.inputrc"

ln -s "$HOME/dotfiles/.screenrc" "$HOME/.screenrc"

ln -s "$HOME/dotfiles/.agignore" "$HOME/.agignore"

ln -s "$HOME/dotfiles/.agignore" "$HOME/.rgignore"

mkdir -p ~/.config/nvim/

ln -s "$HOME/dotfiles/.vimrc" "$HOME/.config/nvim/init.vim"

ln -s "$HOME/dotfiles/coc-settings.json" "$HOME/.config/nvim/coc-settings.json"

ln -s "$HOME/dotfiles/karabiner.json" "$HOME/.config/karabiner/karabiner.json"

ln -s "$HOME/dotfiles/.ideavimrc" "$HOME/.ideavimrc"

mkdir -p ~/.config/bat/themes/

ln -s "$HOME/dotfiles/gruvbox.tmTheme" "$HOME/.config/bat/themes/gruvbox.tmTheme"

ln -s "$HOME/dotfiles/ultisnips/" "$HOME/.config/coc/"

# tree-sitter for neovim
mkdir -p ~/.local/share/nvim/site/pack/nvim-treesitter/start
cd ~/.local/share/nvim/site/pack/nvim-treesitter/start
git clone https://github.com/nvim-treesitter/nvim-treesitter.git
```
