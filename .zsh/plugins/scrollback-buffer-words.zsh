# http://superuser.com/questions/117051/how-do-i-save-the-scrollback-buffer-in-urxvt
# http://blog.plenz.com/2012-01/zsh-complete-words-from-tmux-pane.html
_scrollback_buffer_words() {
    local expl
    local -a w
    if [[ -n "$TMUX_PANE" ]]; then
        # tmux
        w=( ${(u)=$(tmux capture-pane \; show-buffer \; delete-buffer)} )
        _wanted values expl 'words from current tmux pane' compadd -a w
    elif [[ "${TERM}" =~ "rxvt" ]]; then
        # depends URxvt.print-pipe configuration
        # ensure the ~/.Xresources or ~/.Xdefaults:
        #   URxvt.print-pipe:   cat > /tmp/xxx
        #
        /bin/echo -e -n '\e[i'
        # w=( ${(u)=$(sleep 0.1; /bin/cat $HOME/.xxx)} )
        w=( ${(u)=$(sleep 0.1; /bin/cat $HOME/.urxvtprint)} )
        _wanted values expl 'words from current buffer' compadd -a w
    else
        echo "Not implemented for this terminal!"
    fi
}

zle -C scrollback-buffer-words-prefix   complete-word _generic
zle -C scrollback-buffer-words-anywhere complete-word _generic
# Alt-Tab:
# bindkey -M viins "\e\t" scrollback-buffer-words-prefix
bindkey -M viins "^V" scrollback-buffer-words-prefix
# Shift-Tab
# bindkey -M viins "^[[Z" scrollback-buffer-words-anywhere
bindkey -M viins "^X" scrollback-buffer-words-anywhere
zstyle ':completion:scrollback-buffer-words-(prefix|anywhere):*' completer _scrollback_buffer_words
zstyle ':completion:scrollback-buffer-words-(prefix|anywhere):*' ignore-line current
zstyle ':completion:scrollback-buffer-words-anywhere:*' matcher-list 'b:=* m:{A-Za-z}={a-zA-Z}'

