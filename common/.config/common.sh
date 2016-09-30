see_path() {
    echo "$PATH" | tr ":" "\n"
}

# make compiling easier
go() {
    echo ""; clang++ -std=c++11 -Wall -Werror "$1" -o "$1.out" && ./"$1.out";
}

setedit() {
    # shellcheck disable=SC2139
    alias edit="vim $1";
}

lazygit() {
    git add . && git commit -m "$1" && git push;
}

#set today to the date
today=$(date +%Y-%m-%d)
export today

# mk and cd directory
mkcd() {
  if [ ! -n "$1" ]; then
    echo "Enter a directory name"
  elif [ -d "$1" ]; then
    echo "\`$1' already exists"
  else
    # shellcheck disable=SC2164
    mkdir "$1" && cd "$1"
  fi
}

logit() {
    today=$(date +%Y-%m-%d.%H.%M)
    "$@" > >(tee "$1".stdout."$today".log) 2> >(tee "$1".stderr."$today".log >&2)
}

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

if [[ -n "$ZSH_VERSION" ]]; then
    unsetopt AUTO_CD
elif [[ -n "$BASH_VERSION" ]]; then
    export PS1="\[$(tput bold)\]\[$(tput setaf 6)\]\t \[$(tput setaf 2)\][\[$(tput setaf 6)\]\u\[$(tput setaf 6)\]@\[$(tput setaf 6)\]\h \[$(tput setaf 6)\]\W\[$(tput setaf 2)\]]\n\\$ \[$(tput setaf 4)\]\[$(tput sgr0)\]"
    bind 'TAB:menu-complete'
fi

# if fortune is on here, say it
# shellcheck disable=SC2039
# hash fortune && echo "$(tput setaf $(( ($RANDOM % 17)+1 )) )$(fortune)$(tput sgr0)"

if [[ -f "$HOME/.config/machine.sh" ]]; then
    source "$HOME/.config/machine.sh"
fi
