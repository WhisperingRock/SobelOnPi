# Sobel On Pi

Sobel filter implemented on RPi3 B+ 

## The Grayscale Operator
This implementation requires that the RBG image (**TODO** img type) be flattened
into a single intensity value ... a grayscale value. This can be done with a few methods.

- Average : $$p = \frac{R + G + B}{3}$$
- [ITU-R B.709 Luminance](https://en.wikipedia.org/wiki/Rec._709) 
    $$p = 0.2126 R + 0.7152 G + 0.0722 B$$

I opt'd to use Luminance for its accepted standard. 

## The Sobel Operator

Uses two 3x3 kernels which are convolved with the original (grayscale) image to 
calculate approximations of the derivatives. Each kernel, one for horizontal change and one for vertical change, performs a low pass Gaussian filtering [1 2 1] as well as a discrete differentiation [+1 0 -1] on each pixel of the image.

```math
\bf{G_x} = 
\begin{bmatrix}
+1 & 0 & -1 \\
+2 & 0 & -2 \\
+1 & 0 & -1
\end{bmatrix}=
\begin{bmatrix} 1 \\ 2 \\ 1 \end{bmatrix}
\begin{bmatrix} +1 & 0 & -1 \end{bmatrix}
```

```math
\bf{G_y} = 
\begin{bmatrix}
+1 & +2 & +1 \\
0 & 0 & 0 \\
-1 & -2 & -1
\end{bmatrix}=
\begin{bmatrix} +1 \\ 0 \\ -1 \end{bmatrix}
\begin{bmatrix} 1 & 2 & 1 \end{bmatrix}
```

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

### Installing OpenCV

This was a doozy to do natively and I only had success after cross compiling on my UNIX machine.

#### On your UNIX machine

1. Update and install the ARM cross-compiler toolchain

```
sudo apt-get update
sudo apt-get install -y build-essential cmake git wget
sudo apt-get install -y gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf
```

2. Download opencv
```
cd ~
wget -O opencv.zip https://github.com/opencv/opencv/archive/refs/tags/4.10.0.zip
unzip opencv.zip
mv opencv-4.10.0 opencv
```

3. Create a toolchain file for CMake to target the pi's ARM architecture.
```
cat > ~/arm-toolchain.cmake << 'EOF'
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR armv7l)

set(CMAKE_C_COMPILER arm-linux-gnueabihf-gcc)
set(CMAKE_CXX_COMPILER arm-linux-gnueabihf-g++)

set(CMAKE_FIND_ROOT_PATH /usr/arm-linux-gnueabihf)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=armv7-a -mfpu=neon -mfloat-abi=hard")
EOF
```

4. Build opencv on the UNIX machine (my desktop), ensuring that NEON and VFPV3 are enabled (we'll be using them later)
```
cd ~
mkdir opencv-build
cd opencv-build

cmake -DCMAKE_TOOLCHAIN_FILE=~/arm-toolchain.cmake \
      -DENABLE_VFPV3=ON \
      -DENABLE_NEON=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/opt/opencv-arm \
      ~/opencv

make -j4
```

5. Make the library package, compress it, and send to the pi via ssh (or USB if you want to)
```
cd ~/opencv-build
sudo make install

# Create a tarball of the compiled libraries
cd /opt
sudo tar czf ~/opencv-arm.tar.gz opencv-arm/

# Transfer to your Pi
scp ~/opencv-arm.tar.gz pi@<pi-ip>:/tmp/
```
*dont forget to replace `<pi-ip>` with the pi's real ip addr*

#### On the Pi
1. ssh into the pi and extract the transferred files.
```
ssh pi@<pi-ip>
cd /tmp
tar xzf opencv-arm.tar.gz
sudo mv opencv-arm /opt/
```

2. Update the env variables added to bashrc
```
echo "export PYTHONPATH=/opt/opencv-arm/lib/python3.9/site-packages:$PYTHONPATH" >> ~/.bashrc
echo 'export PKG_CONFIG_PATH=/opt/opencv-arm/lib/pkgconfig:$PKG_CONFIG_PATH' >> ~/.bashrc
source ~/.bashrc
sudo ldconfig -n /opt/opencv-arm/lib
```

3. Create the missing opencv4.pc file, which is a metadata file that informs pck-config where opencv is installed.
```
sudo mkdir -p /opt/opencv-arm/lib/pkgconfig
sudo tee /opt/opencv-arm/lib/pkgconfig/opencv4.pc > /dev/null << 'EOF'
prefix=/opt/opencv-arm
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include/opencv4

Name: opencv
Description: Open Source Computer Vision Library
Version: 4.12.0
Libs: -L${libdir} -lopencv_core -lopencv_imgproc -lopencv_imgcodecs -lopencv_videoio -lopencv_video -lopencv_calib3d -lopencv_features2d -lopencv_objdetect -lopencv_dnn -lopencv_ml -lopencv_flann -lopencv_photo -lopencv_stitching -lopencv_gapi -lopencv_highgui
Cflags: -I${includedir}
EOF
```

4. Create a persistent linker config
```
sudo tee /etc/ld.so.conf.d/opencv-arm.conf > /dev/null << 'EOF'
/opt/opencv-arm/lib
EOF


sudo ldconfig
```

5. Confirm pck-config can find opencv
```
pkg-config --modversion opencv4
```

6. Run a simple test script
```
cat > /home/admin/test_opencv.cpp << 'EOF'
#include <iostream>
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>

int main() {
    std::cout << "OpenCV version: " << CV_MAJOR_VERSION << "." 
              << CV_MINOR_VERSION << "." << CV_SUBMINOR_VERSION << std::endl;
    
    // Create a simple 3x3 matrix
    cv::Mat mat = cv::Mat::zeros(3, 3, CV_32F);
    mat.at<float>(0, 0) = 1.5f;
    mat.at<float>(1, 1) = 2.5f;
    mat.at<float>(2, 2) = 3.5f;
    
    std::cout << "Matrix created and populated successfully:\n" << mat << std::endl;
    
    // Test a simple operation
    cv::Mat result;
    cv::transpose(mat, result);
    std::cout << "Transpose successful:\n" << result << std::endl;
    
    std::cout << "\n✓ All tests passed!" << std::endl;
    return 0;
}
EOF
```
... and compile/execute using pkg-config to handle the links...
```
g++ -o /home/admin/test_opencv /home/admin/test_opencv.cpp \
    $(pkg-config --cflags --libs opencv4)

./test_opencv
```

#### Back on the UNIX machine

Backup the Pi's image on the ssd for easy recovery.

1. Check which `dev/` the ssd was binded to
```
sudo fdisk -1

# or use a graphical tool
```

2. Copy the memory from the ssd. (mine was on `/dev/sda` )
```
sudo dd bs=4M if=/dev/sda of=/home/username/MyImage.img status=progress
```

