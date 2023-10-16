## Wezterm

Trying to switch from iTerm2 for the following reasons:

- iTerm2 has a harder to reason about config file
- this is supposed to be faster, though I've never felt slowed by iTerm2
- Cross platform if I move to Linux
- A buncha built-in color schemes
- Help me learn Lua

Font looks odd, but that could be ok. I think it's a different font

Need to adjust font size in lua config

https://wezfurlong.org/wezterm/config/files.html#configuration-files

To open a link, you shift click it (not cmd click like MacOS). I think I should
get used to that as it's more cross platform -
https://wezfurlong.org/wezterm/config/mouse.html#default-mouse-assignments

Running into garbled text when I SSH into a server and tail logs...

```bash
brew tap homebrew/cask-fonts
brew install font-fira-code
brew install font-ia-writer-mono
```

## Font rendering

For some reason, iTerm2 has much better font rendering to me. See https://github.com/wez/wezterm/issues/681

Also see https://github.com/wez/wezterm/issues/3774 - maybe I should try kitty?

# Other terminals

## Kitty

Has a weird tab bar at the bottom

Need to adjust font size

