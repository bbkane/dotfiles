# consider doing something special if connected via SSH: https://github.com/KorvinSilver/blokkzh/blob/master/blokkzh.zsh-theme#L49
# http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#Version-Control-Information
# prompt %vars: http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Prompt-Expansion
# url auto-complete, tetris: https://matt.blissett.me.uk/linux/zsh/zshrc
# https://unix.stackexchange.com/a/214699/185953

# -- Prompt --

# https://unix.stackexchange.com/a/40646/185953
setopt prompt_subst

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

# I'm getting these via https://github.com/sharkdp/pastel
# and https://gist.github.com/MicahElliott/719710#gistcomment-3180418 (  )
zp_color() {
    local -r color_code="$1"
    local -r text="$2"
    echo "%F{$color_code}$text%f"
}

zp_gen_colors_pastel(){
    local -r start="$1"
    local -r stop="$2"
    pastel gradient -n 7 "$start" "$stop" | pastel format hex
}

# this doesn't tend to produce very good looking prompts :(
zp_gen_colors_printf_random(){
    for i in {1..7}; do
        printf "#%06x\n" $RANDOM
    done
}

zp_prompt() {
    # must be a newline delimited string of colors with 7 elements
    local -r zsh_prompt_colors_str="$1"

    # if the string is empty, fall back
    if [[ -z "$zsh_prompt_colors_str" ]]; then
        local return_code_color=196  # red
        local virtualenv_prompt_info_var_color=47  # green
        local git_prompt_info_var_color=86  # cyan
        local timestamp_color=214  # burnt orange
        local short_hostname_color=147  # purple
        local current_directory_color=45  # light blue
        local prompt_character_color=226  # yellow
    else
        # we got a string; turn it into an array
        # https://unix.stackexchange.com/a/29748/185953
        local -r zsh_prompt_colors=("${(@f)zsh_prompt_colors_str}")

        local return_code_color="$zsh_prompt_colors[1]"
        local virtualenv_prompt_info_var_color="$zsh_prompt_colors[2]"
        local git_prompt_info_var_color="$zsh_prompt_colors[3]"
        local timestamp_color="$zsh_prompt_colors[4]"
        local short_hostname_color="$zsh_prompt_colors[5]"
        local current_directory_color="$zsh_prompt_colors[6]"
        local prompt_character_color="$zsh_prompt_colors[7]"
    fi

    # if $? == 0 then nothing else 'red '
    local -r return_code="%(?..$(zp_color $return_code_color '%?') )"

    # an uninterpolated string (single quotes on purpose)
    # this var will undergo prompt_subst and be overwritten by precmd
    local -r virtualenv_prompt_info_var="$(zp_color $virtualenv_prompt_info_var_color '$virtualenv_prompt_info_var')"

    # an uninterpolated string (single quotes on purpose)
    # this var will undergo prompt_subst and be overwritten by precmd
    local -r git_prompt_info_var="$(zp_color $git_prompt_info_var_color '$git_prompt_info_var')"

    local -r timestamp="$(zp_color $timestamp_color '%D{%H:%M:%S.%. %Z}')"

    local -r short_hostname="$(zp_color $short_hostname_color '%m')"

    local -r current_directory="$(zp_color $current_directory_color '%~')"

    # if UID == 0 then '#' else '$'
    local -r prompt_character="$(zp_color $prompt_character_color '%(!.#.$)')"

    # NOTE: return code includes it's own spacing (so it doesn't go here)
    export VIRTUAL_ENV_DISABLE_PROMPT=1
    export PROMPT="$return_code$virtualenv_prompt_info_var$git_prompt_info_var$timestamp $short_hostname:$current_directory
$prompt_character "
}

# meant to be used like:
# zp_prompt "$(zp_gen_colors_pastel pink gold)"
