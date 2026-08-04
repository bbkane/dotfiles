# Personal Debian GUI Git configuration

See the [git-common README](../git-common/README.md) for shared dependencies
and configuration notes.

## Credentials

Install [Git Credential Manager using its Debian
package](https://github.com/git-ecosystem/git-credential-manager/blob/release/docs/install.md#debian-package).
The package installs `git-credential-manager` in `/usr/local/bin`, so ensure
that directory is in `PATH`:

```bash
export PATH="$PATH:/usr/local/bin"
```

This profile configures Git Credential Manager to use the Secret Service
credential store.

## Link

From the dotfiles repository root:

```bash
mkdir -p ~/.config
fling link -s ./git-common -s ./git-linux-gui-personal
```
