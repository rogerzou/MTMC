function out = loadImage(frame, c)
%LOADIMAGE load image from specific camera and frame.
global PATH

cam_path = fullfile(PATH.data_images_path, ['camera',num2str(c)]);          % camera specific path
img_name = sprintf(PATH.data_images_fmat, frameAdjust(c, frame));          % image name
path = fullfile(cam_path, img_name);                                        % full path to specific image
out = imread(path);                                                         % load image
