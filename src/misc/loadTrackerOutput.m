function [ OUT ] = loadTrackerOutput( camera, frame_range, track_dir )
%LOADTRACKEROUTPUT get detections from specific camera and frame range
% camera: camera ID
% frame_range: 1x2 array of minimum and maximum frame for specific camera
% track_dir: directory containing single-camera trajectory tracking output

OUT = dlmread(track_dir);
adj_frame_range = frameAdjust(camera,frame_range(1)):frameAdjust(camera,frame_range(2));
OUT = OUT( ismember(OUT(:,2),adj_frame_range), : );

% 1. person ID as given by tracker
% 2. frame
% 3-6. bounding box
% column 7 and 8: ground plane position
