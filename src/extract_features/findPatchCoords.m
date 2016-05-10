function [bb, bb_pr] = findPatchCoords(data_id, f, c)
%FINDMATCHCOORDS obtain bounding box of person trajectory for a specific
%id, frame, and camera.
% data_id: single camera tracking data of a specific id
% f: frame of interest
% c: camera of interest
global DATASET;

% get the indices in data that pertains to frame of interest
frame_idx = (data_id(:, 2) == f);

% get the bounding box of person in bb
bb = round(data_id(frame_idx, [4 6 3 5 13]));
bb_pr = bb; 
if isempty(bb), return; end

% compute fixed w/h ratio patch coordinates (useful if there is a training)
bb_box_actual_height = bb(2) - bb(1);
bb_box_actual_height = bb_box_actual_height *1.10;
bb_box_actual_width  = bb_box_actual_height /(98/40);
bb_pr(1) = max(1, bb(1));
bb_pr(2) = min(DATASET{c}.imageHeight, bb(1) + bb_box_actual_height);
bb_pr(3) = max(1, (bb(3) + bb(4))/2-bb_box_actual_width/2);
bb_pr(4) = min(DATASET{c}.imageWidth, (bb(3) + bb(4))/2+bb_box_actual_width/2);
bb_pr    = round(bb_pr);

% remove this line to use original BB
bb = bb_pr;