# vim: set ft=zsh:

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

