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
    # This doesn't pick up just init-ed repos
    # git_prompt_info_var="$(git describe --contains --all HEAD 2>/dev/null)"
    # I think this only works for newer versions of git
    git_prompt_info_var="$(git branch --show-current 2>/dev/null)"

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

    local -r cyan=86
    local -r git_prompt_info_var="$(color $cyan '$git_prompt_info_var')"

    # NOTE: return code includes it's own spacing (so it doesn't go here)
    export VIRTUAL_ENV_DISABLE_PROMPT=1
    export PROMPT="$return_code$git_prompt_info_var$virtualenv_prompt_info_var$timestamp $short_hostname:$current_directory
$prompt_character "
}

unfunction color

