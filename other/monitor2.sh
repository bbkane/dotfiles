#!/bin/zsh

# used by my tower to switch monitors
# Put this in the PATH, probably /usr/local/bin

#set up dual monitors with this profile
#https://wiki.ubuntu.com/X/Config/Resolution#How_to_setup_a_dual_monitor

# I want to modify this with optional arguments
# If the script is called with no arguments, then it should default
# to two screen mode
# If the argument is 'left', then the Dell should stay on
# if the argument is 'right', then the Samsung should stay on

DELL=DFP10
SAMSUNG=DFP9

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

