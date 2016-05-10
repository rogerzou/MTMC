function out = frameAdjust(camera, frame)
%FRAMEADJUST Return the proper frame shift for a given camera
% camera: camera ID
% frame: frame number UNADJUSTED
% out: frame number ADJUSTED

global DATASET
out = DATASET{camera}.frameAdjustment + frame;
