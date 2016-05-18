## Common
# Installs
# sudo apt-add-repository ppa:neovim-ppa/unstable
# sudo apt-get update
# sudo apt-get install neovim git stow zsh

# Install Miniconda. Could also use Anaconda by visiting the site
#cd ~
# wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
# bash Miniconda3-latest-Linux-x86_64.sh
# install before Oh-My-ZSH so the path automatically gets added

# Install Oh-My-ZSH
# sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

# DotFiles
# cd ~
# git clone https://github.com/bbkane/backup.git
# cd ~/backup
# stow common
# echo 'source ~/.benshellrc' >> ~/.zshrc

## Network
 # sudo apt-get install openssh-server

# Neovim optional deps
 # sudo apt-get install xsel
# Pyhon deps
# Inside Neovim run:
# - PlugInstall
# - call Nvim functions

# Neovim YouCompleteme
# I want to use the system python for YCM, and Miniconda for jedi
# REMOVE MINICONDA FROM PATH
# sudo apt-get install python-dev python-pip
# pip install neovim
# sudo apt-get install build-essential cmake
# sudo apt-get install nodejs npm
# sudo npm install -g typescript
# sudo ln -s /usr/bin/nodejs /usr/bin/node
# curl -sSf https://static.rust-lang.org/rustup.sh | sh
# cd ~/.vim/bundle/YouCompleteMe/
# ./install.py --clang-completer --tern-completer --racer-completer
# 
