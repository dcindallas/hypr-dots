if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Fixed: Changed from ~/.dotfiles/ to ~/hypr-dots/ (your actual repo)
alias config='/usr/bin/git --git-dir=/home/duane/hypr-dots/ --work-tree=/home/duane'

# 1. Define and EXPORT the path first
# set -gx STARSHIP_CONFIG /home/duane/.config/starship/duane.toml

# 2. Then initialize Starship
# starship init fish | source
