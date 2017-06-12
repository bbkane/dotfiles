# VSCode has different config locations depending on platform
# This should make symlinks based on that...

# http://stackoverflow.com/a/1026626/2958070
import os
import platform


SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
VS_SETTINGS_SRC_PATH = os.path.join(SCRIPT_DIR, 'settings.json')

# https://code.visualstudio.com/docs/getstarted/settings#_settings-file-locations
if platform.system() == 'Windows':
    VS_SETTINGS_DST_PATH = os.path.expandvars(r"%APPDATA%\Code\User\settings.json")
elif platform.system() == "Darwin":
    VS_SETTINGS_DST_PATH = os.path.expandvars(r"$HOME/Library/Application Support/Code/User/settings.json")
elif platform.system() == "Linux":
    raise NotImplementedError()
else:
    raise NotImplementedError()

# On Windows, there might be a symlink pointing to a different file
# Always remove symlinks
if os.path.islink(VS_SETTINGS_DST_PATH):
    os.remove(VS_SETTINGS_DST_PATH)

choice = input('symlink %r -> %r ? (y/n) ' % (VS_SETTINGS_SRC_PATH, VS_SETTINGS_DST_PATH))
if choice == 'y':
    os.symlink(VS_SETTINGS_SRC_PATH, VS_SETTINGS_DST_PATH)
    print('Done')
else:
    print('aborted')
