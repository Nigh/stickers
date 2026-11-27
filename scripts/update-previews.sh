#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

shopt -s nullglob
for dir in "$root"/images/*-previews; do
  name=${dir##*/}
  name=${name%-previews}
  files=("$dir"/*.{jpg,jpeg,png,webp})
  ((${#files[@]})) || continue

  max_width=0
  for file in "${files[@]}"; do
    width=$(magick identify -format '%w' "$file")
    ((width > max_width)) && max_width=$width
  done

  normalized=()
  for i in "${!files[@]}"; do
    file=${files[$i]}
    height=$(magick identify -format '%h' "$file")
    output="$tmp/$i.jpg"
    magick "$file" -background white -gravity center -extent "${max_width}x${height}" "$output"
    normalized+=("$output")
  done
  magick "${normalized[@]}" -append -quality 50 "$root/$name-preview.jpg"
done
