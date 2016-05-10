function [thisModel] = extractDetections(trackerOutput, id, c)
%EXTRACTDETECTIONS Extract people detections of a specific ID and camera to
%a struct model.
% trackerOutput: matrix of tracks
% id: person ID to extract
% c: camera of interest

% load data from specific ID
data = trackerOutput(trackerOutput(:, 1) == id, :);
frames = data(:, 2);    % array of frames

%% extract information about each people trajectory

% iterate over each frame
thisModel = cell(1, length(frames));    % length is the number frames current trajectory is in current camera
for f_idx = 1 : length(frames)
    f = frames(f_idx);

    % explicit patch coords (bb_pr has fixed w/h ratio)
    [bb, bb_pr] = findPatchCoords(data, f, c);
    
    % save to model variable
    thisModel{f_idx} = storeFrameInfo(c, id, f, bb, bb_pr);
end
