# @bbkane's native zsh completion configuration
# Repo: https://github.com/bbkane/dotfiles

# $HOMEBREW_PREFIX is set by `brew shellenv` in ~/.zprofile.
FPATH="$HOMEBREW_PREFIX/share/zsh-completions:$FPATH"
FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions:$FPATH"
FPATH="$HOME/fbin:$FPATH"

# Partial completion suggestions, so cd /us/lo/bi<TAB> autocompletes.
# TODO: go through compinstall to make these.
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix

# Complete from a presented menu.
zstyle ':completion:*' menu select

# Cache completions: https://thevaluable.dev/zsh-completion-guide-examples/
zstyle ':completion:*' use-cache on
# NOTE: I also found ~/.zcompcache by accident. Not sure how that was created.
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompcache"

# Only do the full audit and dump rebuild once per day; otherwise reuse the
# cached dump.
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi
bashcompinit
