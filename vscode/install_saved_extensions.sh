#!/bin/bash

# exit the script on command errors or unset variables
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# https://stackoverflow.com/a/246128/295807
readonly script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${script_dir}"

while IFS='' read -r line || [ -n "${line}" ]; do
    set -x
    code --install-extension "$line"
    { set +x; } 2>/dev/null
done < ./installed_extensions.txt
