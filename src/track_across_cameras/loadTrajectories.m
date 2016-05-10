function [traj, traj_f] = loadTrajectories(cameras, frame_range, traj_dir)
%LOADTRAJECTORIES load trajectories from selected cameras inside the specified frame range
% cameras: array of cameras of interest
% frame_range: [starting frame, ending frame]
% traj_dir: directory of trajectory files
% traj: stores each trajectory data struct in a cell array
% traj_f: Nx2 matrix where each row illustrates the start and end 

fileList	= dir(fullfile(traj_dir, '*.mat')); N = numel(fileList);
traj        = cell(N, 1);
traj_f      = zeros(N, 2);
valid       = zeros(N, 1);
for i = 1 : N
    % check if trajectory belongs to one of the specified cameras
    trajdata = strsplit(fileList(i).name, '_');
    c = str2double(trajdata{1});
    if ~ismember(c, cameras), continue; end
    
    % check validity of track w.r.t. length and frame range
    traj{i} = load(fullfile(traj_dir, fileList(i).name));
    wpi = traj{i}.wrl_pos;
    c = traj{i}.c;
    if size(wpi, 1) > 1 && min(wpi(:, 1)) >= frameAdjust(c,frame_range(1)) && max(wpi(:, 1)) <= frameAdjust(c,frame_range(2))
        valid(i) = 1;
        traj_f(i, :) = [wpi(1, 1), wpi(end, 1)];
    end
end

% filter output
traj   = traj(valid==1);
traj_f = traj_f(valid==1, :);
