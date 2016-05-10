function [feasibilityMatrix, motionMatrix, globalAppearanceMatrix, patchAppearanceMatrix, indifferenceMatrix] = computeMatrices(traj, opts, task)
global text; text = cell(4, 1); % initialize text streams
N = length(traj);

% constants
bigV = 10^6;

% parameters
par_indifference = 6000;
speedLimit       = 2.5;
frameRate        = 30;

%% create binary feasibility matrix based on speed and direction
fprintf('Computing feasibility matrix: '); t = tic; text{1} = ''; c = 0;
feasibilityMatrix = zeros(N, N); N_t = N;
for i = 1 : N_t-1
    for j = i+1 : N_t
        if isequal(task, 'reid'), continue; end
        c = c+1;
        printMyText(2, 'pair %d of %d (time elapsed: %d sec)\n', c, nchoosek(N, 2), round(toc(t)));
        
        % check if they simultaneously appear in two different cameras
        % do not merge trajectories from the same camera
        %numel(intersect(traj{i}.wrl_pos(:, 1), traj{j}.wrl_pos(:, 1)))
        if ((traj{i}.c ~= traj{j}.c))% || traj{i}.MC_id == traj{j}.MC_id% && numel(intersect(traj{i}.wrl_pos(:, 1), traj{j}.wrl_pos(:, 1))) < 200) ...
                %|| (traj{i}.c ~=traj{j}.c) | %&& (traj{i}.c ~=traj{j}.c)
            feasibilityMatrix(i,j) = 1;
        end
        
%         if ~isempty(traj{i}.wrl_pos) && ~isempty(traj{j}.wrl_pos)
%             % temporal ordering is required here
%             if traj{i}.wrl_pos(1, 1) < traj{j}.wrl_pos(1, 1), A = traj{i}; B = traj{j}; else A = traj{j}; B = traj{i}; end
%             % compute required number of frames
%             distance    = sqrt(sum((A.wrl_pos(end, [2 3]) - B.wrl_pos(1, [2 3])).^2));
%             frames_betw = abs(B.wrl_pos(1, 1) - A.wrl_pos(end, 1));
%             min_number_of_required_frames = distance / speedLimit * frameRate;
%             
%             % compute directional information
%             L1 = sqrt(sum((A.wrl_pos(end, [2 3]) - B.wrl_pos(1, [2 3])).^2));
%             L2 = sqrt(sum((A.wrl_pos(end, [2 3]) - B.wrl_pos(end, [2 3])).^2));
%             L3 = sqrt(sum((A.wrl_pos(1, [2 3])   - B.wrl_pos(1, [2 3])).^2));
%             
%             if frames_betw > min_number_of_required_frames && L1 < L2 && L1 < L3 && ~isequal(A.c, B.c)
%                 feasibilityMatrix(i,j) = 1; % feasible association
%             end
%         end
    end
end
feasibilityMatrix = feasibilityMatrix + feasibilityMatrix';

%% motion information
fprintf('Computing motion matrix: '); t = tic; text{3} = ''; c = 0;
motionMatrix = zeros * ones(N, N); N_t = N;
for i = 1 : N_t-1
    for j = i+1 : N_t
        if isequal(task, 'reid'), continue; end
        c = c+1;
        printMyText(3, 'pair %d of %d (time elapsed: %d sec)\n', c, nchoosek(N, 2), round(toc(t)));
        if ~isempty(traj{i}.wrl_pos) && ~isempty(traj{j}.wrl_pos) && feasibilityMatrix(i,j) == 1
            
            %temporal ordering is required here
            if traj{i}.wrl_pos(1, 1) < traj{j}.wrl_pos(1, 1), A = traj{i}; B = traj{j}; else A = traj{j}; B = traj{i}; end
            %DATASETS 1 and 2
            if any(A.c==[1 2]) && any(B.c==[1 2])
                t_c_1 = 900;
                motionMatrix(i,j) = 1-(min([1, abs(abs(B.wrl_pos(1,1)-A.wrl_pos(end, 1))-t_c_1)/t_c_1]))-0.5;
            end
            if any(A.c==[2 3]) && any(B.c==[2 3])
                t_c_2 = 1500;
                motionMatrix(i,j) = 1-(min([1, abs(abs(B.wrl_pos(1,1)-A.wrl_pos(end, 1))-t_c_2)/t_c_2]))-0.5;
            end
            
%             traj{i}.wrl_pos(1, end) = 1; traj{j}.wrl_pos(1, end) = 1;
%             traj{i}.wrl_pos(end, end) = -1; traj{j}.wrl_pos(end, end) = -1;
%                
%             % dataset 3
%             pieces_i = [traj{i}.wrl_pos(find(traj{i}.wrl_pos(:, end)==1), 1) traj{i}.wrl_pos(find(traj{i}.wrl_pos(:, end)==-1), 1)]; %#ok
%             pieces_j = [traj{j}.wrl_pos(find(traj{j}.wrl_pos(:, end)==1), 1) traj{j}.wrl_pos(find(traj{j}.wrl_pos(:, end)==-1), 1)]; %#ok
%             
%             for k1 = 1 : size(pieces_i, 1)
%                 for k2 = 1 : size(pieces_j, 1)
%                     
%                     if pieces_i(k1, 1) < pieces_j(k2, 1), A = pieces_i(k1, :); B = pieces_j(k2, :); else A = pieces_j(k2, :); B = pieces_i(k1, :); end
%                     
%                     if 0&&any(traj{i}.c==[1 2]) && any(traj{j}.c==[1 2])
%                         % t_c = 100; s_c = 10000; % dataset 3
%                         t_c = 1400; % dataset 4
%                         value = 1-(min([1, abs(abs(B(1)-A(2))-t_c)/t_c]))-0.5;
%                         %value = exp(-(abs(abs(B(1)-A(2))-t_c))^2/s_c)-0.5;
%                         if (value > motionMatrix(i,j)) || motionMatrix(i,j) == 0, motionMatrix(i,j) = value; end
%                     end
%                     
%                     if 0&&any(traj{i}.c==[3 2]) && any(traj{j}.c==[3 2])
%                         %t_c = 170; s_c = 50000; % dataset 3
%                         t_c = 400; % dataset 4
%                         value = 1-(min([1, abs(abs(B(1)-A(2))-t_c)/t_c]))-0.5;
%                         %value = exp(-(abs(abs(B(1)-A(2))-t_c))^2/s_c)-0.5;
%                         if (value > motionMatrix(i,j)) || motionMatrix(i,j) == 0, motionMatrix(i,j) = value; end
%                     end
%                     
%                     if 0&&any(traj{i}.c==[3 4]) && any(traj{j}.c==[3 4])
%                         %t_c = 300; s_c = 75000; % dataset 3
%                         t_c = 2400; % dataset 4
%                         value = 1-(min([1, abs(abs(B(1)-A(2))-t_c)/t_c]))-0.5;
%                         %value = exp(-(abs(abs(B(1)-A(2))-t_c))^2/s_c)-0.5;
%                         if (value > motionMatrix(i,j)) || motionMatrix(i,j) == 0, motionMatrix(i,j) = value; end
%                     end
%                     
%                     if any(traj{i}.c==[5 4]) && any(traj{j}.c==[5 4])
%                         %t_c = 300; s_c = 75000; % dataset 3
%                         t_c = 1600; % dataset 4
%                         value = 1-(min([1, abs(abs(B(1)-A(2))-t_c)/t_c]))-0.5;
%                         %value = exp(-(abs(abs(B(1)-A(2))-t_c))^2/s_c)-0.5;
%                         if (value > motionMatrix(i,j)) || motionMatrix(i,j) == 0, motionMatrix(i,j) = value; end
%                     end
% 
%                 end
%             end
        end
        if ~isempty(traj{i}.wrl_pos) && ~isempty(traj{j}.wrl_pos) && feasibilityMatrix(i,j) == 1
            % temporal ordering is required here
            if traj{i}.wrl_pos(1, 1) < traj{j}.wrl_pos(1, 1), A = traj{i}; B = traj{j}; else A = traj{j}; B = traj{i}; end
            %frame_difference = abs(B.wrl_pos(1, 1) - A.wrl_pos(end, 1)); % it could happen to be negative in overlapping camera settings
            %space_difference = sqrt(sum((B.wrl_pos(1, [2 3]) - A.wrl_pos(end, [2 3])).^2, 2));
            %vA = sqrt(sum(diff(A.wrl_pos(:, [1 2])).^2, 2)); vA = mean(vA(end-4:end));
            %vB = sqrt(sum(diff(B.wrl_pos(:, [1 2])).^2, 2)); vB = mean(vB(1:5));
            % %motionMatrix(i, j) = max(0, 1 - par_motion * (abs(vA*frame_difference-space_difference)+abs(vB*frame_difference-space_difference))/(2*space_difference));
            %motionMatrix(i, j) = sigmf(-min([abs(vA*frame_difference-space_difference), abs(vB*frame_difference-space_difference)])/space_difference, [0.5 0])-0.3;
            frame_difference = abs(B.wrl_pos(1, 1) - A.wrl_pos(end, 1)); % it could happen to be negative in overlapping camera settings
            space_difference = sqrt(sum((B.wrl_pos(1, [2 3]) - A.wrl_pos(end, [2 3])).^2, 2));
            needed_speed     = space_difference / frame_difference; %mpf
            speedA = sqrt(sum(diff(A.wrl_pos(:, [2 3])).^2, 2)); speedA = mean(speedA(end-9:end));
            speedB = sqrt(sum(diff(B.wrl_pos(:, [2 3])).^2, 2)); speedB = mean(speedB(1:10));
            motionMatrix(i, j) = -(sigmf(mean([abs(speedA-needed_speed), abs(speedB-needed_speed)]), [5 0])-opts.t_motion);
        end
    end
end
motionMatrix = motionMatrix + motionMatrix';
%motionMatrix(eye(size(motionMatrix))==1) = -bigV;
%figure, imagesc(motionMatrix);

%% create global appearance matrix
fprintf('Computing global appearance similarities: ');
globalAppearanceMatrix = zeros(N, N); selectedMatrix = zeros(N, N); N_t = N;
parfor_progress(N_t);
for i = 1 : N_t-1
    parfor_progress;
    for j = 1 : N_t
        if j <= i, continue; end
        if isequal(task, 'reid') || feasibilityMatrix(i,j) > 0
            globalAppearanceMatrix(i, j) = sum(min([traj{i}.mean_hsv; traj{j}.mean_hsv]));
            if any(A.c==[1 2]) && any(B.c==[1 2])   % TODO the iff statements are for checking 
                globalAppearanceMatrix(i, j) = globalAppearanceMatrix(i, j) - 0.7;      %0.7 should be t_ TODO
            end
            if any(A.c==[2 3]) && any(B.c==[2 3])
                globalAppearanceMatrix(i, j) = globalAppearanceMatrix(i, j) - 0.7;
            end
            %if any(A.c==[1 2]) && any(B.c==[1 2])
                %globalAppearanceMatrix(i, j) = globalAppearanceMatrix(i, j) - 0.7;
                
                if sum([traj{i}.mean_hsv, traj{j}.mean_hsv]) <= 1, globalAppearanceMatrix(i, j) = 0; end
            %end
            selectedMatrix(i, j)   = 1;
        end
    end
end
parfor_progress(0);
selectedMatrix = selectedMatrix + selectedMatrix';
globalAppearanceMatrix = globalAppearanceMatrix + globalAppearanceMatrix';
globalAppearanceMatrix(~selectedMatrix) = -Inf;

%% create patch descriptors appearance matrix
fprintf('Computing patch appearance similarities: ');
patchAppearanceMatrix = zeros(N, N); N_t = N;
parfor_progress(N_t);

% iterate over trajectories
if opts.w_patch_app > 0 & false
    for i = 1 : N_t-1
        parfor_progress;
        for j = 1 : N_t
            if j <= i, continue; end
            if ~isequal(task, 'reid') && abs(globalAppearanceMatrix(i,j)) > 0.1, patchAppearanceMatrix(i,j) = globalAppearanceMatrix(i,j); continue; end
            if isequal(task, 'reid'), fprintf('i: %d - j: %d (out of %d)\n', i, j, N_t); end
            % match appearances
            A = traj{i};
            B = traj{j};
            [I, J, ~] = matchTracksMWBM(A, B);
            A.points = A.points(I);
            B.points = B.points(J);
            [ corr, ~, ~ ] = computeCorrelation(A, B);
%             A_gallery = load(fullfile('F:\tracked_patches', sprintf('%d_%d.mat', A.c, A.id)));
%             B_gallery = load(fullfile('F:\tracked_patches', sprintf('%d_%d.mat', B.c, B.id)));
%             figure(2);
%             subplot(1,2,1); m = A_gallery.thisModel{1}; img_A = loadImage(m.frame, m.camera, 'load'); img_A = img_A(m.bb(1):m.bb(2), m.bb(3):m.bb(4), :); imshow(img_A);
%             subplot(1,2,2); m = B_gallery.thisModel{1}; img_B = loadImage(m.frame, m.camera, 'load'); img_B = img_B(m.bb(1):m.bb(2), m.bb(3):m.bb(4), :); imshow(img_B);
%             title(sprintf('%g', corr/3));
%             showMatchedTracks(A,B);
            patchAppearanceMatrix(i,j) = corr/3;
        end
    end
end
parfor_progress(0);
patchAppearanceMatrix = patchAppearanceMatrix + patchAppearanceMatrix';

%% indifference matrix
fprintf('Computing indifference matrix: '); t = tic; text{4} = ''; c = 0;
indifferenceMatrix = zeros(N, N); N_t = N;
frame_difference = zeros(N,N);
for i = 1 : N_t-1
    for j = i+1 : N_t
        if isequal(task, 'reid') || 1, continue; end
        c = c+1;
        printMyText(4, 'pair %d of %d (time elapsed: %d sec)\n', c, nchoosek(N, 2), round(toc(t)));
%         if ~isempty(traj{i}.wrl_pos) && ~isempty(traj{j}.wrl_pos)
%             % temporal ordering is required here
%             if traj{i}.wrl_pos(1, 1) < traj{j}.wrl_pos(1, 1), A = traj{i}; B = traj{j}; else A = traj{j}; B = traj{i}; end
%             frame_difference(i, j) = max(0, B.wrl_pos(1, 1) - A.wrl_pos(end, 1)); % it could happen to be negative in overlapping camera settings
%             indifferenceMatrix(i,j) = sigmf(frame_difference(i,j), [0.001 par_indifference/2]);
%         end
    end
end
indifferenceMatrix = indifferenceMatrix + indifferenceMatrix';
