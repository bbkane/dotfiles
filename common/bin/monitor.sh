#!/bin/zsh

# used by my tower to switch monitors
# Put this in the PATH, probably /usr/local/bin
# The commnand is:
# ln -s $HOME/backup/manually_symlink/monitor.sh /usr/local/bin/monitor.sh
# I'm using GNU Stow now, so it will be symlinked with that

#set up dual monitors with this profile
#https://wiki.ubuntu.com/X/Config/Resolution#How_to_setup_a_dual_monitor

# this is aliased in .zshrc

DELL=DVI-0
SAMSUNG=HDMI-0

# No arguments
if [[ $1 = "" ]]
then
  # both screens
	xrandr --output $DELL --auto
	xrandr --output $SAMSUNG --right-of $DELL
	xrandr --output $DELL --primary
	xrandr --output $SAMSUNG --auto
elif [[ $1 = left ]]
then
  # Dell stays on
  xrandr --output $DELL --primary
  xrandr --output $DELL --auto
	xrandr --output $SAMSUNG --off
elif [[ $1 = right ]]
then
  # Samsung stays on
  xrandr --output $SAMSUNG --primary
  xrandr --output $SAMSUNG --auto
  xrandr --output $DELL --off
else
	echo "Usage: $0 [left | right]. If no arguments are passed, then dual monitor mode"
fi

