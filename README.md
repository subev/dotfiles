# dotfiles

My unix environment, versioned since 2013: Neovim (Lua), zsh/bash, tmux, git,
karabiner, IdeaVim, and shared AI-agent preferences.

## Setup

Clone to `~/dotfiles` — `.zshrc` sources its helper modules from that exact path.

```bash
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

The wizard symlinks everything into `$HOME` and offers to install the tools
listed in `Brewfile` (Homebrew, or `apt` on Debian/Ubuntu). Non-interactively:

```bash
./install.sh --all --deps   # everything, no prompts
./install.sh --check        # report drift and missing tools, change nothing
./install.sh --dry-run      # show intended actions
```

It is idempotent, and anything already in the way is moved to
`~/.dotfiles-backup-<timestamp>/`, never overwritten.

`karabiner.json` is not linked: Karabiner-Elements rewrites that file, so the copy
here is a seed, not a source of truth.

Plugins are managed by lazy.nvim. `lazy-lock.json`, `snippets/`, and `queries/` live
in `nvim/` and are tracked, so a fresh clone reproduces the same plugin revisions.
Two plugins (`sibling-jump.nvim`, `difftastic.nvim`) load from a local checkout under
`~/repos/` when one exists, and from GitHub otherwise.

## Notes

- Agent preferences are edited in [agents/AGENTS.md](agents/AGENTS.md), the single
  source symlinked to Codex, Claude Code, and OpenCode.
- OpenCode needs `CONTEXT7_API_KEY` exported in your shell; its MCP server is
  silently broken without it.
- Claude Code on DeepSeek: [docs/claude-deepseek.md](docs/claude-deepseek.md)
- Neovim navigation notes: [docs/neovim-navigation.md](docs/neovim-navigation.md)
- Tests: `bash tests/test_runner.sh`
