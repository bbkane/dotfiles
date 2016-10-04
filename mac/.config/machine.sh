# Homebrew
homebrew_bin_dir="/usr/local/bin"
export PATH="${homebrew_bin_dir}:$PATH"

# TODO: make this generic? prepend_to_path?
# Making anaconda functional so I can rm it when homebrew whines
anaconda_bin_dir="$HOME/anaconda3/bin"
add_anaconda() {
    if [[ "$PATH" != *"${anaconda_bin_dir}"* ]]; then
        export PATH="${anaconda_bin_dir}:$PATH"
    fi
}

rm_anaconda() {
    export PATH=$(echo $PATH | sed 's|'"${anaconda_bin_dir}:"'||g')
}

# add it by default
add_anaconda

# make vim use ycm
export vim_ide_status='ycm'

perlbrew_bashrc="$HOME/perl5/perlbrew/etc/bashrc"
[[ -e "${perlbrew_bashrc}" ]] && source "${perlbrew_bashrc}"

stack_bin_dir="$HOME/.local/bin"
[[ -d  "${stack_bin_dir}" ]] && export PATH="${stack_bin_dir}:$PATH"
