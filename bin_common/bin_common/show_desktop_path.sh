#!/bin/bash

# exit the script on command errors or unset variables
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# https://stackoverflow.com/a/246128/295807
# readonly script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# cd "${script_dir}"

# https://apple.stackexchange.com/questions/332334/macos-determine-current-wallpaper-path
defaults write com.apple.dock desktop-picture-show-debug-text -bool TRUE;killall Dock
