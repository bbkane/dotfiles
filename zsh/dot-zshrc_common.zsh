# @bbkane's zsh dotfiles!
# Repo: https://github.com/bbkane/dotfiles

# -- Aliases --

# Need two sets of quotes
alias chrome='"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"'

# https://geoff.greer.fm/lscolors/
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=36;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
alias ls='ls -F --color=auto'
# 2023-05-04: warhol isn't coloring ls?
export warhol_ignore_ls=1

# if I have nvim, use it instead of vim
# https://stackoverflow.com/a/7522866/2958070
if type nvim > /dev/null; then
    export EDITOR=nvim
    alias vim=nvim
    alias vimdiff='nvim -d'
fi

# -- Exports --

# if EDITOR is not set (zsh > 5.3)
if [[ ! -v EDITOR ]]; then
    export EDITOR=nvim
fi

# groups | tr_space_to_newline
alias tr_space_to_newline="tr ' ' '\n'"

# interpret control codes with `less`
export LESS="-R"

export MYPY_CACHE_DIR="$HOME/.mypy_cache"

# https://github.com/sharkdp/bat#highlighting-theme
export BAT_THEME="1337"
export BAT_STYLE='plain,header,grid'

# for viewing OTEL traces with logdy (logdy.dev)
export LOGDY_CONFIG="$HOME/.config/logdy.json"

# rclone settings
# NOTE: these aren't tested :)
# I'm leaving dry-run on because I want that explicitly
# overridden. I think this will make the command silent, so I really hope I can figure out what's going on :)
# Also see https://www.bbkane.com/2017/07/18/RSync-From-Android.html
# export RCLONE_DRY_RUN=1
# export RCLONE_LOG_FILE="$HOME/tmp_rclone.log"
# export RCLONE_LOG_LEVEL='DEBUG'
# export RCLONE_PROGRESS=1
# export RCLONE_USE_JSON_LOG=1

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


# `readlink -f` doesn't work on Mac
fullpath() {
    local dirname=$(perl -e 'use Cwd "abs_path";print abs_path(shift)' "$1")
    echo "$dirname"
}

git_commit_pull_push() {
    # http://zsh.sourceforge.net/Doc/Release/Shell-Builtin-Commands.html#index-read
    if read -q "choice?Press Y/y to continue with commit and pull: "; then
        echo
        set -x
        git add . && git commit -m 'haha git go brrr' && git pull && git push
        { set +x; } 2>/dev/null
    else
        echo
        echo "'$choice' not 'Y' or 'y'. Exiting..."
    fi
}

# jq last file in ./logs - useful for JSON logs
jq_last_log() { jq "$1" $(find logs -print0 | xargs -0 ls -t -1 | head -n1) }

# recursively search markdown files
rgmd() { rg --type md --ignore-case "$@" }

# -- Other stuff --

# https://unix.stackexchange.com/a/34251/185953
# this checks $VISUAL, then $EDITOR to find an editor
# requires: autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# https://superuser.com/a/523973/643441
bindkey -e

# \e\e in front, otherwise bell sounds
# Option + Arrow keys
bindkey "\e\e[D" backward-word
bindkey "\e\e[C" forward-word

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

# Remove command from history if it starts with a space
# https://superuser.com/a/352858
setopt HIST_IGNORE_SPACE

# Enable autocorrect for command, but not for arguments
# https://superuser.com/a/610025/643441
unsetopt CORRECT_ALL
setopt CORRECT

# https://matt.blissett.me.uk/linux/zsh/zshrc
# Prompts for confirmation after 'rm *' etc
# Helps avoid mistakes like 'rm * o' when 'rm *.o' was intended
setopt RM_STAR_WAIT

# https://dev.to/manan30/what-is-the-best-zshrc-config-you-have-seen-14id
setopt auto_list # automatically list choices on ambiguous completion
setopt auto_menu # automatically use menu completion

# https://stackoverflow.com/a/11873793/2958070
setopt INTERACTIVECOMMENTS

# from zsh-newuser-install
setopt beep extendedglob nomatch notify

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

# cache completions - https://thevaluable.dev/zsh-completion-guide-examples/
zstyle ':completion:*' use-cache on
# NOTE: I also found ~/.zcompcache by accident. Not sure how that was created
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompcache"

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

if [[ "$OSTYPE" == darwin* ]]; then
    # Open commands in MacOS Preview app
    pman() { man -t "$@" | open -f -a Preview; }

    alias marktext="open -a /Applications/MarkText.app"

    # https://support.typora.io/Use-Typora-From-Shell-or-cmd/
    alias typora="open -a typora"

# elif [[ "$OSTYPE" == linux* ]]; then
fi

# https://news.ycombinator.com/item?id=42061773
if [[ "$OSTYPE" == darwin* ]]; then
    clip() { [ -t 0 ] && pbpaste || pbcopy }
else # assume linux if not macos
    # using xsel as I also need it for NeoVim
    clip() { [ -t 0 ] && xsel --clipboard --output || xsel --clipboard --input }
fi

# https://mil.ad/blog/2024/remote-clipboard.html
function clip-osc52() {
    printf "\033]52;c;%s\007" "$(base64 -w0 < /dev/stdin)"
}


# less options from https://litecli.com/output/
# -X leaves file contents on the screen when less exits.
# -F makes less quit if the entire output can be displayed on one screen.
# -R displays ANSI color escape sequences in “raw” form.
# -S disables line wrapping. Side-scroll to see long lines.
# NOTE: for some reason this isn't working, but $PAGER does
export PAGER="less -SRXF"

# https://unix.stackexchange.com/a/691245/185953
# --ignore : respect .gitignore
# --hidden : show files starting with '.', which includes .git/
# --glob '!.git/' : ignore .git/ directory
tree-git-seen() { rg --ignore --hidden --files --glob '!.git/' "$@" | tree --fromfile -a }

# Use a local copy of warg in current Go project (grabbit, etc.)
go_work_warg() {
    go work init .
    go work use -r ~/Git-GH/warg
}

# https://stackoverflow.com/a/30029855/2958070
port_listening() {
    if [ $# -eq 0 ]; then
        sudo lsof -iTCP -sTCP:LISTEN -n -P
    elif [ $# -eq 1 ]; then
        sudo lsof -iTCP -sTCP:LISTEN -n -P | grep -i --color $1
    else
        echo "Usage: listening [pattern]"
    fi
}

# https://stackoverflow.com/a/1115909/2958070
swap() {
    local TMPFILE=tmp.$$
    mv "$1" $TMPFILE && mv "$2" "$1" && mv $TMPFILE "$2"
}


# NOTE: hyper link on long links is broken... TODO: make an issue
gh_random_issue() {
gh search issues \
    --state open \
    --owner bbkane \
    --limit 100 \
    --json number,repository,title,updatedAt,url \
    --template '{{range .}}{{tablerow (printf "#%v" .number) (timeago .updatedAt) .repository.name (hyperlink .url (truncate 49 .title))}}{{"\n"}}{{end}}' \
| sed '/^$/d' \
| perl \
    -MList::Util=shuffle \
    -e 'print shuffle<STDIN>' \
| head \
    -10
}

# leaving out @$$ - too many false positives...
rg_swear_words() {
    rg -i $(base64 -d <<< "YmFzdGFyZHxiaXRjaHxkYW1ufGZ1Y2t8cGlzc3xzaGl0Cg==")
}

# https://stackoverflow.com/a/17581317/2958070
shuffle() {
    perl -MList::Util=shuffle -e 'print shuffle<STDIN>'
}

unquarantine() {
    xattr -r -d com.apple.quarantine "$1"
}

grabbit_audit() {
    find ~/Pictures/grabbit \( -name 'wallpapers_*' -o -name 'futureporn_*' -o -name 'roomporn_*' \) -ctime -14 -print -exec open {} \;
}

# Use pure Go builds!!
# export CGO_ENABLED=0
