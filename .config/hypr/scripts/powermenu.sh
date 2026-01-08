#!/bin/bash
# Power Menu Script for Wofi

entries=" Logout\n󰤄 Suspend\n Reboot\n⏻ Shutdown"

selected=$(echo -e $entries | wofi --dmenu --cache-file /dev/null --style ~/.config/wofi/powermenu.css | awk '{print tolower($2)}')

case $selected in
    logout)
        hyprctl dispatch exit
        ;;
    suspend)
        systemctl suspend
        ;;
    reboot)
        systemctl reboot
        ;;
    shutdown)
        systemctl poweroff
        ;;
esac
