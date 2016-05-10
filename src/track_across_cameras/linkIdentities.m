function traj = linkIdentities(traj, traj_f, startTime, endTime, opts)
%LINKIDENTITIES
% traj: cell array of single camera person trajectory structures
% traj_f: Nx2 matrix of start and end frames of trajectory
% startTime: first frame of interest (unadjusted)
% endTime: last frame of interest (unadjusted)

sameIDvalue = 20;

% select trajectories that will be associated in this time window
% either because they fall in the time range or because they belong to
% identities who do so.
startFrames = cellfun(@(x) frameAdjust(x.c, startTime), traj);              % adjusted first frames of interest for each trajectory
endFrames = cellfun(@(x) frameAdjust(x.c, endTime), traj);                  % adjusted last frames of interest for each trajectory
time_condition = traj_f(:, 2) > startFrames & traj_f(:, 1) < endFrames;     % logical vector for trajectories that satisfy time condition

ids_win = cellfun(@(x) x.MC_id, traj(time_condition), 'uniformoutput', false);
ids_win = unique([ids_win{:}]); ids_win = ids_win(ids_win~=-1);

ids_all = cellfun(@(x) x.MC_id, traj, 'uniformoutput', false);
ids_all = [ids_all{:}]';

in_window = time_condition | ismember(ids_all, ids_win);
in_window_ids = find(in_window);

this_traj = traj(in_window);
ids = cellfun(@(x) x.MC_id, this_traj, 'uniformoutput', false);
ids = [ids{:}]';

% APPEARANCE GROUPING
if numel(this_traj) < 2, return; end
app_grouping_labels = findAppearanceGroups(this_traj, ids, opts.group_size);

%% SOLVE SUBPROBLEMS
for l = unique(app_grouping_labels)'
    fprintf('\nSOLVING APPEARANCE GROUP %d of %d:\n', find(l==unique(app_grouping_labels)), numel(unique(app_grouping_labels))); fprintf('--------------------------------------------------------------------------\n');
    this_traj_app = this_traj(app_grouping_labels==l);
    in_group_ids  = in_window_ids(app_grouping_labels==l);
    
    %% COMPUTE EVIDENCE MATRICES
    [feasibilityMatrix, motionMatrix, globalAppearanceMatrix, patchAppearanceMatrix, indifferenceMatrix] = computeMatrices(this_traj_app, opts, 'track');
    motionMatrix(motionMatrix > 100) = Inf;
    motionMatrix(motionMatrix < -100) = -Inf;
    
    % dataset 1,2 a=1,m=0.15
    % dataset 3 a=1,m=1
    % dataset 4 a=1,m=0
    correlationMatrix = ...
        1.0 * globalAppearanceMatrix + ...
        0.15 * motionMatrix;
    % 1.0 is w_global_
    
    correlationMatrix(correlationMatrix > 100) = Inf; correlationMatrix(correlationMatrix < -100) = -Inf;
    correlationMatrix(~feasibilityMatrix) = -Inf;
    correlationMatrix(isnan(correlationMatrix)) = 0;
    correlationMatrix(eye(size(correlationMatrix))==1) = 0;
    
    figure(1);
    subplot(1, 4, 1); imagesc(globalAppearanceMatrix); colorbar;
    subplot(1, 4, 2); imagesc(motionMatrix); colorbar;%.*(1-indifferenceMatrix)*4); colorbar;
    subplot(1, 4, 4); imagesc(correlationMatrix); colorbar;
    drawnow;
    
    1;
    %%
    %appearanceMatrix(appearanceMatrix > 100) = Inf; appearanceMatrix(appearanceMatrix < -100) = -Inf;   
    
    % IMPOSE HARD LINKS
    % check if trajectories involved in the correlation matrix already have a
    % link = add super positive evidence to those. I also do not want to merge
    % two trajectories that were previously tracked = add super negative
    % evidence to those.
    ids = cellfun(@(x) x.MC_id, this_traj_app, 'uniformoutput', false); ids = [ids{:}]';
    pos = find(ids~=-1); if numel(pos) > 1, combos = nchoosek(pos, 2); else combos = []; end
    for j = 1 : size(combos, 1)
        % either they are the same or they are different
        if ids(combos(j, 1)) == ids(combos(j, 2)), mul = +1; else mul = -1; end
        correlationMatrix(combos(j, 1), combos(j, 2)) = mul*sameIDvalue; correlationMatrix(combos(j, 2), combos(j, 1)) = mul*sameIDvalue;
    end
    
%     global to_link;
%     ids_s = cellfun(@(x) x.id, this_traj_app, 'uniformoutput', false); ids_s = [ids_s{:}]';
%     pos = find(ids_s~=-1); if numel(pos) > 1, combos = nchoosek(pos, 2); else combos = []; end
%     for j = 1 : numel(ids_s)
%         if ismember([ids_s(combos(j, 1)), ids_s(combos(j, 2))], to_link, 'rows') || ismember([ids_s(combos(j, 2)), ids_s(combos(j, 1))], to_link, 'rows')
%             correlationMatrix(combos(j, 1), combos(j, 2)) = +Inf; correlationMatrix(combos(j, 2), combos(j, 1)) = +Inf;
%         end
%     end
    
    % SOLVE BIP PROBLEM
    fprintf('Solving BIP subproblem...\n'); t_bip = tic;
    greedySolution = AL_ICM(sparse(correlationMatrix)); % init solution to BIP
    labels         = solveBIP(correlationMatrix, greedySolution);
    fprintf('\b done in %d sec!\n', round(toc(t_bip)));
    
    % merge results
    traj = mergeResults(traj, labels, ids, in_group_ids);
    
end
end