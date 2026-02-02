#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
alias matrix='cmatrix -ab -C blue -u 8 -s'
eval "$(starship init bash)"


# Example: Send the last 20 lines of DMS logs to Gemini for a fix
alias dms-fix="dms logs | tail -n 20 | gemini -p 'I am on Arch/Hyprland using DMS. Explain this error and give me the fix command:'"
