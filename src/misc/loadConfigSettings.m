function [] = loadConfigSettings()
% load experimental settings for each camera
global PATH EXP DATASET

DATASET = cell(max(EXP.cameras),1);
for c = EXP.cameras
    DATASET{c} = loadExperimentSetting(fullfile(PATH.data_config_path, sprintf('%d.config', c)));
end
