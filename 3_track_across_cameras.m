%% TRACK TRAJECTORIES ACROSS MULTIPLE CAMERAS
% Input: features for individual single-camera trajectories
% Output: matched trajectories across cameras

%% SETUP
% calls config_path, config_exp, loadConfigSettings, gurobi_setup, which
% sets up the workspace and experiment settings

clear; clc; close all;
addpath(genpath('.')); mydir = pwd;
global PATH EXP
config_path; config_exp; loadConfigSettings;
cd(PATH.gurobi_path); gurobi_setup; cd(mydir);


%% LOAD TRAJECTORIES (if EXP.opts.loadData is true)

if EXP.opts.loadData
    
    % load trajectories from selected cameras inside the specified frame range
    [traj, traj_f] = loadTrajectories(EXP.cameras, EXP.frame_range, PATH.temp_extfea_path);
    for i = 1 : numel(traj), traj{i}.MC_id = -1; end                    	% initialize identities to -1
end


%% COMPUTE IDENTITIES (if EXP.opts.computeIdentities is true)

tracking_time = tic;                                                        % start clock
if EXP.opts.computeIdentities
    
    startTime = EXP.frame_range(1);                                         % initialize start of temporal range
    endTime = EXP.frame_range(1) + EXP.t_window - 1;                        % initialize end of temporal range
    
    while startTime <= EXP.frame_range(2)                                   % iterate over temporal ranges
        
        clc; fprintf('Window %d...%d\n', startTime, endTime);               % print loop state
        
        traj = linkIdentities(traj, traj_f, startTime, endTime, EXP.opts);  % attach tracklets and store trajectories as they finish
        
        startTime = endTime   - EXP.t_overlap;                              % update start of temporal range
        endTime   = startTime + EXP.t_window;                               % update end of temporal range
    end
end

% prepare output for evaluation/storage
fprintf('Parsing output...');
tracking_time = toc(tracking_time);                                         % end clock
run_id = strrep(datestr(datetime('now')), ' ', '_');
run_id = strrep(run_id, ':', '-');
fprintf(' done.\n');


%% SAVE DATA (if EXP.opts.saveData is true)

if EXP.opts.saveData
    
    % save mat and txt files
    save(fullfile(PATH.temp_result_path,'resultsMC.mat'), 'traj');
    
    % add log about the experiment
    fileID = fopen(fullfile(PATH.temp_result_path,'log.txt'), 'a');
    fprintf(fileID, 'EXP %s\n------------------------\n', run_id);
    fprintf(fileID, 'cam: %s, frm: %s, win: %s, ovr: %s\n', mat2str(EXP.cameras), mat2str(EXP.frame_range), mat2str(EXP.t_window), mat2str(EXP.t_overlap));
    fprintf(fileID, 'global appearance: %g (%2.2f), patch appearance: %g (%2.2f), motion: %g (%2.2f)\n', EXP.opts.w_global_app, EXP.opts.t_global_app, EXP.opts.w_patch_app, EXP.opts.t_patch_app, EXP.opts.w_motion, EXP.opts.t_motion);
    fprintf(fileID, 'number of people for appearance group: %d\n', EXP.opts.group_size);
    fprintf(fileID, 'tracking completed in %2.2f seconds.\n', tracking_time);
    fprintf(fileID, '\n\n\n'); fclose(fileID);
end
