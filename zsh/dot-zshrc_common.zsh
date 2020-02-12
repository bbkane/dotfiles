# -- Aliases --

alias ls='ls -GF'

# if I have nvim, use it instead of vim
which nvim &> /dev/null && alias vim=nvim && alias vimdiff='nvim -d'

# work around npx's hilariously insecure behavior:
# https://github.com/npm/npx/issues/9
alias npx="npx --no-install $@"

# -- Exports --

export EDITOR=vim

# -- Functions --

bak() {
    if [[ -d "$1" ]]; then
        # https://stackoverflow.com/a/9018877/2958070
        local -r no_slash="${1%/}"
        cp -r "${no_slash}"  "${no_slash}.$(date +'%Y-%m-%d.%H.%M.%S').bak"
    elif [[ -f "$1"  ]]; then
        cp "$1" "${1}.$(date +'%Y-%m-%d.%H.%M.%S').bak"
    else
        echo "Only files and directories supported"
    fi
}


fullpath() {
    local dirname=$(perl -e 'use Cwd "abs_path";print abs_path(shift)' "$1")
    echo "$dirname"
}

# -- Other stuff --

# https://unix.stackexchange.com/a/34251/185953
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# https://superuser.com/a/523973/643441
bindkey -e


# man zshoptions

# https://scriptingosx.com/2019/06/moving-to-zsh-part-3-shell-options/
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
SAVEHIST=5000
HISTSIZE=2000
# share history across multiple zsh sessions
setopt SHARE_HISTORY
# append to history
setopt APPEND_HISTORY
# expire duplicates first
setopt HIST_EXPIRE_DUPS_FIRST
# do not store duplications
setopt HIST_IGNORE_DUPS
#ignore duplicates when searching
setopt HIST_FIND_NO_DUPS
# removes blank lines from history
setopt HIST_REDUCE_BLANKS
# when using !!, don't auto-hit enter
setopt HIST_VERIFY

# Let zsh try to correct me
setopt CORRECT
setopt CORRECT_ALL

# https://matt.blissett.me.uk/linux/zsh/zshrc
# Prompts for confirmation after 'rm *' etc
# Helps avoid mistakes like 'rm * o' when 'rm *.o' was intended
setopt RM_STAR_WAIT

# https://dev.to/manan30/what-is-the-best-zshrc-config-you-have-seen-14id
setopt auto_list # automatically list choices on ambiguous completion
setopt auto_menu # automatically use menu completion

# URL completion. Use URLs from history.
# zstyle -e ':completion:*:*:urls' urls 'reply=( ${${(f)"$(egrep --only-matching \(ftp\|https\?\)://\[A-Za-z0-9\].\* $HISTFILE)"}%%[# ]*} )'

# Play tetris
#autoload -U tetris
#zle -N tetris
#bindkey '^X^T' tetris

# partial completion suggestions
# so cd /us/lo/bi<TAB> autcompletes
# TODO: go through compinstall to make these
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix

# complete from a presented menu
zstyle ':completion:*' menu select

# enable completion
autoload -Uz compinit && compinit

# https://github.com/junegunn/fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# TODO: https://github.com/clvv/fasd

# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/colored-man-pages/colored-man-pages.plugin.zsh
function colored() {
	command env \
		LESS_TERMCAP_mb=$(printf "\e[1;31m") \
		LESS_TERMCAP_md=$(printf "\e[1;31m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[1;32m") \
		PAGER="${commands[less]:-$PAGER}" \
		_NROFF_U=1 \
		PATH="$HOME/bin:$PATH" \
			"$@"
}

function man() {
	colored man "$@"
}
