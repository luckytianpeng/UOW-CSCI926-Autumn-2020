# UOW-CSCI926-Autumn-2020
Group project

Ref:
  https://au.mathworks.com/help/gpucoder/examples/code-generation-for-traffic-sign-detection-and-recognition-networks.html


V2
-------------------------------------------------------------------------------
How to use?
1 Run getTsdr.m to download the detection and recognition networks:
    yolo_tsr.mat and RecognitionNet.mat.

2 Run generate_CUDA_MEX.m to Create a GPU configuration object for 
    a MEX target and set the target language to C++.

3 

	matlab     |     description          |    resutls            |     R
---------------+--------------------------+-----------------------+------------
ts_thresh.m    | different thresh of YOLO | output_thresh.csv     | thresh.R
ts_fog.m       | different desity of fog  | output_fog.csv        | fog.R
ts_new_signs.m | using new traffic signs  | output_neew_signs.csv | new_signs.R
  
  


V1
-------------------------------------------------------------------------------
How to use?
1 Run getTsdr.m to download the detection and recognition networks:
    yolo_tsr.mat and RecognitionNet.mat.

2 Run generate_CUDA_MEX.m to Create a GPU configuration object for 
    a MEX target and set the target language to C++.

3 Run ts.m.
