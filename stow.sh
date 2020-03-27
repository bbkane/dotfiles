#!/bin/bash

# exit the script on command errors or unset variables
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# https://stackoverflow.com/a/246128/295807
# readonly script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# cd "${script_dir}"

# useful options gleaned from `man stow`

# -d DIR
# --dir=DIR
#     Set the stow directory to "DIR" instead of the current
#     directory.  This also has the effect of making the default
#     target directory be the parent of "DIR".

# -t DIR
# --target=DIR
#     Set the target directory to "DIR" instead of the parent of the
#     stow directory.

# --dotfiles
#     Enable special handling for "dotfiles" (files or folders whose
#     name begins with a period) in the package directory. If this
#     option is enabled, Stow will add a preprocessing step for each
#     file or folder whose name begins with "dot-", and replace the
#     "dot-" prefix in the name by a period (.). This is useful when
#     Stow is used to manage collections of dotfiles, to avoid having
#     a package directory full of hidden files.

#     For example, suppose we have a package containing two files,
#     stow/dot-bashrc and stow/dot-emacs.d/init.el. With this option,
#     Stow will create symlinks from .bashrc to stow/dot-bashrc and
#     from .emacs.d/init.el to stow/dot-emacs.d/init.el. Any other
#     files, whose name does not begin with "dot-", will be processed
#     as usual.

# -v
# --verbose[=N]
#     Send verbose output to standard error describing what Stow is
#     doing. Verbosity levels are from 0 to 5; 0 is the default.
#     Using "-v" or "--verbose" increases the verbosity by one; using

#  -n
# --no
#     Do not perform any operations that modify the filesystem;
#     merely show what would happen.          `--verbose=N' sets it to N.

# NOTE: --dotfiles is stow 2.3.x, not 2.2.x. My linux box only has 2.2.x and this isn't important enough for me to try to build from source

set -x
stow --no --ignore 'README.*' -vvv --target "$HOME" "$@"
{ set +x; } 2>/dev/null

echo
# https://stackoverflow.com/a/27875395/2958070
read -p "Press 'Y' to continue with stow: " answer
case ${answer:0:1} in
    Y )
        set -x
        stow --ignore 'README.*' -vvv --target "$HOME" "$@"
        { set +x; } 2>/dev/null
    ;;
    * )
        echo "Exiting..."
    ;;
esac
