#!/bin/bash

# Define output filename
output="timelapse.webm"

# Create a temporary directory
temp_dir=$(mktemp -d)

# Counter for renaming files
i=0

# Find and process each image individually, sorted by modification time
while IFS= read -r -d '' img; do
  # Extract timestamp from filename
  filename=$(basename "$img")
  # Example input: timestamp_raw="20250615-091234"

  timestamp_raw=$(echo "$filename" | grep -oP '\d{8}-\d{6}')

  # Break it down into clean components
  date_part=${timestamp_raw%-*}   # 20250615
  time_part=${timestamp_raw#*-}   # 091234

  # Manually reformat to "YYYY-MM-DD HH:MM:SS"
  formatted_date="${date_part:0:4}-${date_part:4:2}-${date_part:6:2} ${time_part:0:2}:${time_part:2:2}:${time_part:4:2}"

  # Now feed that to `date` safely
  readable_time=$(date -d "$formatted_date" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)

  # Format output filename
  printf -v newname "%s/img%04d.jpg" "$temp_dir" "$i"

  # Apply yellow text on black background using ImageMagick
  convert "$img" \
    -gravity NorthWest \
    -fill yellow \
    -undercolor black \
    -pointsize 50 \
    -annotate +10+10 "$readable_time" \
    "$newname"

  ((i++))
done < <(
  find /srv/images/ -maxdepth 1 -type f -name "*-MSA_projected.jpg" -cmin -1440 -print0 |
  xargs -0 stat --format '%Y %n' |
  sort -n |
  cut -d' ' -f2- |
  tr '\n' '\0'
)

# Generate timelapse video
ffmpeg -y \
  -an \
  -framerate 2 \
  -i "$temp_dir/img%04d.jpg" \
  -vcodec libvpx-vp9  \
  -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" \
  -pix_fmt yuv420p \
  "$output"

# Move the animation to /srv/videos/ for displaying on the web
sudo mv "$output" /srv/videos/RollingAnimation.webm

# Clean up
rm -r "$temp_dir"
