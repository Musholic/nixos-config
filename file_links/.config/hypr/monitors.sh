#!/bin/sh

hyprctl keyword monitor "DP-3, preferred, auto, 1"

# We are probably streaming if the directory /run/current-system/specialisation is empty
if [ -z "$(ls /run/current-system/specialisation)" ]; then
    hyprctl keyword monitor "DP-2, preferred, auto-left, 1.6"
else
    hyprctl keyword monitor "DP-2, preferred, auto-left, 1"
fi
