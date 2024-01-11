######################################
######### staging version ############
######################################

function getVersions
  for dir in $GODIR/*
      test -d $dir
      set -l base $(basename $dir)
      cd $dir
      git fetch --tags &> /dev/null
      set -l tag (git tag -l --sort=-creatordate | head -n 1)
      echo "$base -- $tag"
  end
end

function dirbb
  set dir (basename "$PWD")
  set br (git branch --show-current)
  set url "https://bitbucket.org/newyuinc/$dir/commits/branch/$br"

  read -P "Open $url? (Y/n) " opt
  test $opt = "" && set opt "y"

  if test (string lower $opt) = "y"
   open "$url"
  end
end

function tagAs
  # is the `-f/--force` flag passed?
  set -l force (fish_opt -o -s f -l force)
  argparse $force -- $argv
  or return

  set tag "$argv[1]"

  # check if it starts with a v, cause it should
  if test (string sub --length 1 $tag) != "v"
    if not set -q _flag_force
      echo "tag $tag does not start with a `v`, pass `-f/--force` to force"
      return 1
    end
  end

  # forward and return the error if there is one
  git tag $tag || return

  echo "pushing $tag to origin..."
  git push origin $tag
end

function branchDelete
  read -P "This will delete branch $arv[1], are you sure? (y/N)" opt
  if test (string lower $opt) = "y"
    return (git push origin --delete $argv[1])
  end
  echo "Aborting operation"
end
abbr -a bd --position command branchDelete

function updateDep
  set br (git branch --show-current)
  set repo $argv[1]
  set repo_version $argv[2]
  go get -u bitbucket.org/newyuinc/$repo@$repo_version || return
  go mod tidy && go mod vendor
  git checkout -b jlasley/version_bump

  git status
  read -P "Continue? (Y/n)" opt
  if test (string lower $opt) = "n"
    git checkout $br
    git branch -d jlasley/version_bump
    return
  end

  git add .
  git commit -m 'version bump'
  git push -u origin jlasley/version_bump
end

function tags
  git describe --tags
end

function deleteTag
  if test (string sub --length 1 $argv[1]) != "v"
    read -P 'tag does not start with `v` (RET to continue)'
  end
  git tag -d $argv[1]
  git push --delete origin $argv[1]
end


############################
#       end staging        #
############################

