# General Notes

This is stuff I'll forget if I'm not careful.

## Make it so git only asks for password when I push
[](http://superuser.com/questions/199507/how-do-i-ensure-git-doesnt-ask-me-for-my-github-username-and-password)

```
git config -l #check remote.origin.url
git config remote.origin.url
https://USERNAME@github.com/REPO_OWNER/REPO_NAME.git
```

## GIMP Notes
1. To make it more like an IDE, use Windows->Single Window Mode
2. Open windows (Colors, Brushes, Layers, etc), and grab the tab. drag it till you see a blue line. Then release, and blam, it fits
3. To save these window preferences, use Edit->Preferences->Window Management->Save Windows Positions Now

1. GIMP is Useful for cropping images as well
2. If Hide Docks is selected in Windows, de-select it
3. Use the selection tool, then get dimensions right on the little
   window below it, then crop to selection

httrack is a good for for downloading websites for offline viewing. Use
in an empty folder

stow -D <folder name> removes the symlinks
stow <folder name> -t <target name> stows the folder to the target

Kronos IHaskell is great for interactive Haskell dev work. Now if only we could get Anaconda Haskell Distro :)

`ln -s /media/ben/Stuff/ `pwd`/Stuff/` is nice to reach my external HDD

Notes for .login-wallpaper are in bootstrap.sh

## Gedit
Gedit is super cool for my config file work where I need a mouse.
Stop creating backup files in Edit->Preferences->Editor

## Todo conky
fix .conkyrc_i3wm from backup
do the same for .conkyrc
Also need to make .desktop file for QTConsole and Spyder

## VPN Stuff
sudo apt-get install network-manager-openvpn openvpn
sudo restart network manager
Open kupfer and select Network Connections
I'll do it on mac now
