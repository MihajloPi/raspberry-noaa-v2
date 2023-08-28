#!/bin/bash

cd ~/raspberry-noaa-v2/tmp

for i in {1..5}; do
  counter=$((6-$i))
  wget --no-check-certificate https://hidmet.gov.rs/data/satelitska_slika/Srbija_com_$i.png
  convert Srbija_com_$i.png -quality 100 Srbija_com_$counter.jpg
  rm Srbija_com_$i.png
done

#ffmpeg -an -framerate 2 -i "Srbija_com_%01d.jpg" -vcodec libx264 -pix_fmt yuv420p -level 3 -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" -y serbia_cloud_animation.mp4
ffmpeg -an -framerate 2 -i "Srbija_com_%01d.jpg" -vcodec libvpx-vp9 -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" -y serbia_cloud_animation.webm
sudo mv serbia_cloud_animation.webm /srv/videos/RollingAnimation.webm

rm Srbija_com_*.jpg
