#!/bin/bash

# NOTE: --uninstall-extension returns non-zero exits codes if another extension
# depends on it. Ignore those

# exit the script on command errors or unset variables
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -uo pipefail
IFS=$'\n\t'

# https://stackoverflow.com/a/246128/295807
readonly script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${script_dir}"

# https://stackoverflow.com/a/72394467/2958070
code --list-extensions | while read extension;
do
 code --uninstall-extension $extension
done
