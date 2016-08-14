import platform
import sys
import subprocess
import shutil

def installed_ubuntu(package):
    """attempts to find package on ubuntu
    Uses dpkg to check if package is installed and shutil
    to check if it's on the PATH

    Params:
        package: str : name of package to check
    Returns:
        bool: True if installed, False if not
    Raises:
        None"""

    result = subprocess.run(['dpkg', '-l', package]).returncode
    return result == 0 or bool(shutil.which(package))

print('loaded')
print(installed_ubuntu('nvim'))
