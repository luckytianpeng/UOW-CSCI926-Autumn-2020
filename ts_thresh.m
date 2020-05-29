% Peng TIAN, 5354870, pt882
% luckytianpeng@hohtmail.com, pt882@uowmail.edu.au
%
% CSCI926 Software Testing and Analysis
% Group project - simulation testing tool for ADAS, automated, and autonomous driving systems

% Traffic Signs with different thresholds

% Ref:
%   https://au.mathworks.com/help/gpucoder/examples/code-generation-for-traffic-sign-detection-and-recognition-networks.html

clear;
clc;

% Configuration:
% thresh - probability, for YOLO
THRESH_MIN = 0.2;
THRESH_MAX = 0.8;
THRESH_STEP = 0.05;

VIDEO_DIR = 'videos';   % directory of videos
DRAW_BOUNDING_BOX = true;
DRAW_CLASS_TEXT = true;

SHOW_IMAGE = true;
SAVE_IMAGE = true;
IMAGE_DIR = 'output_thresh';

CSV_FILE = 'output_thresh.csv';

% constants
% Traffic Signs (35)
CLASS_NAMES = {'addedLane','slow','dip','speedLimit25','speedLimit35','speedLimit40','speedLimit45',...
    'speedLimit50','speedLimit55','speedLimit65','speedLimitUrdbl','doNotPass','intersection',...
    'keepRight','laneEnds','merge','noLeftTurn','noRightTurn','stop','pedestrianCrossing',...
    'stopAhead','rampSpeedAdvisory20','rampSpeedAdvisory45','truckSpeedLimit55',...
    'rampSpeedAdvisory50','turnLeft','rampSpeedAdvisoryUrdbl','turnRight','rightLaneMustTurn',...
    'yield','yieldAhead','school','schoolSpeedLimit25','zoneAhead45','signalAhead'};


f = fopen(CSV_FILE,'wt');
fprintf(f, 'thresh,video,frame,x,y,w,h,class\n');
fclose(f);
f = fopen(CSV_FILE,'a+');

for thresh = THRESH_MIN: THRESH_STEP: THRESH_MAX  
    % proc every video
    video_files = file_list(VIDEO_DIR);
    for v_i = 1:length(video_files)
        count = 0;

        full_path = strcat(VIDEO_DIR, '\', video_files(v_i));

        v = VideoReader(full_path);

        % proc every frame
        while hasFrame(v)
            img = readFrame(v);
            count = count + 1;

            % Incorrect size for expression 'img': expected [480x704x3] but found [920x1632x3].
            % [480, 704] is the size of input of the pretrained YOLO
            img = imresize(img, [480,704]);

            [boundingBoxes,classIndices] = tsdr_predict_thresh_mex(img, thresh);

            outputImage = img;

            % draw bounding box:
            if DRAW_BOUNDING_BOX
                outputImage = insertShape(img,'Rectangle', boundingBoxes, 'LineWidth', 3);
            end

            % proc every bounding box:
            for i = 1:size(boundingBoxes,1)
                if DRAW_CLASS_TEXT
                    classRec = CLASS_NAMES{classIndices(i)};
                    ymin = boundingBoxes(i,2);xmin=boundingBoxes(i,1);xmax=xmin+boundingBoxes(i,3);
                    outputImage = insertText(outputImage,[xmax ymin-20],classRec,'FontSize',20,'TextColor','red');
                    
                    x = boundingBoxes(i, 1);
                    y = boundingBoxes(i, 2);
                    w = boundingBoxes(i, 3);
                    h = boundingBoxes(i, 4);
                    
                    fprintf(f, '%f,%s,%d,%d,%d,%d,%d,%s\n',thresh, video_files(v_i), count, x , y, w, h, classRec);
                end
            end

            if SHOW_IMAGE
                imshow(outputImage);
            end

            if SAVE_IMAGE
                si(outputImage, 'png', strcat(IMAGE_DIR, '\', num2str(thresh), '_', video_files(v_i), '_', num2str(count)));
            end
        end % frame
    end % video
end % thresh

fclose(f);


% functions:

% Traffic Sign Detection and Recognition (TSDR) - 
%     [boundingBox, class] = tsdr_predict_thresh(image, thresh)

% Save Image (si)
%     [] = si(image, formate, full_path_name)
function si(image, format, fullName)
    imwrite(image,strcat(fullName,'.', format), format);
end

% get the list of all files in path
function [output] = file_list(path)
    output = [];
    
    listing = dir(path);
    for i = 1:length(listing)
        if strcmp(listing(i).name,'.')==1 || strcmp(listing(i).name,'..')==1
            continue;
        else
            output = [output; string(listing(i).name)];
        end
    end
end
