# [espanso](https://espanso.org/)

# MacOS Accessibility issues

This used to work (2026-09-13):

```bash
espanso start --unmanaged
```

But now I have to:

- Remove `Espanso` from the Accessibility list (highlight it, click remove at the bottom)
- completely close system settings
- `pkill -f espanso`
- `espanso service register` (and toggle it on)
- `espanso start` (if necessary)
