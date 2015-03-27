# shut apt-get up
DEBIAN_FRONTEND=noninteractive

# get gedit for editing this
# sudo apt-get install gedit

: '
# get i3wm. Maybe I should change this to the fork?
 echo "deb http://debian.sur5r.net/i3/ $(lsb_release -c -s) universe" >> /etc/apt/sources.list
 apt-get update
 apt-get --allow-unauthenticated install sur5r-keyring
 apt-get update
 apt-get install i3
echo "You can now log out and log back in to i3"
'

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
'

: '
# get oh-my-zsh
sudo apt-get install zsh git
wget --no-check-certificate http://install.ohmyz.sh -O - | sh
chsh -s /bin/zsh
echo "**********now log out and log back in**********"
'

: '
# get janus
sudo apt-get -y install ack-grep ctags git ruby rake curl
curl -Lo- https://bit.ly/janus-bootstrap | bash
'

: '
# fix audio
sudo apt-get -y install pulseaudio-utils pulseaudio
echo "**********INSTRUCTIONS FOR SOUND FIX************"
echo "first, logout and log back in"
echo "follow these steps to get to the right output"
echo "pacmd list-sinks"
echo "find the one that says hdmi and copy it"
echo "It looks something like <alsa_output.pci-0000_01_00.1.hdmi-stereo>"
echo "pacmd set-default-sink <name of sink just found without angle brackets>"
'

: '
# doesnt work
# Test fix for audio
sudo apt-get -y install pulseaudio-utils pulseaudio
# double quotes might not work here ...
RIGHT_SINK=`pacmd list-sinks | grep -E "name:*hdmi"`
# pass RIGHT_SINK to sed to get rid of angle brackets
RIGHT_SINK=`sed "s/^<//; s/>$//" $RIGHT_SINK
#pacmd set-default-sink $RIGHT_SINK
echo "$RIGHT_SINK"
'

: '
# get programs from my README
sudo apt-get -y install kupfer # dont think I need this anymore. I do. gnome do freezes my pc.
sudo apt-get -y install feh compton  xbindkeys
sudo apt-get -y install x11-xkb-utils # for setxkbmap for ditching CAPS
# eclipse is a large download
sudo apt-get -y install stow
# The repo eclipse is old. Use http://ubuntuhandbook.org/index.php/2014/06/install-latest-eclipse-ubuntu-14-04/ instead
sudo apt-get -y install vlc
# clang3.3 is already installed by anaconda. If I need clang3.5, I can use the full name
'

: '
# Now it takes sudo to change zsh stuff. Must update this. Later.
# get config files
git clone --recursive https://github.com/bbk1524/backup.git
cd ~/backup
stow common
rm ~/.zshrc ~/.i3/config
# move bootstrap
rm ~/backup/tower/bootsrap.sh
mv ~/bootstrap.sh ~/backup/tower/
stow tower
echo " a note: .xprofile messes up my clock and stuff with LXDE. This is fixed later."
echo "To fix the start panels length, right click it->Panel Settings->Width->1920 pixels"
echo " change Terminal font to an appropriate size. LXTerminal->Edit->Style->Terminal font"
cd ~/backup/manually_symlink
sudo stow tower_bin -t /usr/local/bin
'

: '
# this might need a better url if it gets updated.
cd ~
wget http://repo.continuum.io/anaconda3/Anaconda3-2.1.0-Linux-x86_64.sh
bash Anaconda3-2.1.0-Linux-x86_64.sh -b
'

: '
# start getting wallpapers!!
cd ~
git clone https://github.com/EndlesslyCurious/RedditImageGrab.git
python2 ~/RedditImageGrab/redditdownload.py earthporn ~/Pictures/Wallpapers -score 1000 -num 25
python2 ~/RedditImageGrab/redditdownload.py cityporn ~/Pictures/Wallpapers -score 1000 -num 25
'

#echo "get firefox addons: vimperator, adblock plus, Reddit Enhancement Suite"

: '
#lets install steam...
cd ~
wget http://media.steampowered.com/client/installer/steam.deb
sudo apt-get -y install gdebi-core 
sudo gdebi steam.deb
echo "run Steam, then erase its gcc with the next set of commands"
'

: '
# lets erase steams old gcc
echo "Erasing steam crud"
# This is all I needed to erase.. Leaving the rest commented
rm ~/.steam/bin32/steam-runtime/i386/usr/lib/i386-linux-gnu/libstdc++.so.6
rm ~/.steam/bin32/steam-runtime/i386/lib/i386-linux-gnu/libgcc_s.so.1
rm ~/.steam/bin32/steam-runtime/amd64/lib/x86_64-linux-gnu/libgcc_s.so.1
rm ~/.steam/bin32/steam-runtime/amd64/usr/lib/x86_64-linux-gnu/libstdc++.so.6
rm ~/.steam/bin32/steam-runtime/i386/usr/lib/i386-linux-gnu/libxcb.so.1
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
# The controls need serious reconfigs. How?
'
: '
# haskell Stuff
# sudo apt-get -y install haskell-platform
cabal update
cabal install ghc-mod
'

: '
# set up git
git config --global user.email "bbk1524@gmail.com"
git config --global user.name "Ben-Lubuntu"
git config --global push.default matching
'

: '
echo "make power commands non-sudo"
echo "add this in /etc/sudoers via"
echo "visudo"
echo "%sudo ALL = NOPASSWD: /sbin/shutdown, /sbin/poweroff, /sbin/reboot"
echo "dont forget the commas"
'

: '
echo "use lxappearance to set a gtk theme"
echo "download a theme (right now Im using delorean-dark-3.10) to ~/.themes"
echo "kupfer cant find lxappearance, so type it into the terminal to open it"
# themes found at:	 http://www.noobslab.com/p/themes-icons.html#icons
#sudo apt-add-repository ppa:noobslab/themes
#sudo apt-get update
# sudo apt-get install polar-night-gtk
# get icon themes
sudo apt-add-repository ppa:numix/ppa
sudo apt-get update
sudo apt-get install numix-icon-theme numix-icon-theme-circle
'

: '
echo "User Icon: .face should be a square .png in my backup/tower"

# sudo ln -s /home/ben/.login-wallpaper /usr/share/lubuntu/wallpapers/login-wallpaper
echo "edit /etc/lightdm/lightdm-gtk-greeter.conf"
echo "the line that says background should read"
echo "\t background=/usr/share/lubuntu/wallpapers/login-wallpaper"
echo "now simply save the wallpaper as ~/.login-wallpaper, and LightDM will find it."
'

: '
# get eclipse luna
sudo apt-get install openjdk-8-jdk
# download eclipse to home folder http://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/luna/SR1/eclipse-java-luna-SR1-linux-gtk-x86_64.tar.gz
cd ~
#tar -xzvf name of tarfile
# change how it looks in Window->Preferences->General->Appearance
'

: '
# get haroopad for markdown
cd ~/Downloads/
wget https://bitbucket.org/rhiokim/haroopad-download/downloads/haroopad-v0.13.0-x64.deb
sudo gdebi haroopad-v0.13.0-x64.deb
'

#: '
# begin Conky stuff
sudo apt-get install conky