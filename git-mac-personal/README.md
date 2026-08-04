# Personal macOS Git configuration

See the [git-common README](../git-common/README.md) for shared dependencies
and configuration notes.

## Credentials

This profile uses the macOS `osxkeychain` credential helper included with Git,
so no separate credential helper needs to be installed. Authenticate during
the first HTTPS fetch or push to store the credential in Keychain.

## Link

From the dotfiles repository root:

```bash
mkdir -p ~/.config
fling link -s ./git-common -s ./git-mac-personal
```
