Motion Detection by Using Histograms on MATLAB

Motion detection is done by using algortihms applied in MATLAB developed to be useful on live footage of stationary cameras.
That stationary camera part is important since the code checks only the change of histograms of consecutively obtained frames
with a certain delay.
Checking if there exists a motion by only using histograms are actually pretty much "going around" a lot of image processing methods
for the sake of only applying this on stationary cameras.
However this method still suffers for motions that happen far away from the camera. Since those moves will be in smaller amount
of pixels than others and less pixel difference means higher chance of that motion being neglected. Because the amount of change
in the max and min points of histograms are a lot less than desired.
A moving camera captures images with always changing histograms and it is a job for completely different algorithm to obtain motion
on a already moving camera.

First part of this code is specified for built-in camera of my laptop. It may vary depending of your hardware, address and name of
the camera in your computer.
The layout of the output window is also open for development especially if you think about the Motion:1 and Motion:0 being written
on empthy graphics plate.

Screen recording of the output window while code is running given in the link below:
https://mega.nz/file/4d0TlSQY#UuP2TFf--BHxX71E4dReYT8GdsZsQ9190V0KWQDHvcQ