

clc; clear; close all;

%% param
folder_arr={'20201209_test_14'}; % the folder of the experiment
phantom_name_arr={'p1','p2'}; % in the same order as the phantom 1,2...n

num_SDS=5;
num_gate=10;
num_phantom=6;
SDS_dist_arr=[1.5 2.2 2.9 3.6 4.3]; % cm

calib_mode=1; % 1=MCML, 2=MCX

output_folder_arr={'calibration_MCML_2','calibration_MCX'};
calib_mode_arr={'MCML','MCX'};
simulate_folder_arr={'phantom_simulation_MCML_FDA_7EK_2_dilated','phantom_simulation_MCX'}; % the folders contain the siulation spectrum of the phantoms
sim_prefix_arr={'phantom_','effective_reflectance_ph_'}; % the file name prefix of the simulated spectrum file in the folder
sim_postfix_arr={'_TPSF',''}; % the file name postfix of the simulated spectrum file in the folder
sim_ph_index=[1 2 3 4 5 6]; % the index of the simulated phantom corresponding to the measured phantom
sim_SDS_index=[1 2 3 4 5 6]; % the SDS in the simulated spectrum correspond to the measured spectrum

for fi=1:length(folder_arr)
    
    %% for flat phantom
    load(fullfile(folder_arr{fi},'TPSF_processed.mat'));    % load measured data
    load(fullfile(folder_arr{fi},'TPSF_collect.mat'));      % load measured data
    
    simulate_folder=simulate_folder_arr{calib_mode};        % load phantom simulation data
    
    output_folder=fullfile(folder_arr{fi},output_folder_arr{calib_mode});
    
    measure_IRF=IRF_mean;
    measure_TPSF={};
    for p=1:num_phantom
        for s=1:num_SDS
            measure_TPSF{1,p}(:,s)=mean(TPSF_orig{p,s},2);
        end
    end
    
    simulate_TPSF={};
    for p=1:num_phantom
        simulate_TPSF{1,p}=load(fullfile(simulate_folder,[sim_prefix_arr{calib_mode} num2str(sim_ph_index(p)) sim_postfix_arr{calib_mode} '.txt']));
        simulate_TPSF{1,p}=simulate_TPSF{1,p}(:,sim_SDS_index);
    end
    
    %% do convolution
    for p=1:num_phantom
        for s=1:num_SDS
            simulate 
    
    
    
    
    
        
    
    
    
    
    
    
    
    
    
    
    