#!/bin/bash

# Fun little script to see how many lines of Go I've coded for projects I care about.
# 2024-01-23: 11320 Go Code lines

# exit the script on command errors or unset variables
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

tokei \
    ~/Git-GH/example-go-cli \
    ~/Git-GH/fling \
    ~/Git-GH/gocolor \
    ~/Git-GH/grabbit \
    ~/Git-GH/logos \
    ~/Git-GH/shovel \
    ~/Git-GH/starghaze \
    ~/Git-GH/tablegraph \
    ~/Git-GH/warg \
