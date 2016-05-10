function mask = loadMask(frame, c)
%LOADMASK load mask from specific camera and frame.
global PATH

cam_path = fullfile(PATH.data_bacsub_path, ['camera', num2str(c)]);         % camera specific path
msk_path = sprintf(PATH.data_bacsub_fmat, frameAdjust(c,frame));           % mask name
path = fullfile(cam_path, msk_path);                                        % full path to specific mask
mask = im2double(imread(path));                                             % load mask
