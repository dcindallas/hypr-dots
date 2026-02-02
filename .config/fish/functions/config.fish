function config --wraps='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME' --wraps='/usr/bin/git --git-dir=$HOME/hypr-dots/ --work-tree=$HOME' --description 'alias config=/usr/bin/git --git-dir=$HOME/hypr-dots/ --work-tree=$HOME'
    /usr/bin/git --git-dir=$HOME/hypr-dots/ --work-tree=$HOME $argv
end
