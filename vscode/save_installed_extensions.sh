#!/bin/bash

# exit the script on command errors or unset variables
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# https://stackoverflow.com/a/246128/295807
readonly script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${script_dir}"

code --list-extensions \
| grep -Ev '^linkedin\.' \
| grep -Ev 'suchitadoshi1987.vscode-ember-experimental' \
| sort > ./installed_extensions.txt 
