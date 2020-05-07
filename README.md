# UOW-CSCI926-Autumn-2020
Group project

Ref:
  https://au.mathworks.com/help/gpucoder/examples/code-generation-for-traffic-sign-detection-and-recognition-networks.html

How to use?
1 Run getTsdr.m to download the detection and recognition networks:
    yolo_tsr.mat and RecognitionNet.mat.

2 Run generate_CUDA_MEX.m to Create a GPU configuration object for 
    a MEX target and set the target language to C++.

3 Run ts.m.
