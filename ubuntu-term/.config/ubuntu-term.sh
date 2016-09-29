# An extra bash init file so I can just source this from the default system bash file
# and source .benshellrc from this

export vim_ide_status='ycm'

# https://bpaste.net/show/c689a3ea783f
# replace man with this function to get colors :)
man() {
    if [ "$TERM" = 'linux' ]; then
        env \
            LESS_TERMCAP_mb=$(printf "\e[34m") \
            LESS_TERMCAP_md=$(printf "\e[1;31m") \
            LESS_TERMCAP_me=$(printf "\e[0m") \
            LESS_TERMCAP_se=$(printf "\e[0m") \
            LESS_TERMCAP_so=$(printf "\e[30;43m") \
            LESS_TERMCAP_ue=$(printf "\e[0m") \
            LESS_TERMCAP_us=$(printf "\e[32m") \
            /usr/bin/man "$@"
    else
        env \
            LESS_TERMCAP_mb=$(printf "\e[1;34m") \
            LESS_TERMCAP_md=$(printf "\e[38;5;9m") \
            LESS_TERMCAP_me=$(printf "\e[0m") \
            LESS_TERMCAP_se=$(printf "\e[0m") \
            LESS_TERMCAP_so=$(printf "\e[30;43m") \
            LESS_TERMCAP_ue=$(printf "\e[0m") \
            LESS_TERMCAP_us=$(printf "\e[38;5;10m") \
            /usr/bin/man "$@"
    fi
}
