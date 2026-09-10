# Claude Code on DeepSeek

`bin/claude-deepseek` runs the normal Claude Code CLI against DeepSeek's
Anthropic-compatible endpoint. Plain `claude` is untouched, and both share
`~/.claude` (plugins, skills, hooks, `CLAUDE.md`).

`install.sh` links the wrapper into `~/.local/bin`, which must be on `PATH` —
including for Neovim's Sidekick panes. The API key is the one manual step.

```bash
mkdir -p "$HOME/.config/deepseek"
install -m 600 /dev/null "$HOME/.config/deepseek/api_key"
$EDITOR "$HOME/.config/deepseek/api_key"  # paste the key; never type it as an argument
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
