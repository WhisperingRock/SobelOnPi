# Sobel On Pi
Sobel filter implemented on RPi3 B+ 

## Hardware Specs
|||
|----|----|
|Device|Raspberry Pi 3 B+|
|OS|RaspPi OS (32-bit) - Debian Trixie 2026-04-21|
|CPU|4 ARMv7 processors [600, 1400] MHz|
|Memory|965 MB RAM|
|Storage|16GB Storage|
|Caches| L1{d,i} 120KiB, L2 512 KiB|
|Case| Plastic, no fans, small heaksink on CPU|


## Measurements
| OC | Desc | Video | FPS |
|----|----|----|----|
| 1 | OpenCV Baseline | 1080p_blender.mp4 | ?? |


## Links / Troubleshooting
1. [Installing OpenCV](https://learnopencv.com/build-and-install-opencv-4-for-raspberry-pi/)
  - Had to install dphys-swapfile (removed rpi-swap) `sudo apt install dphys-swapfile`
    - Edit `/etc/dphys-swapfile` to extend the swapfile storage to 2GB `CONF_SWAPSIZE=2048`
    - `sudo dphys-swapfile swapoff` -> `sudo dphys-swapfile setup` -> `sudo dphys-swapfile swapon`
    - Valdiate swapfile in use with `free -h` alongside RAM
