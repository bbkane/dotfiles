: '
# get i3wm
 echo "deb http://debian.sur5r.net/i3/ $(lsb_release -c -s) universe" >> /etc/apt/sources.list
 apt-get update
 apt-get --allow-unauthenticated install sur5r-keyring
 apt-get update
 apt-get install i3
'

: '
echo "inside commented part"
#get vim (from YouCompleteMe stuff
sudo apt-get install libncurses5-dev libgnome2-dev libgnomeui-dev \
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
'

: '
# get oh-my-zsh
sudo apt-get install zsh git
wget --no-check-certificate http://install.ohmyz.sh -O - | sh
chsh -s /bin/zsh
echo "now log out and log back in"
'
: '
# get janus
sudo apt-get install ack-grep ctags git ruby rake curl
curl -Lo- https://bit.ly/janus-bootstrap | bash
'

: '
# fix audio
sudo apt-get install pulseaudio-utils pulseaudio
##follow these steps to get to the right output
# pacmd list-sinks
## find the one that says hdmi and copy it
# pacmd set-default-sink <name of sink just found>
'
: '
# get programs from my README
sudo apt-get install kupfer feh compton  xbindkeys
sudo apt-get install x11-xkb-utils # for setxkbmap for ditching CAPS
sudo apt-get install stow
'
: '
git clone --recursive https://github.com/bbk1524/backup.git
cd ~/backup
stow common
rm ~/.zshrc ~/.i3/config
stow tower
'
: '
cd ~
wget http://repo.continuum.io/anaconda3/Anaconda3-2.1.0-Linux-x86_64.sh
bash Anaconda3-2.1.0-Linux-x86_64.sh
'

