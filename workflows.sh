#!/bin/zsh
function gitbrdel() {
  local branches remote
  while [[ "$#" -gt 0 ]]; do
    case $1 in
        -r|--remote) remote=1 ;;
        *) echo "Unknown parameter passed: $1"; return 1 ;;
    esac
    shift
  done

  branches=$(git branch --sort=committerdate |
    grep --invert-match '\*' |
    cut -c 3- |
    fzf --tac --multi --preview="git ls master..{}");
  while IFS= read -r line; do
    if [[ $remote ]]; then
      echo "deleting remotely..."
      git push origin -d $line;
    fi
    #echo "deleting >>>$line<<<"
    git branch -D $line;
  done <<< $branches;
  echo "done"
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
