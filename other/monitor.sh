#!/bin/bash

# used by my tower to switch monitors
# Put this in the PATH, probably /usr/local/bin

#set up dual monitors with this profile
#https://wiki.ubuntu.com/X/Config/Resolution#How_to_setup_a_dual_monitor

#DFP9 is my Samsung
#DFP10 is my Dell

#set Samsung to the right of Dell
#xrandr --output DFP9 --right-of DFP10

#Make the Dell the primary monitor
#xrandr --output DFP10 --primary

#correct the resolution on the Samsung
#xrandr --output DFP9 --auto

DELL=DFP10
SAMSUNG=DFP9

if [ $1 = one ]
then
	echo "Changing to one screen mode"
	xrandr --output $DELL --off
	
elif [ $1 = two ]
then
	echo "Changing to two screen mode"
	xrandr --output $DELL --auto
	xrandr --output $SAMSUNG --right-of $DELL
	xrandr --output $DELL --primary
	xrandr --output $SAMSUNG --auto
	
else
	echo "not one or two"
fi

