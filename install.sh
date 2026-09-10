#!/usr/bin/env bash
#
# Links this repo's tracked files into $HOME. Idempotent: re-running only
# touches links that are missing or wrong, and never destroys a file it finds
# in the way (it moves it into a timestamped backup directory instead).
#
#   ./install.sh                    interactive wizard
#   ./install.sh --all              install every component
#   ./install.sh --only nvim,shell  install selected components
#   ./install.sh --check            report drift and exit 1 if any is found
#   ./install.sh --dry-run          show what would change, change nothing
#
set -euo pipefail

# pwd -P: a symlinked path to this repo must resolve to the same $DOTFILES,
# or the idempotency check compares two spellings of the same file.
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
BACKUP_ROOT="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
BACKUP_USED=0
DRY_RUN=0
CHECK_ONLY=0
ONLY=""

LINKED=0
SKIPPED=0
PROBLEMS=0
ORPHANS=0
TOOLS_MISSING=0
DEPS_WANTED=0

# Tools the config shells out to, by binary name. Kept separate from PROBLEMS:
# a missing convenience like broot is not link drift, and `--check` should say
# which of the two it found.
DEP_TOOLS=(rg fzf git difft git-lfs gh nvim node tmux zellij fnm direnv jq autojump broot make)

have() { command -v "$1" >/dev/null 2>&1; }

if [[ -t 1 ]]; then
  C_DIM=$'\033[2m'; C_OK=$'\033[32m'; C_WARN=$'\033[33m'; C_ERR=$'\033[31m'; C_OFF=$'\033[0m'
else
  C_DIM=""; C_OK=""; C_WARN=""; C_ERR=""; C_OFF=""
fi

COMPONENTS=(shell nvim tmux git ignore agents opencode bat ideavim bin)

describe() {
  case "$1" in
    shell)    echo "zsh + bash profiles, fzf, readline, screen" ;;
    nvim)     echo "Neovim config (init.lua, lua/, lockfile, snippets, queries)" ;;
    tmux)     echo "tmux config" ;;
    git)      echo "git config" ;;
    ignore)   echo "ripgrep / ag ignore rules" ;;
    agents)   echo "shared AGENTS.md for Codex, Claude Code, OpenCode" ;;
    opencode) echo "OpenCode config and agents" ;;
    bat)      echo "gruvbox theme for bat" ;;
    ideavim)  echo "JetBrains IdeaVim config" ;;
    bin)      echo "claude-deepseek wrapper on PATH" ;;
  esac
}

# Emits "source|target" pairs for a component.
component_links() {
  case "$1" in
    shell) cat <<EOF
$DOTFILES/.zshrc|$HOME/.zshrc
$DOTFILES/.bashrc|$HOME/.bashrc
$DOTFILES/.bash_profile|$HOME/.bash_profile
$DOTFILES/.fzf.zsh|$HOME/.fzf.zsh
$DOTFILES/.inputrc|$HOME/.inputrc
$DOTFILES/.screenrc|$HOME/.screenrc
EOF
      ;;
    # One link for the whole config dir: anything added under nvim/ (after/,
    # ftplugin/, spell/, ...) is picked up without touching this manifest.
    nvim) echo "$DOTFILES/nvim|$HOME/.config/nvim" ;;
    tmux)   echo "$DOTFILES/.tmux.conf|$HOME/.tmux.conf" ;;
    git)    echo "$DOTFILES/.gitconfig|$HOME/.gitconfig" ;;
    ignore) cat <<EOF
$DOTFILES/.agignore|$HOME/.agignore
$DOTFILES/.rgignore|$HOME/.rgignore
EOF
      ;;
    agents) cat <<EOF
$DOTFILES/agents/AGENTS.md|$HOME/.codex/AGENTS.md
$DOTFILES/agents/AGENTS.md|$HOME/.claude/CLAUDE.md
$DOTFILES/agents/AGENTS.md|$HOME/.config/opencode/AGENTS.md
EOF
      ;;
    opencode) cat <<EOF
$DOTFILES/opencode/opencode.json|$HOME/.config/opencode/opencode.json
$DOTFILES/opencode/agents|$HOME/.config/opencode/agents
EOF
      ;;
    bat)     echo "$DOTFILES/gruvbox.tmTheme|$HOME/.config/bat/themes/gruvbox.tmTheme" ;;
    ideavim) echo "$DOTFILES/.ideavimrc|$HOME/.ideavimrc" ;;
    bin)     echo "$DOTFILES/bin/claude-deepseek|$HOME/.local/bin/claude-deepseek" ;;
  esac
}

all_links() {
  local c
  for c in "${COMPONENTS[@]}"; do
    component_links "$c"
  done
}

# Mirrors the path under $HOME rather than using basename: two targets can share
# a basename (agents maps one source to both ~/.codex/AGENTS.md and
# ~/.config/opencode/AGENTS.md), and a basename-keyed backup would drop one.
backup_path() {
  local target="$1" rel="$BACKUP_ROOT/${1#"$HOME"/}"
  BACKUP_USED=1
  mkdir -p "$(dirname "$rel")"
  mv "$target" "$rel"
  echo "  ${C_WARN}backed up${C_OFF} $target -> ${rel#"$HOME"/}"
}

link_one() {
  local src="$1" dst="$2"

  if [[ ! -e "$src" ]]; then
    echo "  ${C_ERR}missing source${C_OFF} $src (cannot link $dst)"
    PROBLEMS=$((PROBLEMS + 1))
    return 0
  fi

  # A link that points at the right place but resolves to nothing is still broken.
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    if [[ -e "$dst" ]]; then
      SKIPPED=$((SKIPPED + 1))
    else
      echo "  ${C_ERR}dangling${C_OFF} $dst -> $src (target does not exist)"
      PROBLEMS=$((PROBLEMS + 1))
    fi
    return 0
  fi

  if [[ "$CHECK_ONLY" == 1 ]]; then
    if [[ -L "$dst" ]]; then
      echo "  ${C_WARN}drift${C_OFF}  $dst (symlink to $(readlink "$dst"))"
    elif [[ -e "$dst" ]]; then
      echo "  ${C_WARN}drift${C_OFF}  $dst (a real file, not a symlink)"
    else
      echo "  ${C_WARN}missing${C_OFF} $dst"
    fi
    PROBLEMS=$((PROBLEMS + 1))
    return 0
  fi

  if [[ "$DRY_RUN" == 1 ]]; then
    echo "  would link $dst -> $src"
    return 0
  fi

  mkdir -p "$(dirname "$dst")"
  [[ -e "$dst" || -L "$dst" ]] && backup_path "$dst"
  ln -s "$src" "$dst"
  echo "  ${C_OK}linked${C_OFF}   $dst -> $src"
  LINKED=$((LINKED + 1))
}

# Finds links under $HOME that point into this repo but that the manifest no
# longer owns — leftovers from past layouts, which a manifest-only check cannot
# see. Scans a bounded set of directories rather than walking $HOME.
check_orphans() {
  local manifest="$1" dir entry target
  local dirs=(
    "$HOME" "$HOME/.config/nvim" "$HOME/.config/nvim/lua" "$HOME/.config/opencode"
    "$HOME/.config/coc" "$HOME/.config/bat/themes" "$HOME/.codex" "$HOME/.claude"
    "$HOME/.local/bin"
  )
  for dir in "${dirs[@]}"; do
    [[ -d "$dir" ]] || continue
    # "$dir"/.* too: leftovers from a config-dir layout are usually dotfiles
    # (~/.vimrc, ~/.zshrc.pre-oh-my-zsh), and `*` alone never matches those.
    # "." and ".." are not symlinks, so the -L test drops them.
    for entry in "$dir"/* "$dir"/.*; do
      [[ -L "$entry" ]] || continue
      target="$(readlink "$entry")"
      case "$target" in "$DOTFILES"/*) ;; *) continue ;; esac
      # Manifest lines are "source|target".
      grep -qxF "$target|$entry" "$manifest" && continue
      echo "  ${C_WARN}orphan${C_OFF} $entry -> $target (not in the manifest)"
      ORPHANS=$((ORPHANS + 1))
    done
  done
}

install_component() {
  local comp="$1" line src dst
  echo "${C_DIM}==>${C_OFF} $comp ${C_DIM}— $(describe "$comp")${C_OFF}"
  while IFS='|' read -r src dst; do
    [[ -z "$src" ]] && continue
    link_one "$src" "$dst"
  done < <(component_links "$comp")
}

# An app-managed file cannot be a symlink; Karabiner rewrites it in place.
karabiner_note() {
  local live="$HOME/.config/karabiner/karabiner.json"
  [[ -e "$live" || -L "$live" ]] || return 0
  if [[ -L "$live" ]]; then
    echo "  ${C_WARN}note${C_OFF}   $live is a symlink; Karabiner will overwrite the repo copy."
  else
    echo "  ${C_DIM}skip${C_OFF}   karabiner.json is app-managed and left alone."
  fi
}

usage() {
  cat <<EOF
Usage: ./install.sh [options]

  --all                install every component, no prompts
  --only a,b,c         install only these components
  --deps               also install system packages (Brewfile / apt)
  --check              report drift and missing tools; exit 1 if any
  --dry-run            print intended actions, change nothing
  -h, --help           this message

Components: ${COMPONENTS[*]}
EOF
}

check_deps() {
  local missing=() t
  echo "${C_DIM}==>${C_OFF} dependencies ${C_DIM}— tools the config shells out to${C_OFF}"
  for t in "${DEP_TOOLS[@]}"; do
    have "$t" || missing+=("$t")
  done
  if [[ ${#missing[@]} -eq 0 ]]; then
    echo "  all present"
    return 0
  fi
  echo "  ${C_WARN}missing${C_OFF}: ${missing[*]}"
  echo "  install with: ./install.sh --deps"
  TOOLS_MISSING=${#missing[@]}
}

# Package installation, not linking: needs network, and sudo on Linux.
install_deps() {
  local brewfile="$DOTFILES/Brewfile"
  echo "${C_DIM}==>${C_OFF} dependencies"
  if have brew; then
    [[ -f "$brewfile" ]] || { echo "  ${C_ERR}no Brewfile at $brewfile${C_OFF}"; return 1; }
    if [[ "$DRY_RUN" == 1 ]]; then
      echo "  would run: brew bundle --file=Brewfile"
      return 0
    fi
    echo "  brew bundle --file=Brewfile"
    brew bundle --file="$brewfile"
    return 0
  fi
  if [[ "$(uname -s)" == "Linux" ]] && have apt-get; then
    # Verified against Debian 13. Everything listed below is packaged; the
    # extras named afterwards are not, so --deps here cannot satisfy every name
    # in DEP_TOOLS.
    local pkgs=(ripgrep fzf bat jq direnv autojump broot python3 nodejs npm git
      git-lfs gh tmux build-essential git-delta)
    if [[ "$DRY_RUN" == 1 ]]; then
      echo "  would run: apt-get install ${pkgs[*]}"
    else
      echo "  apt-get install ${pkgs[*]}"
      # Non-fatal: a partly-available list should still reach the summary below.
      sudo apt-get update && sudo apt-get install -y "${pkgs[@]}" ||
        echo "  ${C_WARN}apt-get did not complete${C_OFF}"
    fi
    # Said either way: --deps on Linux cannot satisfy every DEP_TOOLS name.
    echo "  ${C_WARN}not installable this way${C_OFF}: difftastic (the difft binary), fnm, zellij."
    echo "  Distro Neovim is 0.10; this config needs 0.11+ (vim.lsp.config) — install it separately."
    return 0
  fi
  echo "  no Homebrew or apt-get here; install the tools listed in Brewfile by hand."
}

wizard() {
  local i=1 reply picked=() n choice
  echo
  echo "Dotfiles installer — repo at $DOTFILES"
  echo
  for choice in "${COMPONENTS[@]}"; do
    printf '  %2d) %-9s %s\n' "$i" "$choice" "$(describe "$choice")"
    i=$((i + 1))
  done
  echo
  echo "  a) all"
  echo

  # On EOF (no tty, `curl | bash`, make) the safe answer is to do nothing.
  if ! read -r -p "Install which? [a] " reply; then
    echo
    echo "${C_WARN}No input available; nothing installed.${C_OFF} Use --all to skip the prompt."
    exit 1
  fi
  reply="${reply:-a}"

  # Separate question, defaulting to no: this one runs a package manager.
  local deps_reply=""
  if read -r -p "Also install system packages via Homebrew/apt? [y/N] " deps_reply; then
    [[ "$deps_reply" =~ ^[Yy] ]] && DEPS_WANTED=1
  fi

  if [[ "$reply" == "a" || "$reply" == "all" ]]; then
    ONLY="${COMPONENTS[*]}"
    return
  fi

  for n in ${reply//,/ }; do
    if ! [[ "$n" =~ ^[0-9]+$ ]] || ((n < 1 || n > ${#COMPONENTS[@]})); then
      echo "Not a component number: $n" >&2
      exit 2
    fi
    picked+=("${COMPONENTS[$((n - 1))]}")
  done

  if ((${#picked[@]} == 0)); then
    echo "Nothing selected." >&2
    exit 2
  fi
  ONLY="${picked[*]}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all) ONLY="${COMPONENTS[*]}"; shift ;;
    --only)
      if [[ $# -lt 2 ]]; then
        echo "--only needs a value, e.g. --only nvim,shell" >&2
        exit 2
      fi
      ONLY="${2//,/ }"
      shift 2
      ;;
    --deps) DEPS_WANTED=1; shift ;;
    --check) CHECK_ONLY=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

# --check reports on everything by default rather than prompting.
if [[ "$CHECK_ONLY" == 1 && -z "$ONLY" ]]; then
  ONLY="${COMPONENTS[*]}"
fi

# `--deps` on its own means "packages only": no prompt, and no linking.
DEPS_ONLY=0
if [[ -z "$ONLY" && "$DEPS_WANTED" == 1 ]]; then
  DEPS_ONLY=1
fi

if [[ -z "$ONLY" && "$DEPS_ONLY" == 0 ]]; then
  wizard
fi

if [[ "$DEPS_ONLY" == 0 ]]; then
  selected=()
  for c in $ONLY; do
    if [[ " ${COMPONENTS[*]} " == *" $c "* ]]; then
      selected+=("$c")
    else
      echo "unknown component: $c" >&2
      exit 2
    fi
  done

  if ((${#selected[@]} == 0)); then
    echo "Nothing to install." >&2
    exit 2
  fi

  echo
  # Inside the guard: expanding an empty array with "${a[@]}" aborts under
  # `set -u` on bash 3.2, which is what macOS ships.
  for c in "${selected[@]}"; do
    install_component "$c"
  done
fi

if [[ "$CHECK_ONLY" == 1 ]]; then
  check_deps
  echo "${C_DIM}==>${C_OFF} orphans ${C_DIM}— links into this repo the manifest no longer owns${C_OFF}"
  manifest="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm -f '$manifest'" EXIT
  all_links > "$manifest"
  check_orphans "$manifest"
  rm -f "$manifest"
fi

echo
if [[ "$CHECK_ONLY" == 1 ]]; then
  if [[ $((PROBLEMS + ORPHANS + TOOLS_MISSING)) -eq 0 ]]; then
    echo "${C_OK}All links up to date, all tools present.${C_OFF}"
    exit 0
  fi
  if [[ "$PROBLEMS" -gt 0 ]]; then
    echo "${C_WARN}$PROBLEMS link(s) need attention.${C_OFF} Run ./install.sh to fix those."
  fi
  if [[ "$TOOLS_MISSING" -gt 0 ]]; then
    echo "${C_WARN}$TOOLS_MISSING tool(s) missing.${C_OFF} Install with ./install.sh --deps."
  fi
  if [[ "$ORPHANS" -gt 0 ]]; then
    echo "${C_WARN}$ORPHANS orphan(s)${C_OFF} are left over from an older layout; install.sh does not remove them."
  fi
  exit 1
fi

if [[ "$DEPS_WANTED" == 1 ]]; then
  install_deps
fi

karabiner_note
echo "${C_OK}linked: $LINKED${C_OFF}  unchanged: $SKIPPED${C_OFF}"
if [[ "$PROBLEMS" -gt 0 ]]; then
  echo "${C_WARN}$PROBLEMS link(s) could not be created.${C_OFF}"
fi
if [[ "$BACKUP_USED" == 1 ]]; then
  echo "previous files saved in $BACKUP_ROOT"
fi
