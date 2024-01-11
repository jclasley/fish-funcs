# swap back and forth between branches more easily
function gco -d "Save the current branch, checkout a new one. Current branch is saved and exported as $prev_branch. You can pass `-s/--switch` to automatically go back and forth between two branches."
  set -l innerPrev (git rev-parse --abbrev-ref HEAD)

  # check if switch is set
  set -l switch (fish_opt -o -s s -l switch)
  set -l switch $switch (fish_opt -s b -l branch)

  argparse $switch -- $argv || return

  # if flag is set
  if set -q _flag_switch
    git checkout $prev_branch || return
  else if set -q _flag_branch
    git checkout -b $argv || return
  else
    git checkout $argv || return
  end

  if set -q branch_history
    if not contains $innerPrev $branch_history
      set -U branch_history $innerPrev $branch_history[..9]
    end
  else
    set -U branch_history $innerPrev
  end

  set -g prev_branch $innerPrev
end
  

function new-branch -d "Pastes the URL from the clipboard and creates a branch. Second argument is the branch prefix. Remaining args are appended to the branch with `-`"
  set prefix "$argv[1]"
  set url (pbpaste)

  if test -z "$url"
    echo "No Jira URL in clipboard"
    return 1
  end

  set ticket (string match -r 'ADC-\d+' $url)
  if test -z "$ticket"
    echo "Couldn't find ticket number in clipboard contents"
    echo "Clipboard contents:"
    echo (string shorten -m 20 $url)
    return 1
  end

  set branch "$prefix/$ticket"

  if test (count $argv) -gt 1
    set addtl $argv[2..]
  end
  
  set -g prev_branch (git rev-parse --short HEAD)
  git checkout -b $branch-(string join "-" $addtl)
end
abbr -a nb new-branch

