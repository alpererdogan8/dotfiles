#!/bin/bash

# Usage: ./toggle_audio.sh [sink|source]

TARGET=$1

if [ "$TARGET" = "sink" ]; then
    pactl set-sink-mute @DEFAULT_SINK@ toggle
elif [ "$TARGET" = "source" ]; then
    pactl set-source-mute @DEFAULT_SOURCE@ toggle
else
    echo "Usage: $0 [sink|source]"
    exit 1
fi











