This directory contains files that are not dotfiles, but that I want to
back up. Each file should have info about where it belongs and what is
does in comments at the top.

To symlink, use the command `ln -s <file location> <symlink location>`

The file location should be in this folder for backup purposes, so an
example `<file location>` is `< $HOME/backup/other/monitor.sh >`, and an
example `<symlink location>` is `< /usr/local/bin/monitor.sh >`.

So, my symlinks are acting screwy. I'll have to ask for help until I get
it figured out. In the meantime, better just copy the stuff in here to
the correct folder.

After some more messing with it, I have found it works if you use full
file paths- no `./filname` in the command.

I think this works..

