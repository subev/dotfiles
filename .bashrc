# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# dotnet
PATH="/usr/local/share/dotnet:$PATH"

# haskell compiled output
PATH="${HOME}/.local/bin:$PATH"
PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

alias git='hub'
alias g='git'
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

#turn autocomplete to be case insensitive
bind 'set completion-ignore-case on'

#enable ctrl-t to search forward (oposite of ctr-r)
bind "\C-t":forward-search-history

#enable clipboard writing
alias xclip='xclip -selection c'

#free the ctrl-s shortcut
stty ixany
stty ixoff -ixon

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

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alFH --group-directories-first --color=auto'
alias la='ls -A'
alias l='ls -CF'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

if [ -f ~/.git-completion.bash ]; then
    . ~/.git-completion.bash
fi

eval $(thefuck --alias)
command_exists () {
    type "$1" &> /dev/null ;
}

export EDITOR=vim

if command_exists rg ; then
  alias rg="rg --type-add 'pug:*.pug' --type-add 'zsh:.zshrc'"
fi

if command_exists mvim ; then
  export VISUAL="mvim"
fi

export PATH="$HOME/.cargo/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
. "$HOME/.cargo/env"
