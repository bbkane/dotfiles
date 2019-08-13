#!/bin/zsh

# pbcopy is mac specific
stackoverflowit() {
    cat "$1"| sed 's/^/    /g' | pbcopy
}

# Homebrew
homebrew_bin_dir="/usr/local/bin"
export PATH="${homebrew_bin_dir}:$PATH"

# YCM is being a *****
# export vim_ide_status='ycm'

complete -W 'start stop restart reload force-relead status configtest bootstrap' 'mysql.server'

export PATH="/Users/bbkane/anaconda3/bin:$PATH"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

export s5='192.168.1.66'
export s8='192.168.1.153'

export EDITOR=/usr/local/bin/nvim

export CGO_ENABLED=1
export GOPATH="$HOME/Code/Go"

export PATH="$PATH:$GOPATH/bin"

alias GOME='cd ~/Code/Go/src/github.com/bbkane/'
