# @bbkane's zsh prompt! Lots of borrowed (and hopefully cited) ideas!
# Repo: https://github.com/bbkane/dotfiles

# Features:
# - customizable colors
# - python virtualenv support
# - git support
# - shows non-zero return codes
# - subsecond timestamp and timezone
# - only ASCII characters (paste into non-unicode-friendly apps like JIRA)
# - hostname and directory in format ready to copy for SSH or SCP
# Requires:
# - zsh --version > 1.7.1 (if hex color codes desired - not tested on lower versions - 8bit might work)
# - git --version >= 2.2.1 (for showing branch easily)
# Usage:
#   zp_prompt  # default 8bit colors
#   zp_prompt "$(zp_gen_colors_printf_random)"
#   # newline delimited string of 7 colors
#   zp_prompt $'#743eb1\n#743eb1\n#743eb1\n#743eb1\n#743eb1\n#743eb1\n#743eb1\n'
#   # Use pastel for prettier colors: https://github.com/sharkdp/pastel
#   zp_prompt "$(pastel gradient -n 7 dodgerblue lightgreen | pastel format hex)"
#   zp_prompt "$(pastel random -n 7 | pastel format hex)"

# -- Functions  --

# helper function to echo colors
zp_color() {
    local -r color_code="$1"
    local -r text="$2"
    echo "%F{$color_code}$text%f"
}

# generate random colors for zp_prompt
# this doesn't tend to produce very good looking prompts :(
zp_gen_colors_printf_random(){
    for i in {1..7}; do
        printf "#%06x\n" $RANDOM
    done
}

# create and assign to PROMPT
zp_prompt() {
    # must be a newline delimited string of colors with 7 elements
    local zsh_prompt_colors_str="$1"

    # if the string is empty, fall back to 8bit colors
    if [[ -z "$zsh_prompt_colors_str" ]]; then
        zsh_prompt_colors_str=$'196\n47\n86\n214\n147\n45\n226\n'
    fi

    # we got a newline delimited string; turn it into an array
    # https://unix.stackexchange.com/a/29748/185953
    local -r zsh_prompt_colors=("${(@f)zsh_prompt_colors_str}")

    local return_code_color="$zsh_prompt_colors[1]"
    local zp_venv_precmd_var_color="$zsh_prompt_colors[2]"
    local zp_git_precmd_var_color="$zsh_prompt_colors[3]"
    local timestamp_color="$zsh_prompt_colors[4]"
    local short_hostname_color="$zsh_prompt_colors[5]"
    local current_directory_color="$zsh_prompt_colors[6]"
    local prompt_character_color="$zsh_prompt_colors[7]"

    # prompt vars: http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Prompt-Expansion

    # if $? == 0 then nothing else 'red '
    local -r return_code="%(?..$(zp_color $return_code_color '%?') )"

    # an uninterpolated string (single quotes on purpose)
    # this var will undergo prompt_subst and be overwritten by precmd
    local -r zp_venv_precmd_var="$(zp_color $zp_venv_precmd_var_color '$zp_venv_precmd_var')"

    # an uninterpolated string (single quotes on purpose)
    # this var will undergo prompt_subst and be overwritten by precmd
    local -r zp_git_precmd_var="$(zp_color $zp_git_precmd_var_color '$zp_git_precmd_var')"

    local -r timestamp="$(zp_color $timestamp_color '%D{%H:%M:%S.%. %Z}')"

    local -r short_hostname="$(zp_color $short_hostname_color '%m')"

    local -r current_directory="$(zp_color $current_directory_color '%~')"

    # if UID == 0 then '#' else '$'
    local -r prompt_character="$(zp_color $prompt_character_color '%(!.#.$)')"

    # NOTE: optional things return their own spacing
    export PROMPT="$return_code$zp_venv_precmd_var$zp_git_precmd_var$timestamp $short_hostname:$current_directory
$prompt_character "
}

# make an easy way to set the prompt via pastel
# zp_prompt_pastel red white blue
zp_prompt_pastel() {
    zp_prompt "$(pastel gradient -n 7 "$@" | pastel format hex)"
}

# -- Precmd Stuff --
# use precmds to update the prompt before every command

# sets `zp_venv_precmd_var`.
zp_venv_precmd() {
    # https://github.com/ohmyzsh/ohmyzsh/blob/96f4a938383e558e8f800ccc052a80c6f743555d/plugins/virtualenv/virtualenv.plugin.zsh
    zp_venv_precmd_var=''
    # -n means length of string is non-zero
    if [[ -n $VIRTUAL_ENV ]]; then
        # "${VIRTUAL_ENV:t}" == "$(basename $VIRTUAL_ENV)"
        zp_venv_precmd_var="${VIRTUAL_ENV:t} "
    fi
}

# sets `zp_git_precmd_var`
zp_git_precmd() {
    # https://stackoverflow.com/a/56501750/2958070
    # git >= 2.21, doesn't work in detatched head mode
    zp_git_precmd_var="$(git branch --show-current 2>/dev/null)"

    local changes=''
    if [[ "$zp_git_precmd_var" != "" ]]; then
        if ! git diff --no-ext-diff --quiet; then
            changes='*'
        fi
        if ! git diff --no-ext-diff --cached --quiet; then
            changes="${changes}+"
        fi
    fi
    if [[ "$changes" != "" ]]; then
        zp_git_precmd_var="$zp_git_precmd_var:$changes"
    fi
    # Add right-padding if needed
    if [[ "$zp_git_precmd_var" != "" ]]; then
        zp_git_precmd_var="$zp_git_precmd_var "
    fi
}

# http://zsh.sourceforge.net/Doc/Release/User-Contributions.html
# https://stackoverflow.com/q/30840651/2958070
# see loaded precmds with `add-zsh-hook -L`
# requires: autoload -Uz add-zsh-hook
add-zsh-hook precmd zp_git_precmd
add-zsh-hook precmd zp_venv_precmd

# https://unix.stackexchange.com/a/40646/185953
setopt prompt_subst

# tell venv we want to do our own formatting
export VIRTUAL_ENV_DISABLE_PROMPT=1

