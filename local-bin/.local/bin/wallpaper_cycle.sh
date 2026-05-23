#!/bin/bash

DIR="$HOME/Pictures/wallpapers"

PICS=($(ls $DIR | grep -E ".jpg|.jpeg|.png|.webp|.gif"))
RANDOM_PICS=${PICS[RANDOM%${#PICS[@]}]}

#swww img "$DIR/$RANDOM_PICS" --transition-type wipe --transition-fps 60 --transition-step 90
#swww img "$DIR/$RANDOM_PICS" --transition-type any --transition-fps 120 --transition-step 180
awww img "$DIR/$RANDOM_PICS" --transition-type wave --transition-fps 120 --transition-step 10
#swww img "$DIR/$RANDOM_PICS" --transition-type grow --transition-pos center --transition-fps 120 --transition-step 200
#swww img "$DIR/$RANDOM_PICS" --transition-type outer --transition-pos center --transition-fps 120 --transition-step 18
#swww img "$DIR/$RANDOM_PICS" --transition-type outer --transition-pos center --transition-fps 120 --transition-step 1800
#swww img "$DIR/$RANDOM_PICS" --transition-type any --transition-fps 120 --transition-step 180
