# @bbkane's zsh dotfiles entry point
# Repo: https://github.com/bbkane/dotfiles

autoload -Uz add-zsh-hook
autoload -Uz bashcompinit
autoload -Uz compinit
autoload -Uz edit-command-line

source "${ZDOTDIR:-$HOME}/.zshrc_core.zsh"
source "${ZDOTDIR:-$HOME}/.zshrc_completion.zsh"
source "${ZDOTDIR:-$HOME}/.zshrc_plugins.zsh"
source "${ZDOTDIR:-$HOME}/.zshrc_prompt.zsh"
