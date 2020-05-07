% Ref:
%   https://au.mathworks.com/help/gpucoder/examples/code-generation-for-traffic-sign-detection-and-recognition-networks.html

% Generate CUDA MEX for the tsdr_predict Function

cfg = coder.gpuConfig('mex');
cfg.TargetLang = 'C++';
cfg.DeepLearningConfig = coder.DeepLearningConfig('cudnn');
% codegen -config cfg tsdr_predict -args {ones(480,704,3,'uint8')} -report
codegen -config cfg tsdr_predict_thresh -args {ones(480,704,3,'uint8'), ones(1, 'double')} -report
