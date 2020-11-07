#!/usr/bin/python3

# VSCode has different config locations depending on platform
# This should make symlinks based on that...
from __future__ import print_function

import argparse
import os
import platform
import sys

DESCRIPTION = """
Use the same VS Code settings across platforms with symlinks
"""


# monkey patch the new input function if this is an old Python
if sys.version_info.major == 2:
    input = raw_input

# http://stackoverflow.com/a/1026626/2958070 if I want to confirm admin privs

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
VS_SETTINGS_SRC_PATH = os.path.join(SCRIPT_DIR, "settings.json")

# https://code.visualstudio.com/docs/getstarted/settings#_settings-file-locations
if platform.system() == "Windows":
    VS_SETTINGS_DST_PATH = os.path.expandvars(r"%APPDATA%\Code\User\settings.json")
elif platform.system() == "Darwin":
    VS_SETTINGS_DST_PATH = os.path.expandvars(
        r"$HOME/Library/Application Support/Code/User/settings.json"
    )
elif platform.system() == "Linux":
    VS_SETTINGS_DST_PATH = os.path.expandvars(r"$HOME/.config/Code/User/settings.json")
else:
    raise NotImplementedError("No platform support for %r" % (platform.system()))

parser = argparse.ArgumentParser(description=DESCRIPTION)
parser.add_argument(
    "--batch", action="store_true", help="Don't ask for confirmation or print stdout"
)

args = parser.parse_args()


if args.batch:
    do_it = True
else:
    choice = input(
        "symlink %r -> %r ? [y/n] " % (VS_SETTINGS_SRC_PATH, VS_SETTINGS_DST_PATH)
    )
    do_it = choice == "y"

if do_it:

    # TODO: is this cross-platform?
    try:
        os.makedirs(os.path.dirname(VS_SETTINGS_DST_PATH))
    except OSError as e:
        if e.args[0] != 17:  # file exists
            raise

    # On Windows, there might be a symlink pointing to a different file
    # Always remove symlinks
    if os.path.islink(VS_SETTINGS_DST_PATH):
        os.remove(VS_SETTINGS_DST_PATH)

    os.symlink(VS_SETTINGS_SRC_PATH, VS_SETTINGS_DST_PATH)
else:
    print("Aborted")
