#!/bin/bash

# exit the script on command errors or unset variables
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

make_print_color() {
    color_name="$1"
    color_code="$2"
    color_reset="$(tput sgr0)"
    if [ -t 1 ] ; then
        eval "print_${color_name}() { printf \"${color_code}%s${color_reset}\\n\" \"\$1\"; }"
    else  # Don't print colors on pipes
        eval "print_${color_name}() { printf \"%s\\n\" \"\$1\"; }"
    fi
}

make_print_color "red" "$(tput setaf 1)"
make_print_color "green" "$(tput setaf 2)"
make_print_color "yellow" "$(tput setaf 3)"

print_green "Current status:"

git status

print_green "Current tags:"

# Some notes on this:
# - I want the last 10 tags ordered by version
# - can't use `git tag` because it doesn't have a --count option
# - If I use --count directly on git for-each-ref, I get the first 10 tags and there's no --reverse option
# - So reverse sort by version, ensure color=always, and pipe to perl for a cross platform reverse
# format strings at https://git-scm.com/docs/git-for-each-ref#_field_names
git for-each-ref refs/tags \
    --count=10 \
    --sort=-version:refname \
    --color=always \
    --format='%(align:width=10,position=right)%(color:blue)%(refname:short)%(end) %(color:cyan)%(*authordate:short) %(color:yellow)%(subject)' \
| perl \
    -e 'print reverse <>' 

print_green "Create new tag and push!"

read -r -p "New tag (Ex: v1.0.0): " new_tag

if [[ ! "$new_tag" =~ ^v[0-9][0-9]?\.[0-9][0-9]?\.[0-9][0-9]? ]]; then
    print_red "Tag must match version reges"
    exit 1
fi

read -r -p "New message (Ex: 'new feature'): " new_message

git tag -a "${new_tag}" -m "${new_message}"
git push origin "${new_tag}"
