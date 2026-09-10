# Sourced by ~/.bash_profile for login shells, and by interactive non-login
# shells directly. Interactive-only setup goes below the guard.

# Above the guard: cargo must reach non-interactive login shells too
# (`ssh host cmd`, cron, `#!/bin/bash -l`).
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

alias g='git'
alias __git_ps1="git branch 2>/dev/null | grep '*' | sed 's/* \(.*\)/(\1)/'"

function _git_prompt() {
local git_status="`git status -unormal 2>&1`"
if ! [[ "$git_status" =~ Not\ a\ git\ repo ]]; then
    if [[ "$git_status" =~ nothing\ to\ commit ]]; then
        local ansi=32
    elif [[ "$git_status" =~ nothing\ added\ to\ commit\ but\ untracked\ files\ present ]]; then
        local ansi=34
    else
        local ansi=33
    fi
    echo -n '\[\e[0;33;'"$ansi"'m\]'"$(__git_ps1)"'\[\e[0m\]'
fi
}

function _prompt_command() {
  PS1="[\[\033[32m\]\w\[\033[0m\]]\[\033[0m\]\n\[\033[1;36m\]\u@\[\033[0;37m\]\h]`_git_prompt`\[\033[1;33m\]->\[\033[0m\]"
}

PROMPT_COMMAND=_prompt_command

HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize

# turn autocomplete to be case insensitive
bind 'set completion-ignore-case on'

# enable ctrl-t to search forward (oposite of ctr-r)
bind "\C-t":forward-search-history

# free the ctrl-s shortcut
stty ixany
stty ixoff -ixon

command_exists () {
    type "$1" &> /dev/null ;
}

export EDITOR=vim

if command_exists rg ; then
  alias rg="rg --type-add 'pug:*.pug' --type-add 'zsh:.zshrc'"
fi

# GNU ls: `gls` from Homebrew coreutils on macOS, plain `ls` on Linux.
LS_BIN=$(command -v gls 2>/dev/null || command -v ls)
alias ll="$LS_BIN -alFHh --group-directories-first --color=auto"
alias la='ls -A'
alias l='ls -CF'

eval "$(fnm env --use-on-cd --shell bash)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/petur/.cache/lm-studio/bin"

source /Users/petur/.config/broot/launcher/bash/br

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
