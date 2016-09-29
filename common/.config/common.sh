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

# if fortune is on here, say it
# shellcheck disable=SC2039
hash fortune && echo "$(tput setaf $(( ($RANDOM % 17)+1 )) )$(fortune)$(tput sgr0)"
