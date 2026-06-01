function mkcd
    if test (count $argv) -ne 1
        echo "Usage: mkcd <directory>"
        return 1
    end

    if test -d $argv[1]
        echo "Directory '$argv[1]' already exists"
        return 1
    end

    mkdir -p $argv[1]
    if test $status -ne 0
        echo "Failed to create directory '$argv[1]'"
        return 1
    end

    cd $argv[1]
end
