function addgit
    set -l target_path $argv[1]

    if test -z "$target_path"
        echo "Usage: addgit <path>"
        return 1
    end

    # Respects your .gitignore logic—will fail if the path is actually ignored
    git --git-dir=$HOME/hypr-dots/ --work-tree=$HOME add $target_path
    
    # Execute your push command
    hyper-push
end
