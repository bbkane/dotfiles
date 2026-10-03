# @bbkane's zsh plugin configuration
# Repo: https://github.com/bbkane/dotfiles

# fzf shell integration
eval "$(fzf --zsh)"

# fzf-tab must load after compinit and before plugins that wrap ZLE widgets.
source "$HOMEBREW_PREFIX/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh"
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' switch-group '<' '>'

# zsh-autosuggestions
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
bindkey '^ ' autosuggest-accept
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#737373'

# zoxide
eval "$(zoxide init zsh)"

# grc command colorization
source "$HOMEBREW_PREFIX/etc/grc.zsh"
# Keep native ls colors instead of grc's wrapper.
if (( $+functions[ls] )); then
    unfunction ls
fi

# Leave kubectl unwrapped so interactive sessions retain their terminal streams.
if (( $+functions[kubectl] )); then
    unfunction kubectl
fi

# zsh-syntax-highlighting must be the last plugin that wraps ZLE widgets.
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
