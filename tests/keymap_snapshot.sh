#!/bin/bash
# Dump every active keymap in a normalized, order-independent form.
#
# Used to prove that a config refactor changed no mapping:
#
#   bash tests/keymap_snapshot.sh > /tmp/maps-before.txt
#   ...make changes...
#   diff /tmp/maps-before.txt <(bash tests/keymap_snapshot.sh)
#
# Snapshots the config Neovim actually loads (~/.config/nvim, symlinked into
# this repo), not the working tree directly.
#
# Normalized away, because they change between runs and would produce noise:
#   - script-local ids (<SNR>N_) and Lua entry ids (<Lua N:)
#   - the :line suffix of a Lua mapping's source location, so that edits which
#     only shift lines in a file do not register as changed mappings
# Output is sorted because plugin load order is not stable either. `desc`
# continuation lines are excluded; only mode, lhs, and rhs are compared.
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

raw="$(mktemp)"
out="$(mktemp)"
trap 'rm -f "$raw" "$out"' EXIT

if ! nvim --headless \
  -c "redir! > $raw" \
  -c 'silent map' \
  -c 'silent map!' \
  -c 'silent tmap' \
  -c 'redir END' \
  -c 'qa!' >"$out" 2>&1; then
  echo "keymap_snapshot: nvim exited non-zero" >&2
  sed 's/^/  /' "$out" >&2
  exit 1
fi

# The mode column is exactly three characters wide and may be blank (mappings
# that apply to several modes) or multi-character ('nox'). A mapping line has
# a non-space immediately after that column; indented `desc` lines do not.
snapshot="$(grep -E '^.{3}[^ ]' "$raw" \
  | sed -E '
      s/<Lua [0-9]+: (.+):[0-9]+>/<Lua: \1>/g;
      s/<Lua [0-9]+:/<Lua:/g;
      s/<SNR>[0-9]+_/<SNR>_/g;
      s/[[:space:]]+$//' \
  | sort)"

# A config that fails to load is *silent* here: nvim still exits 0, prints
# nothing, and goes on to run its -c commands, so the only evidence is a short
# dump. Without this guard a broken config reads as "no mappings changed".
# <Space>wI comes from config/workspace_info.lua by way of the lazy `ui` spec,
# so it exists only when loading got all the way through plugin setup.
if ! grep -q '<Space>wI' <<<"$snapshot"; then
  {
    echo "keymap_snapshot: the config does not look loaded — sentinel mapping"
    echo "  <Space>wI is absent and only $(wc -l <<<"$snapshot" | tr -d ' ') mappings were found."
    echo "  nvim output:"
    sed 's/^/    /' "$out"
  } >&2
  exit 1
fi

printf '%s\n' "$snapshot"
