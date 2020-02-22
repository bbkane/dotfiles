# play with colors at https://zsh-prompt-generator.site/
# consider doing something special if connected via SSH: https://github.com/KorvinSilver/blokkzh/blob/master/blokkzh.zsh-theme#L49
# http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#Version-Control-Information
# prompt %vars: http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Prompt-Expansion
# url auto-complete, tetris: https://matt.blissett.me.uk/linux/zsh/zshrc
# https://unix.stackexchange.com/a/214699/185953

# -- Prompt --

# https://unix.stackexchange.com/a/40646/185953
setopt prompt_subst

# I'm getting these via https://github.com/sharkdp/pastel
# and https://gist.github.com/MicahElliott/719710#gistcomment-3180418 (  )
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
    # https://stackoverflow.com/a/56501750/2958070
    # git >= 2.21, doesn't work in detatched head mode
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


# TODO: that doing this will probably stomp over oh-my-zsh
# There should be a way to use an array for these
precmd() {
    git_prompt_info
    virtualenv_prompt_info
}

# Put these calculations in an anonymous function so locals don't leak to
# environment when this script is sourced
function {
    # return_code_color=
    # virtualenv_prompt_info_var_color=
    # git_prompt_info_var_color=
    # timestamp_color=
    # short_hostname_color=
    # current_directory_color=
    # prompt_character_color=

    local current_color

    # current_color=196  # red
    current_color='#da0b0b'
    # if $? == 0 then nothing else 'red '
    local -r return_code="%(?..$(color $current_color '%?') )"

    # current_color=47  # green
    current_color='#ff8c00'  # darkorange
    # an uninterpolated string (single quotes on purpose)
    # this var will undergo prompt_subst and be overwritten by precmd
    local -r virtualenv_prompt_info_var="$(color $current_color '$virtualenv_prompt_info_var')"

    # current_color=86  # cyan
    current_color='#ffd700'  # gold
    # an uninterpolated string (single quotes on purpose)
    # this var will undergo prompt_subst and be overwritten by precmd
    local -r git_prompt_info_var="$(color $current_color '$git_prompt_info_var')"

    # current_color=214  # burnt orange
    current_color='#73da0b'
    local -r timestamp="$(color $current_color '%D{%H:%M:%S.%. %Z}')"

    # current_color=147  # purple
    current_color='#40e0d0'  # turquoise
    local -r short_hostname="$(color $current_color '%m')"

    # current_color=45  # light blue
    current_color='#1e90ff'  # dodgerblue
    local -r current_directory="$(color $current_color '%~')"

    # current_color=226  # yellow
    current_color='#9932cc'  # darkorchid
    # if UID == 0 then '#' else '$'
    local -r prompt_character="$(color $current_color '%(!.#.$)')"

    # NOTE: return code includes it's own spacing (so it doesn't go here)
    export VIRTUAL_ENV_DISABLE_PROMPT=1
    export PROMPT="$return_code$virtualenv_prompt_info_var$git_prompt_info_var$timestamp $short_hostname:$current_directory
$prompt_character "
}

unfunction color

