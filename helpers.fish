function diffpaste
  set file -l $argv[1]
  pbpaste | diff -c $file -
end

abbr -a --position anywhere ... -- ../..
