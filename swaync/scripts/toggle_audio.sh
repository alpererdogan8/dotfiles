#!/usr/bin/env bash
# =============================================================================
# toggle_audio.sh — Mute toggle for audio sink or source
#
# Usage: toggle_audio.sh [sink|source]
#
#   sink   — toggle mute on the default audio output (speakers/headphones)
#   source — toggle mute on the default audio input (microphone)
# =============================================================================

TARGET=$1

case "$TARGET" in
  sink)
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    ;;
  source)
    pactl set-source-mute @DEFAULT_SOURCE@ toggle
    ;;
  *)
    echo "Usage: $0 [sink|source]" >&2
    exit 1
    ;;
esac
