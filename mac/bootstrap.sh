: '
# install command line tools and xcode
#xcode-select --install
#sudo xcodebuild -license
'

: '
# install Homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
'
#echo export PATH='/usr/local/bin:$PATH' >> ~/.bash_profile

: '
# install Homebrew cask for graphical apps
brew install caskroom/cask/brew-cask
brew cask doctor
'

: '
# Install Git
brew install git
git config --global user.email "bbk1524@gmail.com"
git config --global user.name "Ben-MacbookPro"
git config --global push.default matching
'

: '
# get vim , macvim, and janus
brew install vim macvim
brew linkapps macvim
brew install ack
curl -Lo- https://bit.ly/janus-bootstrap | bash
'

: '
# install oh-my-zsh. This might need work
brew install zsh
echo "change shells through preferences in GDoc, then restart"
curl -L http://install.ohmyz.sh | sh
'

: '
# Get Anaconda for python
cd ~
curl -O http://repo.continuum.io/anaconda3/Anaconda3-2.1.0-MacOSX-x86_64.sh
bash ~/Anaconda3-2.1.0-MacOSX-x86_64.sh
'

: '
# Get my dotfiles
brew install stow
rm .zshrc
cd ~
git clone --recursive https://github.com/bbk1524/backup.git
cd backup
stow common
stow mac
'

: '
# get Lisp
brew install clisp
# pandoc is for latex, markdown, etc
brew install pandoc
# wget is for downloading power!!!
brew install wget
# fdupes erases duplicates in a folder
brew install fdupes
# httrack lets you mirror a website easily. Use in a empty folder
brew install httrack
'

: '
# obvious installs
brew cask install firefox dropbox google-drive skype vlc
# skim is a really good pdf reader with note exporting abilies I like
brew cask install skim
# functionflip is useful for F5 (compile and run in spyder and eclipse)
brew cask install functionflip
echo activate function flip for F5
# transmission is a torrent client. Yay
brew cask install transmission
# eclipse is huge. Worth it though
brew cask install eclipse-java
echo install the latest JDK from the website
# Alfred replaces Spotlight Search. Can run applescripts on search
brew cask install alfred
echo add Caskroom to Alfed manually
# clean up leftovers
brew cask cleanup
# openemu is a one shop stop emulator frontend for SNES, GBA, etc
#brew cask install openemu
'

: '
# start getting wallpapers!!
cd ~
git clone https://github.com/EndlesslyCurious/RedditImageGrab.git
python2.7 ~/RedditImageGrab/redditdownload.py earthporn ~/Pictures/Wallpapers -score 1000 -num 25
echo Change Wallpaper settings in Preferences
'
