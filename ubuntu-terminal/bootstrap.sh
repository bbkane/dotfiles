# Use by cloning, cd-ing into the correct folder, then running bootstrap

# shut apt-get up
DEBIAN_FRONTEND=noninteractive

: '
#get vim (from YouCompleteMe stuff)
sudo apt-get -y install libncurses5-dev libgnome2-dev libgnomeui-dev \
    libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
    libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev \
    ruby-dev mercurial

sudo apt-get remove vim vim-runtime gvim
sudo apt-get remove vim-tiny vim-common vim-gui-common

cd ~
hg clone https://code.google.com/p/vim/
cd vim
./configure --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp \
            --enable-pythoninterp \
            --with-python-config-dir=/usr/lib/python2.7/config \
            --enable-perlinterp \
            --enable-luainterp \
            --enable-gui=gtk2 --enable-cscope --prefix=/usr

make VIMRUNTIMEDIR=/usr/share/vim/vim74
sudo make install

sudo update-alternatives --install /usr/bin/editor editor /usr/bin/vim 1
sudo update-alternatives --set editor /usr/bin/vim
sudo update-alternatives --install /usr/bin/vi vi /usr/bin/vim 1
sudo update-alternatives --set vi /usr/bin/vim
echo "@@@@@@@@@@@@@ Vim is now built! @@@@@@@@@@@@@@"

# get oh-my-zsh
sudo apt-get install zsh git
wget --no-check-certificate http://install.ohmyz.sh -O - | sh
sudo chsh -s /bin/zsh
echo "@@@@@@@@@@ ZSH installed. Logout and log back in!! @@@@@@@@@@@"
'

echo "@@@@@@@@@@@@@@ GET ANACONDA FOR PYTHON @@@@@@@@@@@@@"

: '
# get programs from my README
sudo apt-get -y install xbindkeys
sudo apt-get -y install x11-xkb-utils # for setxkbmap for ditching CAPS
sudo apt-get -y install stow
# clang3.3 is already installed by anaconda. If I need clang3.6, I can use the full name
sudo apt-get -y install clang-3.6
# I want to install clang-format and clang-modernize too
'

: '
# Now it takes sudo to change zsh stuff. Must update this. Later.
# get config files
cd ~/backup
# rm ~/.zshrc ~/.i3/config
stow common
# move bootstrap that Ive downloaded and continually worked on to the repo
stow ubuntu-terminal
cd ~/backup/manually_symlink
sudo stow lubuntu_bin -t /usr/local/bin
'

 
# set up git
git config --global user.email "bbk1524@gmail.com"
git config --global user.name "Ben-Lubuntu"
git config --global push.default matching


echo "make power commands non-sudo"
echo "add this in /etc/sudoers via"
echo "visudo"
echo "%sudo ALL = NOPASSWD: /sbin/shutdown, /sbin/poweroff, /sbin/reboot"
echo "dont forget the commas"


