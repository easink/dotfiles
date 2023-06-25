# Setup fzf
# ---------
# if [[ ! "$PATH" == *${HOME}/.fzf/bin* ]]; then
#   export PATH="$PATH:${HOME}/.fzf/bin"
# fi

# Auto-completion
# ---------------
# [[ $- == *i* ]] && source "${HOME}/.fzf/shell/completion.zsh" 2> /dev/null
[[ $- == *i* ]] && source "/usr/share/doc/fzf/examples/completion.zsh" 2> /dev/null

# Key bindings
# ------------
# source "${HOME}/.fzf/shell/key-bindings.zsh"
# source "/usr/share/doc/fzf/examples/key-bindings.zsh"
if [ -n "${commands[fzf-share]}" ]; then
  source "$(fzf-share)/key-bindings.zsh"
  source "$(fzf-share)/completion.zsh"
fi
