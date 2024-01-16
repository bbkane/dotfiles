# Wezterm

Trying to switch from iTerm2 for the following reasons:

- iTerm2 has a harder to reason about config file
- this is supposed to be faster, though I've never felt slowed by iTerm2
- Cross platform if I move to Linux
- A buncha built-in color schemes
- Help me learn Lua

https://wezfurlong.org/wezterm/config/files.html#configuration-files

To open a link, you shift click it (not cmd click like MacOS). I think I should
get used to that as it's more cross platform -
https://wezfurlong.org/wezterm/config/mouse.html#default-mouse-assignments - now it appears you double-click links

Insert Unicode (re: emojis) with Ctrl + Shift + U

Running into garbled text when I SSH into a server and tail logs... those are from gzipped logs lol

```bash
brew tap homebrew/cask-fonts
brew install font-fira-code
brew install font-ia-writer-mono
```

## FIXED - Font rendering

For some reason, iTerm2 has much better font rendering to me. See https://github.com/wez/wezterm/issues/681

Also see https://github.com/wez/wezterm/issues/3774 - maybe I should try kitty again? Fixed with config

## FIXED - Lag 

It lags when I do my three-finger-up swipe to zoom out...

See https://github.com/wez/wezterm/issues/2669 - fixed with https://github.com/wez/wezterm/issues/2669#issuecomment-1411507194

# Other terminals

## Kitty

Has a weird tab bar at the bottom

Need to adjust font size

