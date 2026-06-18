# Sobel On Pi

Sobel filter implemented on RPi3 B+ 

## The Grayscale Operator
This implementation requires that the RBG image (**TODO** img type) be flattened
into a single intensity value ... a grayscale value. This can be done with a few methods.

- Average : $$p = \frac{R + G + B}{3}$$
- [ITU-R B.709 Luminance](https://en.wikipedia.org/wiki/Rec._709) $$ p = 0.2126 R + 0.7152 G + 0.0722 B$$

I opt'd to use Luminance for its accepted standard. 

## The Sobel Operator

Uses two 3x3 kernels which are convolved with the original (grayscale) image to 
calculate approximations of the derivatives. Each kernel, one for horizontal change and one for vertical change, performs a low pass Gaussian filtering [1 2 1] as well as a discrete differentiation [+1 0 -1] on each pixel of the image.

$$
\bf{G_x} = 
\begin{bmatrix}
+1 & 0 & -1 \\
+2 & 0 & -2 \\
+1 & 0 & -1
\end{bmatrix}

=

\begin{bmatrix} 1 \\ 2 \\ 1 \end{bmatrix}
\begin{bmatrix} +1 & 0 & -1 \end{bmatrix}

$$

$$
\bf{G_y} = 
\begin{bmatrix}
+1 & +2 & +1 \\
0 & 0 & 0 \\
-1 & -2 & -1
\end{bmatrix}

=

\begin{bmatrix} +1 \\ 0 \\ -1 \end{bmatrix}
\begin{bmatrix} 1 & 2 & 1 \end{bmatrix}
$$

The results of the operator produce a cheap edge detector where :
- Magnitude : $$\bf{G} = \sqrt{\bf{G_x}^2 + \bf{G_y} ^ 2}$$
- Direction of gradient : $$\bf{\Theta} = \arctan{\left(\frac{G_y}{G_x}\right)}$$

For the scope of this project, I'm only using the magnitude. 

## Hardware Specs

| | |
|----|----|
|Device|Raspberry Pi 3 B+|
|OS|RaspPi OS (32-bit) - Debian Trixie 2026-04-21|
|CPU|4 ARMv7 processors [600, 1400] MHz|
|Memory|965 MB RAM|
|Storage|16GB Storage|
|Caches| L1{d,i} 120KiB, L2 512 KiB|
|Case| Plastic, no fans, small heaksink on CPU|

## Video Specs

| Title | Dimens | Frame Rate | Size | Length |
|----|----|----|----|----|
| 1080p_blender.mp4 | 1920x1080 | 30 | 15.9MB | 2:31 |


## Measurement Milestones

| Stone | Desc | Video | FPS |
|----|----|----|----|
| 1 | OpenCV Baseline | 1080p_blender.mp4 | ?? |


## Process and Troubleshooting

1. [Installing OpenCV](https://learnopencv.com/build-and-install-opencv-4-for-raspberry-pi/)

- Had to install dphys-swapfile (removed rpi-swap) `sudo apt install dphys-swapfile`
    - Edit `/etc/dphys-swapfile` to extend the swapfile storage to 2GB `CONF_SWAPSIZE=2048`
    - `sudo dphys-swapfile swapoff` -> `sudo dphys-swapfile setup` -> `sudo dphys-swapfile swapon`
    - Valdiate swapfile in use with `free -h` alongside RAM
