# Not Git
#
# play with colors at https://zsh-prompt-generator.site/
# consider doing something special if connected via SSH: https://github.com/KorvinSilver/blokkzh/blob/master/blokkzh.zsh-theme#L49
# http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#Version-Control-Information
# prompt %vars: http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Prompt-Expansion
# url auto-complete, tetris: https://matt.blissett.me.uk/linux/zsh/zshrc
# https://unix.stackexchange.com/a/214699/185953

# -- Prompt --

# https://unix.stackexchange.com/a/40646/185953
setopt prompt_subst

color() {
    local -r color_code="$1"
    local -r text="$2"
    echo "%F{$color_code}$text%f"
}

# Virtualenv: current working virtualenv
virtualenv_prompt_info() {
    # https://github.com/ohmyzsh/ohmyzsh/blob/96f4a938383e558e8f800ccc052a80c6f743555d/plugins/virtualenv/virtualenv.plugin.zsh
    # -n means length of string is non-zero
    # "${VIRTUAL_ENV:t}" == "$(basename $VIRTUAL_ENV)"
    virtualenv_prompt_info_var=''
    if [[ -n $VIRTUAL_ENV ]]; then
        virtualenv_prompt_info_var="${VIRTUAL_ENV:t} "
    fi
}

git_prompt_info() {
    # https://arjanvandergaag.nl/blog/customize-zsh-prompt-with-vcs-info.html - didn't really work
    # cribbed from https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
    git_prompt_info_var="$(git describe --contains --all HEAD 2>/dev/null)"

    local changes=''
    if [[ "$git_prompt_info_var" != "" ]]; then
        if ! git diff --no-ext-diff --quiet; then
            changes='*'
        fi
        if ! git diff --no-ext-diff --cached --quiet; then
            changes="${changes}+"
        fi
    fi
    if [[ "$changes" != "" ]]; then
        git_prompt_info_var="$git_prompt_info_var:$changes"
    fi
    # Add right-padding if needed
    if [[ "$git_prompt_info_var" != "" ]]; then
        git_prompt_info_var="$git_prompt_info_var "
    fi
}


# NOTE that doing this will probably stomp over oh-my-zsh
precmd() {
    git_prompt_info
    virtualenv_prompt_info
}

# Put these calculations in an anonymous function so locals don't leak to
# environment when this script is sourced
function {
    local -r red=196
    # if $? == 0 then nothing else 'red '
    local -r return_code="%(?..$(color $red '%?') )"

    local -r orange=214
    local -r timestamp="$(color $orange '%D{%H:%M:%S.%. %Z}')"

    local -r purple=147
    local -r short_hostname="$(color $purple '%m')"

    local -r light_blue=45
    local -r current_directory="$(color $light_blue '%~')"

    local -r yellow=226
    # if UID == 0 then '#' else '$'
    local -r prompt_character="$(color $yellow '%(!.#.$)')"

    # an uninterpolated stirng (single quotes on purpose)
    # this var will undergo prompt_subst and be overwritten by precmd
    local -r green=47
    local -r virtualenv_prompt_info_var="$(color $green '$virtualenv_prompt_info_var')"

    local -r git_prompt_info_var="$(color $green '$git_prompt_info_var')"


    # NOTE: return code includes it's own spacing (so it doesn't go here)
    export VIRTUAL_ENV_DISABLE_PROMPT=1
    export PROMPT="$return_code$git_prompt_info_var$virtualenv_prompt_info_var$timestamp $short_hostname:$current_directory
$prompt_character "
}

unfunction color

# -- Aliases --

alias ls='ls -GF'
# if I have nvim, use it instead of vim
which nvim &> /dev/null && alias vim=nvim && alias vimdiff='nvim -d'

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
