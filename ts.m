% Peng TIAN, 5354870, pt882
% luckytianpeng@hohtmail.com, pt882@uowmail.edu.au
%
% CSCI926 Software Testing and Analysis
% Group project - simulation testing tool for ADAS, automated, and autonomous driving systems

% Traffic Signs

% Ref:
%   https://au.mathworks.com/help/gpucoder/examples/code-generation-for-traffic-sign-detection-and-recognition-networks.html

clear;
clc;

% Configuration:
THRESH = 0.5;       % probability, for YOLO
global FOG;         % desity of fog
FOG = 0.1;
VIDEO_DIR = 'videos';   % directory of videos
SIGN_DIR = 'signs';     % directory of traffic signs
DRAW_BOUNDING_BOX = true;
DRAW_CLASS_TEXT = true;
REPLACE_SIGNS = true;
ENVIRONMENT_SYNTHESIS = true;
SAVE = false;
SAVE_DIR = 'output';

% constants
% Traffic Signs (35)
CLASS_NAMES = {'addedLane','slow','dip','speedLimit25','speedLimit35','speedLimit40','speedLimit45',...
    'speedLimit50','speedLimit55','speedLimit65','speedLimitUrdbl','doNotPass','intersection',...
    'keepRight','laneEnds','merge','noLeftTurn','noRightTurn','stop','pedestrianCrossing',...
    'stopAhead','rampSpeedAdvisory20','rampSpeedAdvisory45','truckSpeedLimit55',...
    'rampSpeedAdvisory50','turnLeft','rampSpeedAdvisoryUrdbl','turnRight','rightLaneMustTurn',...
    'yield','yieldAhead','school','schoolSpeedLimit25','zoneAhead45','signalAhead'};

count = 0;

sign_files = file_list(SIGN_DIR);
% proc every new sign
for s_i = 1:length(sign_files)
    s_full_path = strcat(SIGN_DIR, '\', sign_files(s_i));
    [sign, map, alpha] = imread(s_full_path);

    % proc every video
    video_files = file_list(VIDEO_DIR);
    for v_i = 1:length(video_files)
        full_path = strcat(VIDEO_DIR, '\', video_files(v_i));

        v = VideoReader(full_path);
        fps = 0;

        % proc every frame
        while hasFrame(v)
            img = readFrame(v);
            
            % Incorrect size for expression 'img': expected [480x704x3] but found [920x1632x3].
            % [480, 704] is the size of input of the pretrained YOLO
            img = imresize(img, [480,704]);

            tic;
            [boundingBoxes,classIndices] = tsdr_predict_thresh_mex(img, THRESH);
            newt = toc;

            fps = .9*fps + .1*(1/newt);

            outputImage = img;

            % draw bounding box:
            if DRAW_BOUNDING_BOX
                outputImage = insertShape(img,'Rectangle', boundingBoxes, 'LineWidth', 3);
            end

            % proc every bounding box:
            for i = 1:size(boundingBoxes,1)
                if REPLACE_SIGNS
                    outputImage = rst(img, boundingBoxes, sign, alpha);
                end

                if DRAW_CLASS_TEXT
                    classRec = CLASS_NAMES{classIndices(i)};
                    ymin = boundingBoxes(i,2);xmin=boundingBoxes(i,1);xmax=xmin+boundingBoxes(i,3);
                    outputImage = insertText(outputImage,[xmax ymin-20],classRec,'FontSize',20,'TextColor','red');
                end
            end

            if ENVIRONMENT_SYNTHESIS
                outputImage = es(outputImage, 'fog');
            end
            
            imshow(outputImage);
            
            if SAVE
                count = count + 1;
                nz = num2str(count);
                id = sprintf(nz,count);
                si(outputImage, 'png', strcat(SAVE_DIR, '\', id));
            end
        end % frame
    end % video
end % sign


% functions:

% Traffic Sign Detection and Recognition (TSDR) - 
%     [boundingBox, class] = tsdr_predict_thresh(image, thresh)

% Replace Traffic Sign (RTS)
%     [image] = rts(image, old_sign_boundingBox, new_sign)
function [outputIamge] = rst(image, boundingBox, sign, alpha)
    outputIamge = image;
    
    x = boundingBox(1);
    y = boundingBox(2);
    w = boundingBox(3);
    h = boundingBox(4);
    
    % s - sign
    s_w = w;
    if 0 > x
        s_w = w + x;
    end

    s_h = h;
    if 0 > h
        s_h = h + y;
    end
    
    new_sign = imresize(sign, [s_h s_w]);
    alphaMask = im2double(alpha);
    new_mask = imresize(alphaMask, [s_h s_w]);
    
    % a - area
    a_x = x;
    if 0 >= a_x
        a_x = 1;
    end

    a_y = y;
    if 0 >= a_y
        a_y = 1;
    end
            
    a_x2 = a_x + s_w - 1;
    a_y2 = a_y + s_h - 1;
    
    area = image(a_y:a_y2, a_x:a_x2, :);
    composite = double(area).*(1-new_mask) + double(new_sign).* new_mask;
    
    outputIamge(a_y:a_y2, a_x:a_x2, :) = composite;
end

% Environment Synthesis (ES) - rain, fog, dusk, night ...
%     [image] = es(image, category)
function [outputIamge] = es(image, category)
    global FOG;
    switch category
        case 'fog'
            outputIamge = fog(image, FOG);
        otherwise
            outputImage = image;
    end
end

% Environment Funtion (EF) - various funtions such as rain, fog
%     [image] = ef(image, args)
function [outputImage] = fog(image, arg)
    img = double(image)/255;
    img_delta = img;
    [row, col, z] = size(img_delta);
    A = 0.8;
    m = row / 2;
    n = col / 2;
    
    outputImage = img;
    
    for i=1:3  % RGB - three channels
        for j = 1:row
            for l = 1:col
                d(j,l) = -0.04*sqrt((j-m).^2 + (l-n).^2) + 20;
                td(j,l) = exp(-arg*d(j,l));
                outputImage(j,l,i) = img(j,l,i)*td(j,l) + A*(1-td(j,l));
            end
        end
    end
end

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
