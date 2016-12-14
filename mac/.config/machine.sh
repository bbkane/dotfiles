# pbcopy is mac specific
stackoverflowit() {
    cat "$1"| sed 's/^/    /g' | pbcopy
}

# Homebrew
homebrew_bin_dir="/usr/local/bin"
export PATH="${homebrew_bin_dir}:$PATH"

export vim_ide_status='ycm'

complete -W 'start stop restart reload force-relead status configtest bootstrap' 'mysql.server'
