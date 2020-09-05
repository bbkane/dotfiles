# VS Code

## Install VS Code

- Install Code from https://code.visualstudio.com/
- Add `code` command to `PATH` for command line usage
  - `Cmd-P`: Launch Command Palatte
  - Type `> Shell Command: Install code command in PATH`
  - Consider restarting your terminal if it doesn't work

## Install VS Code settings.json

### Back up potential old settings.json

```
mv \ 
    ~/Library/Application\ Support/Code/User/settings.json \
    ~/Library/Application\ Support/Code/User/settings.json.$(date +%Y-%m-%d)
```

### Install settings.json with `curl`

Note: this will overwrite any current settings.json - see above

```
curl \
    -fLo ~/Library/Application\ Support/Code/User/settings.json \
    https://raw.githubusercontent.com/bbkane/dotfiles/master/vscode/settings.json
```

### Install settings.json with a symlink (not for most users)

This is not needed if you used the `curl` method

```
cd vscode/
python3 install_vs_code_settings.py
```

## Install Microsoft Pylance plugin

- Install linters: `brew install python3 black flake8 mypy`
- From Terminal: `code --install-extension ms-python.python`
- Restart Visual Studio Code
- Install Python Tools the plugin uses (flake8, black)

