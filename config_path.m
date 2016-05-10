function [ ] = config_path
%CONFIG_PATH configure file paths in the user edit section
global PATH

PATH = [];
%% USER EDIT SECTION %%

% data read paths
PATH.data_images_path = '/usr/project/xtmp/ristani/dukecampus/allframes';   % images directory
PATH.data_bacsub_path = '/usr/project/xtmp/ristani/dukecampus/masks';       % background masks directory
PATH.data_config_path = '/usr/project/xtmp/rsz3/config';                    % camera config files directory
PATH.data_images_fmat = '%d.jpg';                                           % images format
PATH.data_bacsub_fmat = '%d.png';                                           % background masks format
PATH.data_detect_path = '/usr/xtmp/ristani/dukecampus/code/detections';     % people detections directory

% data write paths
PATH.temp_ppltrk_path = '/usr/project/xtmp/rsz3/people_tracker';            % people tracker output
PATH.temp_extfea_path = '/usr/project/xtmp/rsz3/extract_features';          % trajectory features output
PATH.temp_result_path = '/usr/project/xtmp/rsz3/results';                   % MTMC tracking results

% config path
PATH.gurobi_path = '/home/home5/rsz3/gurobi651/linux64/matlab';             % gurobi matlab integration

%% DO NOT MODIFY BELOW %%

fieldnames = fields(PATH);

% create data write path folders
fieldIdx = find(strncmp('temp_', fieldnames,5 ))';
for ii=fieldIdx
    fpath = PATH.(fieldnames{ii});
    try
        mkdir(fpath);
    catch
        warning('CONFIG_PATH: mkdir of %s is not permitted', fpath);
    end
end

% Code to run on Windows platform
if ispc
    for ii=1:length(fieldnames)
        PATH.(fieldnames{ii}) = regexprep(PATH.(fieldnames{ii}), '/','\\\');
    end
end