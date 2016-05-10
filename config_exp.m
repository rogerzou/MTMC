function [] = config_exp
%CONFIG_EXP configure experimental settings
global EXP

EXP = [];
%% EXTRACT FEATURES

% specify camera and frame range
EXP.cameras     = [1 2];
EXP.frame_range = [1 20];


%% TRACKING ACROSS CAMERAS

EXP.t_window    = 2500;
EXP.t_overlap   = EXP.t_window/2;           % t_window - window stride

EXP.opts.group_size         = 80;
EXP.opts.w_global_app       = 1.00;      EXP.opts.t_global_app       = 0.70;        % contribution of global appearance to the correlation matrix and treshold
EXP.opts.w_patch_app        = 0.00;      EXP.opts.t_patch_app        = 0.00;        % contribution of patch features to the correlation matrix and threshold
EXP.opts.w_motion           = 0.50;      EXP.opts.t_motion           = 0.53;        % contribution of spatiotemporal coherence data to the correlation matrix

EXP.opts.loadData           = true;


EXP.opts.computeIdentities  = true;
EXP.opts.evaluateResults    = true;
EXP.opts.saveData           = true;
EXP.opts.showResults        = true;
