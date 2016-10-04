# Homebrew
homebrew_bin_dir="/usr/local/bin"
export PATH="${homebrew_bin_dir}:$PATH"

# Should these go in .zshenv?
anaconda_bin_dir="/Users/bbkane/anaconda3/bin"
export PATH="${anaconda_bin_dir}:$PATH"

# make vim use ycm
export vim_ide_status='ycm'

perlbrew_bashrc="$HOME/perl5/perlbrew/etc/bashrc"
[[ -e "${perlbrew_bashrc}" ]] && source "${perlbrew_bashrc}"

stack_bin_dir="$HOME/.local/bin"
[[ -d  "${stack_bin_dir}" ]] && export PATH="${stack_bin_dir}:$PATH"
