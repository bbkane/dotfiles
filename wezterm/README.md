# Wezterm

## Install

```bash
brew install wezterm
brew tap homebrew/cask-fonts
# Fonts I'm liking these days
brew install font-hack
brew install font-fira-code
brew install font-ia-writer-mono
```

Set up [terminfo](https://wezfurlong.org/wezterm/config/lua/config/term.html):

```bash
tempfile=$(mktemp) \
&& curl -o $tempfile https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo \
&& tic -x -o ~/.terminfo $tempfile \
&& rm $tempfile
```

Tbh, I'm not at all sure I care about undercurl this much...

## Keyboard Shortcuts

| Action             | Keys                   | Notes                                                        |
| ------------------ | ---------------------- | ------------------------------------------------------------ |
| Open Link          | Double click           | [Mouse Binding - Wez's Terminal Emulator](https://wezfurlong.org/wezterm/config/mouse.html#default-mouse-assignments) |
| Insert Unicode     | `CTRL` + `SHIFT` + `u` |                                                              |
| Move forward word  | `OPT` + `RIGHT ARROW`  | Set in Lua config (send `Alt` + `b`)                         |
| Move backward word | `OPT` + `LEFT ARROW`   | Set in Lua config (send `Alt` + `f`)                         |
| Backspace word     | `CTRL` + `w`           | Standard Unix shortcut                                       |
| Debug Overlay      | `Ctrl` + `Shift` + `L` | [Troubleshooting - Wez's Terminal Emulator](https://wezfurlong.org/wezterm/troubleshooting.html) |

## Bugs

### FIXED - Font rendering

For some reason, iTerm2 has much better font rendering to me. See https://github.com/wez/wezterm/issues/681

Also see https://github.com/wez/wezterm/issues/3774 - maybe I should try kitty again? Fixed with config

### FIXED - Lag 

It lags when I do my three-finger-up swipe to zoom out...

See https://github.com/wez/wezterm/issues/2669 - fixed with https://github.com/wez/wezterm/issues/2669#issuecomment-1411507194

# Other terminals

## iTerm2

Trying to switch from iTerm2 for the following reasons:

- iTerm2 has a harder to reason about config file
- this is supposed to be faster, though I've never felt slowed by iTerm2
- Cross platform if I move to Linux
- A buncha built-in color schemes
- Help me learn Lua

## Kitty

Has a weird tab bar at the bottom

Need to adjust font size

