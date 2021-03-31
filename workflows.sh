#!/bin/zsh
function gitbrdel() {
  git branch --sort=committerdate |
    grep --invert-match '\*' |
    cut -c 3- |
    fzf --tac --multi --preview="git ls master..{}" |
    xargs -r git branch --delete --force
}
