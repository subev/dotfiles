#!/bin/zsh
function gitbrdel() {
  git branch --sort=committerdate |
    grep --invert-match '\*' |
    cut -c 3- |
    fzf --tac --multi --preview="git ls master..{}" |
    xargs -r git branch --delete --force
}

function gitco() {
  git branch --sort=committerdate |
    grep --invert-match '\*' |
    cut -c 3- |
    fzf --tac --preview="git ls master..{}" |
    xargs -r git co
}

function gitpr() {
  local jq_template pr_number

  jq_template='"'\
'#\(.number) - \(.title)'\
'\t'\
'Author: \(.user.login)\n'\
'Created: \(.created_at)\n'\
'Updated: \(.updated_at)\n\n'\
'\(.body)'\
'"'

  pr_number=$(
    gh api 'repos/:owner/:repo/pulls' |
    jq ".[] | $jq_template" |
    sed -e 's/"\(.*\)"/\1/' -e 's/\\t/\t/' |
    fzf \
      --with-nth=1 \
      --delimiter='\t' \
      --preview='echo -e {2}' \
      --preview-window=top:wrap |
    sed 's/^#\([0-9]\+\).*/\1/'
  )

  if [ -n "$pr_number" ]; then
    gh pr checkout "$pr_number"
  fi
}
