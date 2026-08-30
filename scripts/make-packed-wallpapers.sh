#!/usr/bin/env bash
set -euo pipefail

# Extra packed wallpapers so Settings is not a one-tile picker.
# The teal-waves photo stays the default.

pack=${1:-$HOME/.local/share/backgrounds/hyprarch}
mkdir -p "$pack"

make_blend() {
    local out=$1 c0=$2 c1=$3
    [[ -f $out ]] && return 0
    ffmpeg -loglevel error -y \
        -f lavfi -i "color=c=${c0}:s=3024x1898:d=1" \
        -f lavfi -i "color=c=${c1}:s=3024x1898:d=1" \
        -filter_complex "[0][1]blend=all_expr='A*(1-X/W*Y/H)+B*(X/W*Y/H)'" \
        -frames:v 1 "$out"
}

make_blend "$pack/dusk-navy.jpg" "0x0b1220" "0x155e75"
make_blend "$pack/deep-teal.jpg" "0x042f2e" "0x0f766e"
