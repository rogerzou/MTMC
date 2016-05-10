%EXTRACT_FEATURES 
% Input: raw single-camera trajectory tracking outputs (trajectories)
% Output: features for individual trajectories

%% SETUP
% calls config_path, config_exp, loadConfigSettings, gurobi_setup, which
% sets up the workspace and experiment settings

clear; clc; close all;
addpath(genpath('.'));
config_path; config_exp; loadConfigSettings;
global PATH EXP;


%% COMPUTE FEATURES

if exist(PATH.temp_extfea_path, 'dir')                                      % create dir to store features, if it doesn't exist
    rmdir(PATH.temp_extfea_path, 's');
end
mkdir(PATH.temp_extfea_path);

for c = EXP.cameras                                                         % iterate over each camera
    
    track_dir = fullfile(PATH.temp_ppltrk_path, sprintf('%d.top', c));      % get dir of single camera people tracker output
    trackerOutput = loadTrackerOutput(c, EXP.frame_range, track_dir);       % load tracker output
    
    ids = int64(unique(trackerOutput(:, 1)));                               % get unique people IDs
    t   = zeros(length(ids), 1); t(1) = Inf;                                % t stores times (from tic)
    tROld = Inf;                                                            % starting remaining time
    for idx = 1 : length(ids)                                               % iterate over each trajectory
        
        tRNew = round(mean(t(t>0.01))*(length(ids)-idx+1)/60);              % approximate new remaining time
        if tRNew < tROld                                                    % update remaining time if needed and print
            fprintf('Computing features for traj %d of %d (cam %d) - %d min remaining...\n', idx, length(ids), c, tRNew);
            tROld = tRNew;
        end
        myClock = tic;                                                      % restart clock
        
        id = ids(idx);                                                      % id is current person ID
        thisModel = extractDetections(trackerOutput, id, c);                % extract features for current person ID
        
        wrl_pos              = getPositionalInformation(thisModel);         % extract 3D feet location along the whole traj TODO verify correctness TODO
        mean_hsv             = getBaselineDescriptor(thisModel);            % extract mean HSV histogram from masked images TODO verify correctness TODO
        
        
        save_dir = fullfile(PATH.temp_extfea_path, sprintf('%d_%d.mat', c, id));
        save(save_dir, 'c', 'id', 'wrl_pos', 'mean_hsv');                   % save data for specific trajectory
        
        t(idx) = toc(myClock);                                              % get clock value
    end
end
