# VS Code

Managed with [`vscodectl.py`](../bin_common/bin_common/vscodectl.py), which uses this directory by default (override with `--root` or `VSCODECTL_ROOT`).

## Install VS Code

- Install Code from https://code.visualstudio.com/
- Add `code` command to `PATH` for command line usage
  - `Cmd-P`: Launch Command Palatte
  - Type `> Shell Command: Install code command in PATH`
  - Consider restarting your terminal if it doesn't work

## Install settings

`settings symlink` symlinks `settings.json` into VS Code's User dir. It refuses to overwrite non-symlinks, so back it up first:

```bash
cd ~/Library/Application\ Support/Code/User/
[ -e settings.json ] && [ ! -L settings.json ] && mv settings.json "settings.json.$(date +%Y-%m-%d)"
vscodectl.py settings symlink
```

## Extension management

```bash
vscodectl.py extensions save     # write installed extensions to installed_extensions.txt
vscodectl.py extensions install  # install extensions from installed_extensions.txt
vscodectl.py extensions purge    # uninstall all extensions
```

Every once in a while I purge and reinstall to remove extensions I've manually installed.
