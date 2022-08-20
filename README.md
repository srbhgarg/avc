# AVC (Audio-Visual Communication) #

## Speech Communications ##

### Abstract ###
Using computer-vision and image processing techniques, we aim to identify specific visual cues as induced by facial movements made during Mandarin tone production and examine how they are associated with each of the four Mandarin tones. Audio-video recordings of 20 native Mandarin speakers producing Mandarin words involving the vowel /3/ with each of the four tones were analyzed. Four facial points of interest were detected automatically: medial point of left eyebrow, nose tip (proxy for head movement), and midpoints of the upper and lower lips. The detected points were then automatically tracked in the subsequent video frames. Critical features such as the distance, velocity, and acceleration describing local facial movements with respect to the resting face of each speaker were extracted from the positional profiles of each tracked point. Analysis of variance and feature importance analysis based on random forest were performed to examine the significance of each feature for representing each tone and how well these features can individually and collectively characterize each tone. Results suggest alignments between articulatory movements and pitch trajectories, with downward or upward head and eyebrow movements following the dipping and rising tone trajectories respectively, lip closing movement being associated with the falling tone, and minimal movements for the level tone.

### Notes ###

This code was tested on ```mp4``` files. In case of issues reading video files, check the codecs or use different read function (e.g. ```mmread``` function was also found to be useful to read the audio/video data).

There are some issues in reading video files using ```MATLAB```'s videoReader function on MAC OS. This issue may also occur on other platforms.

- ```avc_main.m``` is the main function file to run the code.
- ```data``` folder contains sample data to run the code.
- ```avc_readData```: function that reads the video files. 
- ```avc_readLabels``` is specific to this project. It parses the filename for different annotation labels.
- ```avc_videosegment```: returns the frame number of the first and the last frame in the video where audio signal is detected.
- ```detectLips```: detect keypoints on lips; uses LBP cascade filter to detect mouth.

![](images/lips.png)

```detectEyes```: detect keypoints on eyebrow. Internally calls ```detectEyebrow```

![](images/eyebrow.png)

```detectNose```: detect keypoints on head.

![](images/nose.png)

```pickpoints```: this function picks one keypoint from various detected keypoints in one region.
uses ```vision.PointTracker``` based KLT tracker to track the detected keypoints.

```avc_extractHeadFeatures```: compute features based on the detected keypoint trajectory.

![](images/eyebrow_track.png)


```classify2.m``` and ```classify3.m``` contains code for random forest and the modified implementation of Paul's random forest method.

For full description on the project please read our paper below:

Garg, S., Hamarneh, G., Jongman, A., Sereno, J. A., & Wang, Y. (2019). Computer-vision analysis reveals facial movements made during Mandarin tone production align with pitch trajectories. Speech Communication, 113, 47-62.
