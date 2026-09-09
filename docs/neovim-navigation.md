# Workspace information and AI file references

Investigated on 2026-09-09 against the installed Neovim 0.13 development build,
Sidekick, Zellij 0.44.1, and the Libratory project.

## Implemented: workspace information

The Lualine statusline uses a folder glyph, nvim-web-devicons file icons, and a
gear for attached language servers. It removes the repeated filetype text,
full mode name, diff counters, and progress percentage. Directory components
use up to four consonants (`packages/server` becomes `pckg/srvr`); short names
such as `src` and `lib`, and the filename itself, remain readable.

Each split uses its own width, including inactive code splits:

| Split width | Display |
| --- | --- |
| 180+ columns | Directory, abbreviated file path, server names and native TS version |
| 100–179 | Directory, abbreviated file path, server names; overflow becomes `+N` |
| 80–99 | Directory, filename, compact server list |
| 40–79 | Filename with devicon, abbreviated server list; `TS7` identifies native TS |
| 20–39 | Filename and attached-server count; line number only when it fits |
| Under 20 | Filename only |

The filename gets the remaining space after the other components are measured
in screen cells. ` 0` means no server is attached to an ordinary file buffer;
special buffers omit that indicator. Full information remains in the popup.

Click either component, press `Space wI`, or run `:WorkspaceInfo` for the full
directory paths, window/tab/global directory scope, filetype, attached server
versions and roots, workspace folders, and other running clients. TypeScript
launchers record their resolved executable and arguments, so the popup shows
the actual command. Other function-based servers report a custom launcher.

`:LspInfo` is restored as an alias for `:checkhealth vim.lsp`. The installed
`nvim-lspconfig/plugin/lspconfig.lua` returns early when the native `:lsp` command
exists, so it no longer creates the old command on this Neovim build.

Verified with headless Neovim: window-local directories, inactive split context,
the details window, commands, Lualine integration, and the live native TypeScript
7.0.2 server attached to Libratory. Restart Neovim to load the changes.

## TypeScript server selection

The nearest project installation wins: `tsc` 7+ or native-preview's `tsgo` uses
native LSP; a legacy compiler or no local compiler uses Mason's `ts_ls` fallback.
Package-local installations take precedence over workspace installations. Deno
exclusion follows the installed nvim-lspconfig root callback.

Version probes run asynchronously and concurrent checks share the same process.
Successful version checks are cached against executable identity and file
metadata; missing binaries and failed probes are retried. Installing a compiler
or replacing it is detected on the next root check. Already attached servers
still need restarting to switch engines; restarting Neovim is not required.
The native launcher rejects roots that have not passed native selection.

## Implemented: Sidekick file references

- **Ctrl-click** a reference in the AI pane in either terminal-input mode or
  normal mode after `Esc Esc`. This also works while the code pane has focus.
- **`gf`** on the reference in Sidekick normal mode performs the same action.
- The existing code window is reused; folds are opened and the target line is
  positioned at the top with the window's `scrolloff` context above it. The cited
  lines are highlighted until the cursor moves or the text changes.
- Ordinary clicks, dragging, and scrolling retain their normal behavior.
- Relative paths use the Sidekick session's directory. Abbreviated basenames
  are searched asynchronously with ripgrep; ambiguous matches prompt for a choice.
  Wrapped alternatives share one search. Missing ripgrep or a failed search gives
  a notification, and bare filenames open without highlighting an invented range.
- Supported forms include `path:line`, `path:line:column`, hyphen/en-dash/em-dash
  ranges, `path#L105-L141`, file URIs, and quoted paths with spaces. Terminal
  rows that wrap a path are joined before parsing. Missing files are not created.

The mouse press is captured before leaving terminal mode, and its release is
consumed so it cannot be delivered to the AI process after focus changes.
The handler is global for Ctrl-click (to support an inactive AI pane), but only
handles references in Sidekick windows. `gf` is buffer-local to Sidekick.

Verified in an isolated Neovim UI with the actual Sidekick/Zellij backend and
synthetic AI output: both mouse modes, clicks from the inactive pane, `gf`,
scrolling a long transcript before clicking an old reference, exact columns,
range highlighting, and preservation of unsaved text. Statuslines were also
rendered at 20–180 columns with three attached-server entries and in four
simultaneous vertical splits.

Run the statement navigation, Sidekick/workspace, and TypeScript selection
suites together from the dotfiles root:

```sh
bash tests/test_runner.sh
```

## Existing navigation outside Sidekick

Neovim already provides `gF` and `Ctrl-W F` to open a filename and jump to a
following line number. Your `vimrc/keybindings.vim` maps lowercase `gf` to
`Ctrl-W F` followed by moving the new split to the far left.
Your config also removes `:` from `isfname`, which supports this workflow.
See [Neovim's file navigation documentation](https://neovim.io/doc/user/editing/#gF).

That global mapping is unchanged outside Sidekick.

Correction to the initial investigation: Sidekick contains a separate scrollback
implementation, but its **installed Zellij backend has `dump()` commented out**,
so that separate buffer is not active here. After `Esc Esc`, Neovim can read the
currently rendered Zellij terminal text directly. Older history is still
scrolled through Zellij in terminal-input mode; the new handler does not change
that behavior. See [Sidekick's Zellij backend](https://github.com/folke/sidekick.nvim/blob/main/lua/sidekick/cli/session/zellij.lua).

## Options investigated

### Zellij's built-in file links

Zellij 0.44 introduced a built-in `link` plugin: Alt-clicking a recognized path
opens the default editor in a new floating pane. It is useful when Zellij owns
the whole workspace, but its default destination does not match this workflow's
existing Neovim code pane. Nested terminal mouse handling also needs to be
accounted for. I did not change the Zellij configuration or test its mouse
behavior in a live AI session.

Source: [Zellij 0.44 release notes](https://github.com/zellij-org/zellij/releases/tag/v0.44.0).

### Pathfinder: the closest existing plugin

[Pathfinder](https://github.com/hawkinst/pathfinder.nvim) offers `gf`/`gF`
enhancements, visible-reference keyboard labels, terminal hard-wrap handling,
line/column navigation, existing-window reuse, and a custom opening callback.
Its external multiplexer integration is for tmux; the Neovim terminal buffer
containing Sidekick is the relevant integration point for this Zellij setup.

Downloaded and tested commit `9c79815` in `/tmp`, without installing it.
The tests used real Libratory paths and captured the opening callback:

| Reference suffix | Result |
| --- | --- |
| `:105-141` | File and line 105; range end discarded |
| `:105–141` | File and line 105; range end discarded |
| `:105:8` | File, line 105, column 8 |
| `#L105-L141` | No valid target found |

The callback only receives filename, starting line, and column. Range parsing
and highlighting would need additional integration. These are parser/opening
tests, not an end-to-end test of clicking through a live Sidekick session.

### open.nvim

Inspected [open.nvim](https://github.com/StefanBartl/open.nvim) at commit
`6fef2e7`. It primarily dispatches paths and URLs to applications, splits, and
link viewers, with an additional `lib.nvim` dependency. Its documented features
do not provide this exact Sidekick reference-range workflow, so it is a less
direct fit than Pathfinder.

## Possible later extension

A reference picker with previews remains an optional extension. Existing
Telescope or fzf-lua could supply it. The implemented workflow is Ctrl-click
and `gf`; no additional navigation plugin is installed.
