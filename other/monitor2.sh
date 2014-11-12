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

# I want to modify this with optional arguments
# If the script is called with no arguments, then it should default
# to two screen mode
# If the argument is 'left', then the Dell should stay on
# if the argument is 'right', then the Samsung should stay on

DELL=DFP10
SAMSUNG=DFP9
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
	echo "One monitor mode: Dell"
	xrandr --output $SAMSUNG --off

elif [[ $1 = right ]]
then
  echo "One monitor mode: Samsung"
  xrandr --output $DELL --off
else
	echo "Usage: $0 [left | right]. No arguments defaults to both screens"
fi

