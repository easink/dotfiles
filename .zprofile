# ~/.zprofile: executed by zsh(1) for login shells.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/login.defs
#umask 022
umask 027

# the rest of this file is commented out.

if [ "$OSTYPE" = "darwin11" ]; then
    # Enable ls colors
    export CLICOLOR=1
fi

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
    fi
fi

# if running zsh
if [ -n "$ZSH_VERSION" ]; then
    if [ -f "$HOME/.zshrc" ]; then
        . "$HOME/.zshrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# do the same with MANPATH
if [ -d ~/man ]; then
    MANPATH=~/man:"${MANPATH}"
    export MANPATH
fi

