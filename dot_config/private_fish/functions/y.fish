# yazi: file manager with cwd integration (cd on exit)
function y --description "yazi file manager (cd on exit)"
    set -l tmp (mktemp -t yazi-cwd)
    yazi $argv --cwd-file=$tmp
    if set -l cwd (command cat $tmp); and test -n "$cwd"; and test "$cwd" != (pwd)
        cd $cwd
    end
    command rm -f $tmp
end
