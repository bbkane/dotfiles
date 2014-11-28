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
#sudo apt-get install kupfer # dont think I need this anymore. I do. gnome do freezes my pc.
sudo apt-get install feh compton  xbindkeys
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
# this might need a better url if it gets updated.
cd ~
wget http://repo.continuum.io/anaconda3/Anaconda3-2.1.0-Linux-x86_64.sh
bash Anaconda3-2.1.0-Linux-x86_64.sh
'

: '
# start getting wallpapers!!
git clone https://github.com/EndlesslyCurious/RedditImageGrab.git
python2 ~/RedditImageGrab/redditdownload.py earthporn ~/Pictures/Wallpapers -score 1000 -num 25
'

# get firefox addons: vimperator, adblock plus, Reddit Enhancement Suite

# get more programs (integrate into readme)
#sudo apt-get install eclipse #eclipse is HUGE!!
# clang3.3 is already installed by anaconda. If I need clang3.5, I can use the full name

: '
# This did not work!!! Im going to add the PPA instead. Dolphin is really glitchy... Keeps quittin on me...
# install dolphin for wii and gamecube
#sudo apt-get install cmake git g++ wx2.8-headers libwxbase2.8-dev libwxgtk2.8-dev libwxgtk3.0-dev libgtk2.0-dev libsdl1.2-dev libxrandr-dev libxext-dev libao-dev libasound2-dev libpulse-dev libbluetooth-dev libreadline-gplv2-dev libavcodec-dev libavformat-dev libswscale-dev libsdl2-dev libusb-1.0-0-dev
#git clone https://github.com/dolphin-emu/dolphin.git
cd ~/dolphin
#mkdir Build && cd Build
#cmake ..
cd ~/dolphin/Build/
make
sudo make install
'
: '
#add PPA
sudo add-apt-repository ppa:glennric/dolphin-emu
sudo apt-get update
sudo apt-get install dolphin-emu-master 

# install an antivirus for ROMs
#This didnt work either....
sudo apt-get install clamav
#update definitions
freshclam
'
: '
# install unrar
sudo apt-get install unrar
# install tools for 7z
sudo apt-get install p7zip
'

# try pcsx2. That didnt work either.... no package available!
#sudo apt-add-repository ppa:gregory-hainaut/pcsx2.official.ppa
#sudo apt-get update
#sudo apt-get install pcsx2

: '
#lets install steam...
cd ~
wget http://media.steampowered.com/client/installer/steam.deb
sudo apt-get install gdebi-core 
sudo gdebi steam.deb

# lets erase steams old gcc
rm ~/.steam/bin32/steam-runtime/i386/usr/lib/i386-linux-gnu/libstdc++.so.6
rm ~/.steam/bin32/steam-runtime/i386/lib/i386-linux-gnu/libgcc_s.so.1
rm ~/.steam/bin32/steam-runtime/amd64/lib/x86_64-linux-gnu/libgcc_s.so.1
rm ~/.steam/bin32/steam-runtime/amd64/usr/lib/x86_64-linux-gnu/libstdc++.so.6
rm ~/.steam/bin32/steam-runtime/i386/usr/lib/i386-linux-gnu/libxcb.so.1
#  now steam wont open...
# If I use kupfer to launch steam on i3, it works... Hmmm. I can run games and everything! Yay!
'
: '
#get retroarch. http://emulation-general.wikia.com/wiki
/Using_RetroArch
#http://filthypants.blogspot.com/
sudo add-apt-repository ppa:hunter-kaller/ppa
#sudo apt-get update
sudo apt-get install retroarch
sudo apt-get install libretro* #get all cores. Thats how I roll
'
: '
# lets try the repo on the website
sudo apt-add-repository ppa:libretro/stable
sudo apt-get upgrade
sudo apt-get install retroarch
sudo apt-get install retroarch-joypad-autoconfig
# Ok that worked. Some notes:
# cores can be found on https://launchpad.net/~libretro/+archive/ubuntu/stable
# Dont need to config anything. Google if I do for BIOS etc
'
