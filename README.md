# dotfiles

My unix environment, versioned since 2013.

- **Neovim** — Lua config (`init.lua`, `lua/`), with its own test suite in `tests/`
  and [workspace/navigation notes](docs/neovim-navigation.md)
- **Shell** — zsh + bash profiles, fzf, ripgrep/ag ignore rules
- **tmux**, **karabiner** keyboard remaps, **ideavim**, **git** config
- **AI agents** — shared personal preferences in `agents/AGENTS.md` for Codex,
  Claude Code, and OpenCode; OpenCode config in `opencode/`

## Setup

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

## Shared AI preferences

Edit [agents/AGENTS.md](agents/AGENTS.md) for personal preferences shared by Codex,
Claude Code (including separate Sidekick sessions), and OpenCode. Keep project
commands and domain-specific workflows in each project's instructions.

All three global instruction files are symlinks to this single source. The old
`opencode/AGENTS.md` path is also a compatibility symlink. Start new agent sessions
after editing preferences so they load the updated instructions.

```bash
mkdir -p "$HOME/.codex" "$HOME/.claude" "$HOME/.config/opencode"
agent_backup_stamp="$(date +%Y%m%d-%H%M%S)"
for agent_target in "$HOME/.codex/AGENTS.md" "$HOME/.claude/CLAUDE.md" "$HOME/.config/opencode/AGENTS.md"; do
  if [ -e "$agent_target" ] || [ -L "$agent_target" ]; then
    if [ "$(readlink "$agent_target")" = "$HOME/dotfiles/agents/AGENTS.md" ]; then
      continue
    fi
    mv "$agent_target" "$agent_target.backup-$agent_backup_stamp"
  fi
  ln -s "$HOME/dotfiles/agents/AGENTS.md" "$agent_target"
done
```

Non-default `CODEX_HOME`, `CLAUDE_CONFIG_DIR`, or `XDG_CONFIG_HOME` installations
need the corresponding global paths adjusted. Model settings, credentials, MCP
configuration, and per-project automatic memories remain tool-specific.

## Claude Code on DeepSeek

`bin/claude-deepseek` runs the normal Claude Code CLI against DeepSeek's
Anthropic-compatible endpoint. Plain `claude` is untouched, and both share
`~/.claude` (plugins, skills, hooks, `CLAUDE.md`).

`~/.local/bin` must be on `PATH`, including for Neovim's Sidekick panes.

```bash
ln -sfn "$HOME/dotfiles/bin/claude-deepseek" "$HOME/.local/bin/claude-deepseek"

mkdir -p "$HOME/.config/deepseek"
install -m 600 /dev/null "$HOME/.config/deepseek/api_key"
$EDITOR "$HOME/.config/deepseek/api_key"  # paste the key; never type it as an argument

claude-deepseek
```

Pasting into an editor keeps the key out of `~/.zsh_history` and out of `ps`.

Key lookup order: `$DEEPSEEK_API_KEY`, then `$DEEPSEEK_API_KEY_FILE`, then the
first line of `~/.config/deepseek/api_key`. `DEEPSEEK_MODEL` and
`DEEPSEEK_SMALL_MODEL` override the model per run; the live ids are listed at
<https://api-docs.deepseek.com/quick_start/pricing> and an unknown one silently
falls back to `deepseek-flash`. In Neovim, `<leader>aN` opens a Sidekick pane on
the `claude_ds` tool.

DeepSeek models are missing from the CLI's model catalog, so the wrapper declares
their real limits (1M context, 32k output per turn) via `CLAUDE_CODE_MAX_CONTEXT_TOKENS`
and `CLAUDE_CODE_MAX_OUTPUT_TOKENS` instead of letting it assume 200k.

What does not carry over: `~/.claude/settings.json` model/effort settings are
Anthropic-specific, thinking budgets and `top_p` are ignored by DeepSeek, and
Anthropic-hosted extras (cloud review, Artifacts, web search, claude.ai
connectors) will not work. Expect an `unrecognized_model` notice on startup.

Revert with `rm "$HOME/.local/bin/claude-deepseek"`.

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
ln -sfn "$HOME/dotfiles/agents/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"
ln -sfn "$HOME/dotfiles/opencode/agents" "$HOME/.config/opencode/agents"
```

Notes:

- Credentials remain in `~/.local/share/opencode/auth.json` (not in git).
- Export `CONTEXT7_API_KEY` in your shell before running OpenCode.
