# Set custom prompt
setopt PROMPT_SUBST
autoload -U promptinit
promptinit
prompt grb

# Initialize completion
autoload -U compinit
compinit

# Add paths
export PATH=/usr/local/sbin:/usr/local/bin:${PATH}
export PATH="$HOME/bin:$PATH"

# Colorize terminal
alias ls='ls -G'
alias ll='ls -lG'
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
export GREP_OPTIONS="--color"

# Nicer history
export HISTSIZE=100000
export HISTFILE="$HOME/.history"
export SAVEHIST=$HISTSIZE

# Use vim as the editor
export EDITOR=vi
# GNU Screen sets -o vi if EDITOR=vi, so we have to force it back.
# set -o emacs
set -o vi

# Search backward in history
bindkey '^R' history-incremental-search-backward
# Insert last word from prev command
bindkey "^[." insert-last-word

# Use C-x C-e to edit the current command line
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# By default, zsh considers many characters part of a word (e.g., _ and -).
# Narrow that down to allow easier skipping through words via M-f and M-b.
export WORDCHARS='*?[]~&;!$%^<>'

# Highlight search results in ack.
export ACK_COLOR_MATCH='red'

# Aliases
#function t() {
#    if [ -e script/test ]; then
#        script/test $*
#    else
#        rspec --color spec
#    fi
#}
#function lack() {
#    # The +k clears the screen (it tries to scroll up but there's nowhere to
#    # go)
#    ack --group --color $* | less -r +k
#}
function mcd() { mkdir -p $1 && cd $1 }
function cdf() { cd *$1*/ } # stolen from @topfunky
alias v="view -"
alias c="cdf"

# Find the directory of the named Python module.
python_module_dir () {
    echo "$(python -c "import os.path as _, ${1}; \
        print _.dirname(_.realpath(${1}.__file__[:-1]))"
        )"
}

# By @ieure; copied from https://gist.github.com/1474072
#
# It finds a file, looking up through parent directories until it finds one.
# Use it like this:
#
#   $ ls .tmux.conf
#   ls: .tmux.conf: No such file or directory
#
#   $ ls `up .tmux.conf`
#   /Users/grb/.tmux.conf
#
#   $ cat `up .tmux.conf`
#   set -g default-terminal "screen-256color"
#
function up()
{
    local DIR=$PWD
    local TARGET=$1
    while [ ! -e $DIR/$TARGET -a $DIR != "/" ]; do
        DIR=$(dirname $DIR)
    done
    test $DIR != "/" && echo $DIR/$TARGET
}

# Switch projects
function p() {
    proj=$(ls ~/proj | selecta)
    if [[ -n "$proj" ]]; then
        cd ~/proj/$proj
    fi
}

# ------------------------------------------------
x() {
    if [[ "$USER" == "root" ]]; then
        echo "Must be regular user (not root) to copy a file to the clipboard."
    else
        if [[ -p /dev/stdin ]]; then
            xclip -selection p
        else
            xclip -out
        fi
    fi
}
# Copy contents of a file
function xf() { cat "$1" | x; }
# Copy SSH public key
# alias xssh="cbf ~/.ssh/id_rsa.pub"
# Copy current working directory
alias xwd="pwd | x"
# Copy most recent command in shell history
alias xhs="echo !! | x"

# By default, ^S freezes terminal output and ^Q resumes it. Disable that so
# that those keys can be used for other things.
unsetopt flowcontrol
# Run Selecta in the current working directory, appending the selected path, if
# any, to the current command.
function insert-selecta-path-in-command-line() {
    local selected_path
    # Print a newline or we'll clobber the old prompt.
    echo
    # Find the path; abort if the user doesn't select anything.
    selected_path=$(find * -type f | selecta) || return
    # Append the selection to the current command buffer.
    eval 'LBUFFER="$LBUFFER$selected_path"'
    # Redraw the prompt since Selecta has drawn several new lines of text.
    zle reset-prompt
}
# Create the zle widget
zle -N insert-selecta-path-in-command-line
# Bind the key to the newly created widget
bindkey "^S" "insert-selecta-path-in-command-line"

# http://superuser.com/questions/117051/how-do-i-save-the-scrollback-buffer-in-urxvt
# http://blog.plenz.com/2012-01/zsh-complete-words-from-tmux-pane.html
_scrollback_buffer_words() {
    local expl
    local -a w
    if [[ -z "$TMUX_PANE" ]]; then
        # not tmux
        #
        # depends URxvt.print-pipe configuration
        # insure the ~/.Xresources or ~/.Xdefaults:
        #   URxvt.print-pipe:   cat > /tmp/xxx
        #
        /bin/echo -e -n '\e[i'
        # w=( ${(u)=$(sleep 0.1; /bin/cat $HOME/.xxx)} )
        w=( ${(u)=$(sleep 0.1; /bin/cat $HOME/.urxvtprint)} )
        _wanted values expl 'words from current buffer' compadd -a w
    else
        # tmux
        w=( ${(u)=$(tmux capture-pane \; show-buffer \; delete-buffer)} )
        _wanted values expl 'words from current tmux pane' compadd -a w
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

# git
alias g="git"
alias ga="git add"
alias gl="git l"
alias ge='vim "$(git ls-files | selecta)"'
alias gd="git diff"
alias gf="git fetch"
alias gfa="git fetch --all"
# alias gre="git remote"
alias gp="git push"
alias gs="git status"
alias gco="git checkout"
alias gcm="git commit -v"
alias gre="git reset"
alias grm="git rm"

# tmux
alias t="tmux"
alias ta="tmux attach"
alias ts='tmux attach -t "$(tmux ls| selecta | cut -d: -f1)"'
alias tls="tmux ls"


