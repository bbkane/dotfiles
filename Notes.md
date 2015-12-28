# General Notes

This is stuff I'll forget if I'm not careful.

## Make it so git only asks for password when I push

```
git config --global credential.https://github.com.username bbkane
```

I can see what I've changed before adding and commit if I use `git diff`

mplayer is pretty good for playing podcasts. Use --ss <time> to start playing at a time.

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

## Killing
- pgrep <name> is useful for searching names
- pkill -9 <name> is useful for killing by name
- top lists all processes

## Installing Clang
```
# Download from website
tar xvf clang+llvm... #unzip
sudo cp -R clang+llvm... /usr/local/bin #copy to /usr/local/bin
cd /usr/local/bin/clang+llvm... 
sudo stow bin #farm some symlinks
# http://stackoverflow.com/questions/13428910/how-to-set-the-environmental-variable-ld-library-path-in-linux
# add path to `clang3.6libs.conf` # I came up with the name
sudo ldconfig #this is great, but I can sudo apt-get install it...

## I want to mount my stuff hard drive automatically
http://www.cyberciti.biz/faq/linux-finding-using-uuids-to-update-fstab/
Mount the drive from PCManFM
`sudo blkid` lists all mounts
Then, edit /etc/fstab with the following
UUID=123...456  /mnt/Stuff      ntfs    defaults,errors=remount-ro  0   1
ntfs is the filesystem-it might be ext4, depending on blkid

## Stop Lubuntu from sleeping
Doable from xfce-power-manager-settings
Or:
Look at settings with `xset -q`
Turn off DPMS (Energy Power Settings) with `xset -dpms`
Turn off screen blanking with `xset s off`

## Ripping CDs
sudo apt-get install abcde lame #might also need cd-diskid and cdparanoia
Then, cd into the target folder and use
`abcde -1 -N -o mp3 -a read,encode -x`
-1 : whole cd
-N : Non-interactive
-o mp3 : mp3 output (requires lame)
-a read,encode : read cd, encode to output
-x : eject cd when finished

Then I can play it in mplayer!!
