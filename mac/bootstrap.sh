#xcode-select --install
#sudo gcc --version

: '
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
'
#echo export PATH='/usr/local/bin:$PATH' >> ~/.bash_profile

: '
echo "hi"
brew install caskroom/cask/brew-cask
brew cask doctor
'

: '
echo "hi"
brew install git
git config --global user.email "bbk1524@gmail.com"
git config --global user.name "Ben-MacbookPro"
git config --global push.default matching
'

#brew install vim macvim
#brew linkapps macvim
#brew install ack
#curl -Lo- https://bit.ly/janus-bootstrap | bash

#brew install zsh
#echo "change shells through preferences in GDoc, then restart"
#curl -L http://install.ohmyz.sh | sh

: '
brew install stow
rm .zshrc
cd ~
git clone --recursive https://github.com/bbk1524/backup.git
cd backup
stow common
stow mac
'
#brew install clisp pandoc wget fdupes httrack

: '
cd ~
#curl -O http://repo.continuum.io/anaconda3/Anaconda3-2.1.0-MacOSX-x86_64.sh
#bash ~/Anaconda3-2.1.0-MacOSX-x86_64.sh
'
#brew cask install firefox skim dropbox google-drive functionflip skype transmission vlc eclipse-java
#brew cask install alfred
# echo add Caskroom to Alfed manually
#echo install the latest JDK from the website
#brew cask cleanup
# activate function flip
#brew cask install openemu


#: '
# start getting wallpapers!!
cd ~
#git clone https://github.com/EndlesslyCurious/RedditImageGrab.git
python2.7 ~/RedditImageGrab/redditdownload.py earthporn ~/Pictures/Wallpapers -score 1000 -num 25
#'
