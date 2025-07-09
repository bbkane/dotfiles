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

## Keyboard Shortcuts

Default keyboard shortcuts at https://wezfurlong.org/wezterm/config/default-keys.html

| Action               | Keys                   | Notes                                                        |
| -------------------- | ---------------------- | ------------------------------------------------------------ |
| Open Link            | Double click           | [Mouse Binding - Wez's Terminal Emulator](https://wezfurlong.org/wezterm/config/mouse.html#default-mouse-assignments) |
| Insert Unicode       | `CTRL` + `SHIFT` + `u` |                                                              |
| Move forward word    | `OPT` + `RIGHT ARROW`  | Set in Lua config (send `Alt` + `b`)                         |
| Move backward word   | `OPT` + `LEFT ARROW`   | Set in Lua config (send `Alt` + `f`)                         |
| Backspace word       | `CTRL` + `w`           | Standard Unix shortcut                                       |
| Debug Overlay        | `Ctrl` + `Shift` + `L` | [Troubleshooting - Wez's Terminal Emulator](https://wezfurlong.org/wezterm/troubleshooting.html) |
| New Window           | `Ctrl` + `Shift` + `n` |                                                              |
| Paste from Clipboard | `Ctrl` + `Shift` + `v` |                                                              |

# Layout

I use a lot of the same tab/window layouts that I want to re-create. I'd like to do tmux-like things, but for now here are some notes on doing it via the CLI. A lot of this is from [this blog](https://mwop.net/blog/2024-07-04-how-i-use-wezterm.html) and some is from Googling.

Definitions:

- window - an open Wezterm app window
- Workspace - a label on a window for easy switching? Note that this hides all windows NOT part of the current workspace.
- domain - a way to share workspaces  among windows? I don't think I need this
- pane - a "subwindow" you can split your window into. Like a physical window must have a least one pane, but can also have multiple to break it into 2 or 4 or 9 subwindows. This is mostly what I'm dealing with as I'm mostly interested in tab layout
- tab - a tab. I think each tab is also a pane? Not sure.

Can list everything with:

```bash
$ wezterm cli list
WINID TABID PANEID WORKSPACE SIZE   TITLE CWD
    0     0      0 default   142x36 zsh   file:///path/to/cwd
```

Create a new window with one pane and 2 child tabs with custom titles

```bash
# returns pane ID of new window
$ wezterm cli spawn --new-window
1

# set tab title
$ wezterm cli set-tab-title 'tab1' --pane-id=1

# create new tab in that pane
$ wezterm cli spawn --pane-id=1
2

# set 2nd tab title
$ wezterm cli set-tab-title 'tab2' --pane-id=2
```

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

