#!/usr/bin/env bash

mainMod="Super"

key_names=(
  "KP_End" "KP_Down" "KP_Next" "KP_Left" "KP_Begin"
  "KP_Right" "KP_Home" "KP_Up" "KP_Prior" "KP_Insert"
)

key_names2=(
  "ampersand" "eacute" "quotedbl" "apostrophe" "parenleft"
  "minus" "egrave" "underscore" "ccedilla" "agrave"
)

# Add workspace bindings
for i in $(seq 1 10); do
  key="${key_names[$i-1]}" # Get the key name from the array
  key2="${key_names2[$i-1]}" # Get the key name from the array
  hyprctl keyword bind "$mainMod,$key,workspace,$i"
  hyprctl keyword bind "$mainMod shift,$key,movetoworkspace,$i"
  hyprctl keyword bind "$mainMod,$key2,workspace,$i"
  hyprctl keyword bind "$mainMod shift,$key2,movetoworkspace,$i"
done
