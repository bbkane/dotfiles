# shut apt-get up
DEBIAN_FRONTEND=noninteractive

cd ~

#INSTALLS

: '
# get programs from my README
sudo apt-get -y install xbindkeys
sudo apt-get -y install x11-xkb-utils # for setxkbmap for ditching CAPS
sudo apt-get -y install stow
# clang3.3 is already installed by anaconda. If I need clang3.6, I can use the full name
sudo apt-get -y install zsh git
sudo apt-get -y install build-essential python-dev cmake
# I want to install clang-format and clang-modernize too
'

: '
echo "get python from https://www.continuum.io/downloads"
'

# cd ~
# wget https://cmake.org/files/v3.4/cmake-3.4.0-Linux-x86_64.sh
# echo "Install with 'bash <name of cmake> --prefix=$HOME/bin --include-subdir"

# echo "get clang from ppa. it's on firefox somewhere"
# echo "get firefox addons: vimperator, adblock plus, reddit enhancement suite"

# eclipse
: '
# get eclipse luna
sudo apt-get install openjdk-8-jdk
# download eclipse to home folder
cd ~
#tar -xzvf name of tarfile
# change how it looks in Window->Preferences->General->Appearance
'

# neovim
: '
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install neovim
# look at https://github.com/neovim/neovim/wiki/Installing-Neovim for python stuff
'

# i3wm
: '
# get i3wm. Maybe I should change this to the fork?
sudo echo "deb http://debian.sur5r.net/i3/ $(lsb_release -c -s) universe" >> /etc/apt/sources.list
sudo apt-get update
sudo apt-get --allow-unauthenticated install sur5r-keyring
sudo apt-get update
sudo apt-get install i3
echo "@@@@@@@@@You can now log out and log back in to i3@@@@@@@@@"
'

#gcc
# sudo add-apt-repository ppa:ubuntu-toolchain-r/test
# sudo apt-get update
# sudo apt-get install gcc-4.9 g++-4.9

# These commands have to be repeated
# sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 20
# sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 20
# sudo update-alternatives --remove-all gcc
# sudo update-alternatives --remove-all g++
# sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 20
# sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 20
# sudo update-alternatives --config gcc
# sudo update-alternatives --config g++

# BUILDS

# get oh-my-zsh
: '
wget --no-check-certificate http://install.ohmyz.sh -O - | sh
chsh -s /bin/zsh
echo "@@@@@@@@@@ ZSH installed. Logout and log back in!! @@@@@@@@@@@"
'

# CONFIG

# Stow common things
: '
# Now it takes sudo to change zsh stuff. Must update this. Later.
# get config files
cd ~/backup
rm ~/.zshrc # ~/.i3/config
stow common
# move bootstrap that Ive downloaded and continually worked on to the repo
stow mint
'

# sudo ln -s /usr/bin/clang++-3.6 /usr/bin/clang++
sudo ln -s /usr/bin/clang-3.6 /usr/bin/clang
# sudo ln -s /usr/bin/vim /usr/bin/nvim

# nvim things (I wan to try to make it compatible with vim)

# These should be done after stowing the files :)
# mkdir -p ${XDG_CONFIG_HOME:=$HOME/.config}
# ln -s ~/.vim $XDG_CONFIG_HOME/nvim
# ln -s ~/.vimrc $XDG_CONFIG_HOME/nvim/init.vim
# ln -s ~/.vimrc-ben $XDG_CONFIG_HOME/nvim/vimrc-ben

: '
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 1
sudo update-alternatives --set editor /usr/bin/nvim
sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 1
sudo update-alternatives --set vi /usr/bin/nvim
'

: '
# set up git
git config --global user.email "bbk1524@gmail.com"
git config --global user.name "Ben-Mint"
git config --global push.default matching
'

# echo "make power commands non-sudo"
# echo "add this in /etc/sudoers via"
# echo "visudo"
# echo "%sudo ALL = NOPASSWD: /sbin/shutdown, /sbin/poweroff, /sbin/reboot"
# echo "dont forget the commas"


# NON_IMPORTANT STUFF :D

: '
# haskell Stuff
# sudo apt-get -y install haskell-platform
#cabal update
#cabal install ghc-mod
'

# echo "use lxappearance to set a gtk theme"
# echo "download a theme (right now Im using delorean-dark-3.10) to ~/.themes"
# echo "kupfer cant find lxappearance, so type it into the terminal to open it"
# # themes found at:	 http://www.noobslab.com/p/themes-icons.html#icons
# sudo apt-add-repository ppa:noobslab/themes
# sudo apt-get update
# sudo apt-get install polar-night-gtk
# get icon themes
# sudo apt-add-repository ppa:numix/ppa
# sudo apt-get update
# sudo apt-get install numix-icon-theme numix-icon-theme-circle

: '
# start getting wallpapers!!
cd ~
git clone https://github.com/EndlesslyCurious/RedditImageGrab.git
python2 ~/RedditImageGrab/redditdownload.py earthporn ~/Pictures/Wallpapers -score 1000 -num 25
python2 ~/RedditImageGrab/redditdownload.py cityporn ~/Pictures/Wallpapers -score 1000 -num 25
'

