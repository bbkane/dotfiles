#!/bin/bash

choice=$(zenity --list --radiolist --text "Which monitor config?" --hide-header --column "I don't know what this is" --column "this either" TRUE "Both monitors" FALSE "Samsung only" FALSE "Dell only")

if [[ $choice = "Both monitors" ]]
then
	./monitor.sh both
elif [[ $choice = "Samsung only" ]]
then
	./monitor.sh right
elif [[ $choice = "Dell only" ]]
then
	./monitor.sh left
fi
