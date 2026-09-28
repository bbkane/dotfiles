# [espanso](https://espanso.org/)

# macOS setup

```bash
brew install espanso
```

When updating, `espanso` can be stuck in the Accessibility screen. How to fix:

Remove `Espanso` from the Accessibility list:

- System Settings app -> Privacy And Security on the left -> Accessibility`
- highlight it, click remove at the bottom
- completely close system settings

Terminal commands to start espanso

```bash
pkill -f espanso
espanso service register  # Follow prompts to open settings and toggle on
espanso start  # if necessary
```

# Debian setup

TODO: explain this better (from minipc notes)

https://espanso.org/docs/install/linux/#deb-wayland

```bash
curl -L -f -o espanso-debian-wayland-amd64.deb \
  https://github.com/espanso/espanso/releases/latest/download/espanso-debian-wayland-amd64.deb
  
sudo apt install ./espanso-debian-wayland-amd64.deb

sudo setcap "cap_dac_override+p" $(which espanso)
```

```bash
# link dotfiles first: 
espanso register
espanso start --unmanaged  # TODO: did I not set this up as a service?
```
