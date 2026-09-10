#!/bin/bash
# Compare two refs of this repo as Neovim configs: startup time, plus the things
# a keymap diff cannot see — user commands, autocommands, option values,
# highlight groups and loaded plugins.
#
#   bash tests/config_compare.sh master nvim-lua-migration
#   RUNS=9 bash tests/config_compare.sh master HEAD
#
# Each ref is checked out into a throwaway worktree and run against a private
# HOME, so neither this working tree nor the real ~/.config/nvim is touched. The
# plugin cache is shared by symlink so lazy does not re-clone ~110 plugins.
#
# The config's location differs either side of the migration (nvim/ after, repo
# root before), so prepare() builds the right shape per ref, including a private
# ~/dotfiles for the pre-migration absolute `~/dotfiles/vimrc/...` sources.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd -P)"
METRICS="$REPO/tests/config_metrics.lua"
A="${1:?usage: config_compare.sh <ref-a> <ref-b>}"
B="${2:?usage: config_compare.sh <ref-a> <ref-b>}"
RUNS="${RUNS:-5}"
REAL_DATA="$HOME/.local/share"

WORK="$(mktemp -d)"
cleanup() {
  local r
  for r in "$A" "$B"; do
    git -C "$REPO" worktree remove --force "$WORK/wt-$r" >/dev/null 2>&1 || true
  done
  rm -rf "$WORK"
}
trap cleanup EXIT

prepare() {
  local ref="$1" wt="$WORK/wt-$1" home="$WORK/home-$1" f
  git -C "$REPO" worktree add --detach --quiet "$wt" "$ref"
  mkdir -p "$home/.config" "$home/.local"
  ln -sfn "$wt" "$home/dotfiles"
  ln -sfn "$REAL_DATA" "$home/.local/share"
  # Pre-migration specs point at ~/repos/<name> directly; without this the
  # isolated HOME cannot see them and those plugins silently do not load,
  # which would read as "the branch added commands" rather than an artefact.
  [[ -d "$HOME/repos" ]] && ln -sfn "$HOME/repos" "$home/repos"

  if [[ -d "$wt/nvim" ]]; then
    ln -sfn "$wt/nvim" "$home/.config/nvim"
  else
    mkdir -p "$home/.config/nvim"
    for f in init.lua lua queries snippets lazy-lock.json .luarc.json; do
      [[ -e "$wt/$f" ]] && ln -sfn "$wt/$f" "$home/.config/nvim/$f"
    done
  fi
}

median() { sort -n | awk '{v[NR]=$1} END{print v[int((NR+1)/2)]}'; }

nvim_startup_ms() {
  local home="$1" i times=()
  for ((i = 1; i <= RUNS; i++)); do
    env "HOME=$home" "XDG_CONFIG_HOME=$home/.config" \
      nvim --headless --startuptime "$WORK/st" -c 'qa!' >/dev/null 2>&1
    times+=("$(awk '/NVIM STARTED/{print $1}' "$WORK/st")")
  done
  printf '%s\n' "${times[@]}" | median
}

# Timed in one process so the timer itself is not part of the measurement.
zsh_startup_ms() {
  python3 - "$1" "$RUNS" <<'PY'
import os, statistics, subprocess, sys, time
zdotdir, runs = sys.argv[1], int(sys.argv[2])
env = dict(os.environ, ZDOTDIR=zdotdir)
times = []
for _ in range(runs):
    start = time.perf_counter()
    subprocess.run(["zsh", "-ic", "exit"], env=env,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    times.append((time.perf_counter() - start) * 1000)
print(int(statistics.median(times)))
PY
}

for ref in "$A" "$B"; do
  prepare "$ref"
done

printf 'ref A = %s   ref B = %s   (%s runs each)\n\n' "$A" "$B" "$RUNS"

for ref in "$A" "$B"; do
  home="$WORK/home-$ref"
  CONFIG_METRICS_OUT="$WORK/metrics-$ref" \
    env "HOME=$home" "XDG_CONFIG_HOME=$home/.config" \
    nvim --headless -c "luafile $METRICS" -c 'qa!' >/dev/null 2>&1
  nvim_startup_ms "$home" >"$WORK/nvim-ms-$ref"
  zsh_startup_ms "$WORK/wt-$ref" >"$WORK/zsh-ms-$ref"
done

printf '%-22s %-14s %-18s %-18s\n' METRIC "$A" "$B" ""
printf '%-22s %-14s %-18s %-18s\n' "----------------------" "--------------" "------------------" "------------------"
printf '%-22s %-14s %-18s %-18s\n' "nvim start (ms)" "$(cat "$WORK/nvim-ms-$A")" "$(cat "$WORK/nvim-ms-$B")" ""
printf '%-22s %-14s %-18s %-18s\n' "zsh start (ms)" "$(cat "$WORK/zsh-ms-$A")" "$(cat "$WORK/zsh-ms-$B")" ""

paste -d'|' <(sort "$WORK/metrics-$A") <(sort "$WORK/metrics-$B") |
  while IFS='|' read -r la lb; do
    key="${la%%=*}"
    va="${la#*=}"
    vb="${lb#*=}"
    # Hashes are 64 chars; show a prefix so a mismatch is still eyeballable.
    [[ ${#va} -gt 18 ]] && va="${va:0:16}…"
    [[ ${#vb} -gt 18 ]] && vb="${vb:0:16}…"
    if [[ "${la#*=}" == "${lb#*=}" ]]; then
      printf '%-22s %-14s %-18s %s\n' "$key" "$va" "$vb" "same"
    else
      printf '%-22s %-14s %-18s %s\n' "$key" "$va" "$vb" "DIFF"
    fi
  done
