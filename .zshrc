# ~/.zshrc: executed by zsh(1) for non-login shells.
# see /usr/share/doc/zsh-doc/zsh.pdf (in the package zsh-doc)
# for examples

# If running interactively...
[ -z "$PS1" ] && return

PATH=$HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/usr/bin/X11:/bin:/sbin
PATH=$PATH:/opt/intel/bin
#PATH=$PATH:/opt/intel/vtune_amplifier_xe_2011
#PATH=$PATH:/opt/intel/inspector_xe_2011
export PATH

export USER=${USER:-`whoami`}

#
# Behaviour
#

# Still, I need emacs keybindings...
#bindkey -e
# Now, I don't...
bindkey -v

# bash-like <Esc><BS> binding
WORDCHARS=${WORDCHARS:s,/,,}
##bindkey "^[^?" vi-backward-kill-word
#bindkey "^[h" vi-forward-blank-word
#bindkey "^[m" vi-backward-blank-word
# expand-or-complete-prefix expands prefix part in completion
bindkey "^I" expand-or-complete-prefix

# when in vi-mode, I want my old ^R workflow back
bindkey '^R' history-incremental-search-backward
# want old <Esc>. to insert last word
bindkey '\e.' insert-last-word

# Disable cycle through tab completion alternatives
setopt noautomenu
setopt nomenucomplete

###

function title()
{
    # escape '%' chars in $1, make nonprintables visible
    local a=${(V)1//\%/\%\%}

    # Truncate command, and join lines.
    a=$(print -Pn "%40>...>$a" | tr -d "\n")
    case $TERM in
        screen*)
            print -Pn "\e]2;$a @ $2\a" # plain xterm title
            print -Pn "\ek$a\e\\"      # screen title (in ^A")
            print -Pn "\e_$2   \e\\"   # screen location
            ;;
        rxvt*|xterm*)
            print -Pn "\e]2;$a @ $2\a" # plain xterm title
            ;;
    esac
}

# Configure colors, if available.
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
#    c_reset='%{[0m%}'
#    c_user='%{[36m%}'
#    c_path='%{[37m%}'
#    c_git_clean='%{[0;32m%}'
#    c_git_dirty='%{[0;33m%}'
    c_reset=$'%{\e[0m%}'
    c_user=$'%{\e[36m%}'
    c_path=$'%{\e[37m%}'
    c_git_clean=$'%{\e[0;32m%}'
    c_git_dirty=$'%{\e[0;33m%}'
else
    c_reset=
    c_user=
    c_path=
    c_git_clean=
    c_git_dirty=
fi
#    PS1="[\[\e[36m\]\u@\h:\[\e[37m\]\w\[\e[0m\]] "

# Function to assemble the Git part of our prompt.
git_prompt()
{
    if ! git rev-parse --git-dir >/dev/null 2>&1 ||
        ! git ls-files --error-unmatch >/dev/null 2>&1; then
        git_branch=
        echo " "
        return 0
    fi

    git_proj=$(basename $(git rev-parse --show-toplevel))
    git_branch=$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')

    if git diff --quiet 2>/dev/null >&2; then
        git_color="$c_git_clean"
    else
        git_color="$c_git_dirty"
    fi

    echo -n "($git_color$git_proj${c_reset}/$git_color$git_branch${c_reset})"
}

# Add vi-mode status (NORMAL/INSERT)
terminfo_down_sc=$terminfo[cud1]$terminfo[cuu1]$terminfo[sc]$terminfo[cud1]
function zle-line-init zle-keymap-select {
    title "zsh" "%m:%55<...<%~ (${COLUMNS}x${LINES})"

    #PROMPT_2="${${KEYMAP/vicmd/-- NORMAL --}/(main|viins)/-- INSERT --}"
    #PROMPT_2="${${KEYMAP/vicmd/-- NORMAL --}/(main|viins)/}"
    PROMPT_2=""
    #PROMPT="%{$terminfo_down_sc$PROMPT_2$terminfo[rc]%}[${c_user}%n@%m${c_reset}:${c_path}%~${c_reset} \$] "
    PROMPT="[${c_user}%n@%m${c_reset}:${c_path}%~${c_reset} \$] "
    #PROMPT="[${c_user}h@h${c_reset}:${c_path}%~${c_reset} \$] "
    #RPROMPT="$(git_prompt)"
    RPROMPT="${${KEYMAP/(main|viins)/$(git_prompt)}/vicmd/[NORMAL]}"

    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

# Catch window resize
function TRAPWINCH()
{
#    precmd
#    zle -N zle-line-init
#    zle -N zle-keymap-select
}

# preexec is called just before any command line is executed
#function preexec() {
#  local a=${${1## *}[(w)1]}  # get the command
#  local b=${a##*\/}   # get the command basename
#  a="${b}${1#$a}"     # add back the parameters
#  a=${a//\%/\%\%}     # escape print specials
#  a=$(print -Pn "$a" | tr -d "\t\n\v\f\r")  # remove fancy whitespace
#  a=${(V)a//\%/\%\%}  # escape non-visibles and print specials
#
#  case "$TERM" in
#    screen|screen.*)
#      # See screen(1) "TITLES (naming windows)".
#      # "\ek" and "\e\" are the delimiters for screen(1) window titles
#      print -Pn "\ek%-3~ $a\e\\" # set screen title.  Fix vim: ".
#      print -Pn "\e]2;%-3~ $a\a" # set xterm title, via screen "Operating System Command"
#      ;;
#    rxvt|rxvt-unicode|rxvt-unicode-256color|xterm|xterm-color|xterm-256color)
#      print -Pn "\e]2;%m:%-3~ $a\a"
#      ;;
#  esac
#}
function preexec()
{
    title "$1" "%m:%35<...<%~ (${COLUMNS}x${LINES})"
}

#PROMPT_COMMAND='PS1="[${c_user}\u@\h${c_reset}:${c_path}\w${c_reset}$(git_prompt)\$] "'
#PROMPT="[${c_user}%n@%m${c_reset}:${c_path}%~${c_reset}$(git_prompt)$(date)\$] "
#PROMPT="[${c_user}%n@%m${c_reset}:${c_path}%~${c_reset}${GIT_PROMPT}\$] "

# don't put duplicate lines in the history. See bash(1) for more options
# bash: export HISTCONTROL=ignoreboth
#export HIST_IGNORE_DUPS
setopt hist_ignore_all_dups
setopt hist_ignore_space

# append to the history file, don't overwrite it
export APPEND_HISTORY
# bash: shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=1000
export SAVEHIST=2000
export HISTFILE="${HOME}/.zsh_history"

# disable indented space of a right prompt, could (no issues yet!) create wierd issues when using broken terminals...
export ZLE_RPROMPT_INDENT=0

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
# bash: shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

## If this is an xterm set the title to user@host:dir
#case "$TERM" in
#xterm*|rxvt*|screen)
##    PS1="[\[\e[36m\]\u@\h:\[\e[37m\]\w\[\e[0m\]] "
##    PS1=$'[%{\e[36m%}%n@%m:%{\e[0m%}%~] '
#    PROMPT=$'[%{\e[36m%}%n@%m:%{\e[0m%}%~] '
#    ;;
#*)
#    ;;
#esac

#
#setopt extended_glob
#preexec () {
#    if [[ "$TERM" == "screen" ]]; then
#        local CMD=${1[(wr)^(*=*|sudo|-*)]}
#        echo -ne "\ek$CMD\e\\"
#    fi
#}
#

## If this is an xterm set the title to user@host:dir
#case $TERM in
#xterm*)
#    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
#    ;;
#*)
#       ;;
#esac
## If this is an xterm set the title to user@host:dir
#case "$TERM" in
#xterm*|rxvt*)
#    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#    ;;
#*)
#    # set a fancy prompt
#    PS1="[\[\e[36m\]\u@\h:\[\e[37m\]\w\[\e[0m\]] "
#    ;;
#esac

# Local
EDITOR=vim; export EDITOR
#LANG=ISO-8859-1; export LANG
LC_CTYPE="sv_SE.UTF-8"; export LC_CTYPE
#LC_TYPE=ISO-8859-1; export LC_TYPE
#LC_MESSAGE=en_US; export LC_MESSAGE
#LANGUAGE=C; export LANGUAGE
#LC_ALL=C; export LC_ALL
#MM_CHARSET=iso-8859-1; export MM_CHARSET
#MM_AUXCHARSETS=iso-8859-1; export MM_AUXCHARSETS

MPAGE='-2tTafH -bA4 -D"%F %R"'; export MPAGE
#MPAGE='-2'; export MPAGE
PRINTER=""; export PRINTER
GS_OPTIONS="-sPAPERSIZE=a4"; export GS_OPTIONS

#LS_COLORS='no=00:fi=00:di=31:ln=01;36:pi=40;33:so=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jpg=01;35:*.png=01;35:*.gif=01;35:*.bmp=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.png=01;35:*.mpg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:'; export LS_COLORS

export RTF2LATEX2E_DIR=/usr/local/rtf2latex2e
#export CLASSPATH=/usr/lib/netscape/47/netscape/java/classes
#export MOZILLA_HOME=/usr/lib/netscape/47/netscape

export PAGER=less
export LESS="-IM"
export GREP_OPTIONS="--color"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    eval "`dircolors -b ~/.dir_colors`"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# some more aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
# alias dir="ls -l"
# alias dira="ls -la -x"
# alias la="ls -la"
alias cd..="cd .."
alias md=mkdir
alias rd=rmdir
alias cls=clear
alias hi=history
# alias cvs="cvs -z9"
# alias kgv=kghostview


ignoreeof=2
notify=
no_exit_on_failed_exec=
command_oriented_history=

#if [ "$TERM" = xterm-debian ]; then
#    updatetitle () { st=']0;';et='';echo -n "$st$HOSTNAME [$USER]: "`perl -e '$a="'$PWD'";print $a =~ /(.{16})$/ ? "...".$1 : $a'`"$et" >/dev/tty; }
#else
#    updatetitle () { :; }
#fi
#
#CD () { cd $@; eval `resize`; updatetitle; }
#updatetitle ;;

export LEFTYPATH=/usr/lib/lefty

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc).
#if [ -f /etc/bash_completion ]; then
#  . /etc/bash_completion
#fi


# This line was appended by KDE
# Make sure our customised gtkrc file is loaded.
# (This is no longer needed from version 0.8 of the theme engine)
export GTK2_RC_FILES=$HOME/.gtkrc-2.0

