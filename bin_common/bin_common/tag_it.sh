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

git tag

print_green "Create new tag and push!"

read -r -p "New tag (Ex: v1.0.0): " new_tag
read -r -p "New message (Ex: 'new feature'): " new_message

git tag -a "${new_tag}" -m "${new_message}"
git push origin "${new_tag}"
