function config = loadExperimentSetting(config_file)
%LOADEXPERIMENTSETTING Load a configuration file for specific experiment
%   This function takes as input the path of a configuration file and
%   returns a struct containing all the parameters to run the experiment
%   and reproduce the same results over multiple runs.

%% OPEN FILE
if ~exist(config_file, 'file')
    assert('Configuration file doesn''t exist...');
end
fid = fopen(config_file);

%% READ FILE LINE BY LINE
tline = fgetl(fid);
while ischar(tline)
    % skip line if empty or comment
    if isempty(tline) || strcmp(strtrim(tline(1)), '#')
        tline = fgetl(fid); continue;
    end
    
    % split parameter into variable name and value
    C = strsplit(tline,'=');
    for i = 1 : length(C), C{i} = strtrim(C{i}); end
    
    % check if the value is numeric or string
    if ~isempty(C{2}) && ismember(C{2}(1), '0123456789[]-+')
        eval(sprintf('config.%s = %s;', C{1}, C{2}));
    else
        eval(sprintf('config.%s = ''%s'';', C{1}, C{2}));
    end
    
    % read next line
    tline = fgetl(fid);
end

%% CLOSE FILE
fclose(fid);

%% PATHS RELATED TO THE SPECIFIC DATASET
% [path, image_path] = path_config;
% config.path                 = sprintf(path, config.camera); %#ok
% config.groundTruthFile      = fullfile(config.path, 'groundtruth.top');
% config.framesDirectory      = sprintf(image_path, config.camera);
% config.framesFormat         = '%06d.jpg'; %'%d.jpg';
% config.detectionsDir        = fullfile(config.path, 'detections');
% config.appearanceDir        = fullfile(config.path, 'appearance');
% config.trackletsDir         = fullfile(config.path, 'tracklets');
% config.trajectoriesFile     = fullfile(config.path, 'trackerOutput.top');
end