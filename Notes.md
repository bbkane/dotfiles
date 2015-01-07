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

httrack is a good for for downloading websites for offline viewing. Use
in an empty folder

stow -D <folder name> removes the symlinks
stow <folder name> -t <target name> stows the folder to the target

Kronos IHaskell is great for interactive Haskell dev work. Now if only we could get Anaconda Haskell Distro :)


