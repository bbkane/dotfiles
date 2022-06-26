#!/bin/bash

# exit the script on command errors or unset variables
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# https://git-scm.com/docs/git-log#Documentation/git-log.txt-emHem
# %H - commit hash
# %x09 - tab character
# %aI - author date
#
# RS = "" means it'll use a blank line as the field separator
git log \
    --format=format:"%aI" \
    --reverse \
    --shortstat \
| awk '
    BEGIN { RS = ""; FS = "\n"; OFS="\t"; print "date", "type", "lines" }
    {
        insertions = match($2, /[[:digit:]]+ insertion/)
        if (insertions != 0)
        {
            insertions = substr($2, RSTART, RLENGTH - 10)
            print $1, "insertion", insertions
        }

        deletions = match($2, /[[:digit:]]+ deletion/)
        if (deletions != 0)
        {
            deletions = -substr($2, RSTART, RLENGTH - 9)
            print $1, "deletion", deletions
        }
    }
'
