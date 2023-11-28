#!/bin/zsh
function gitbrdel() {
  local branches remote main_or_master

  while [[ "$#" -gt 0 ]]; do
    case $1 in
        -r|--remote) remote=1 ;;
        *) echo "Unknown parameter passed: $1"; return 1 ;;
    esac
    shift
  done

  if git show-ref --verify --quiet refs/heads/master; then
    main_or_master=master
  elif git show-ref --verify --quiet refs/heads/main; then
    main_or_master=main
  else
    echo "Neither master nor main branches found."
    return 1
  fi

  branches=$(git branch --sort=committerdate |
    grep --invert-match '\*' |
    cut -c 3- |
    fzf --tac --multi --preview="git ls --first-parent $main_or_master..{}");
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
  local main_or_master
  local flag_r=""
  local flag_a=""

  while [[ "$#" -gt 0 ]]; do
    case $1 in -r|--remote) flag_r="-r" ;;
        -a|--all) flag_a="-a" ;;
        *) echo "Unknown parameter passed: $1"; return 1 ;;
    esac
    shift
  done

  if git show-ref --verify --quiet refs/heads/master; then
    main_or_master=master
  elif git show-ref --verify --quiet refs/heads/main; then
    main_or_master=main
  else
    echo "Neither master nor main branches found."
    return 1
  fi

  # Use the captured flags
  git branch --sort=committerdate $flag_r $flag_a |
    grep --invert-match '\*' |
    grep --invert-match '\->' |
    cut -c 3- |
    fzf --tac --preview="git ls --first-parent origin/$main_or_master..{}" |
    sed -r "s/(remotes\/)?origin\///" | 
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
