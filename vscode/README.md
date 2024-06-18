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

### Install settings.json with a symlink

This is not needed if you used the `curl` method

```
cd vscode/
python3 ./symlink_settings.py
./install_extensions.sh
```

## Extension management

VS Code extensions are kinda hard to manage with scripts that can be version-controlled. I've included scripts to do this, and every once in a while I run `./purge_installed_extensions.sh` to delete everything I've manually installed and reinstall them.
