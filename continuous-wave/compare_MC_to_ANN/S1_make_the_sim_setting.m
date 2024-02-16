%{
Change the different mus for running lookup table using MCX with 5-layer MRI model
Change the param of scalp, skull, CSF and GM, mus of WM = 3* GM

Benjamin Kao
Last update: 2020/12/01
Version: 4.41
%}

clc;clear;close all;
%% param
model_folder='models'; % the folder of the models
target_name_arr={'KB'}; % the name of the model to simulate
num_photon=1E11; % the number of photon
num_SDS=7; % number of detectors

mua_ub=[0.6 0.45 0.1   0.5]; % 1/cm
mua_lb=[0.1 0.05 0.015 0.05]; % 1/cm
mus_ub=[350 350 37 350]; % 1/cm
mus_lb=[50 50 10 50]; % 1/cm

param_range(1,:)=[mua_ub mus_ub];
param_range(2,:)=[mua_lb mus_lb];

mu_table=[];
for t=1:15
    mu_table(end+1,:)=rand(1,8).*(param_range(1,:)-param_range(2,:))+param_range(2,:);
end
mus_table=mu_table(:,5:8);
mus_table(:,5)=mus_table(:,4)*3;

n=1.4;
g=0.9;

sim_version=4.41;

%% init
% make the mus table
    
% simulation setting
sim_set.num_SDS=num_SDS;
sim_set.detector_r=[1.5 1.5 1.5 1.5 1.5]'; % mm
sim_set.detector_larger_r=sim_set.detector_r.*2;
sim_set.detector_NA=ones(sim_set.num_SDS,1)*0.26;
sim_set.fiber_n=1.457;
sim_set.num_photon=num_photon;
sim_set.photon_per_simulation=1E9;%200000000;
sim_set.mcx_max_detpt=60000000;
sim_set.source_type='cone';
sim_set.source_NA=0.26;
sim_set.source_r=0;


%% main
for ti=1:length(target_name_arr)
    clearvars -except target_name_arr ti model_folder layer_mus mus_table sim_set sim_version n g;
    
    fprintf('Processing subject %d/%d\n',ti,length(target_name_arr));
    
    %% init
    target_name=target_name_arr{ti};
    
    target_folder=target_name;
    mkdir(target_folder);
    
    fid=fopen(fullfile(target_folder,'sim_version.txt'),'w');
    fprintf(fid,'%.2f',sim_version);
    fclose(fid);
    
    MRI_voxel_file=fullfile(model_folder,['headModel' target_name '_EEG.mat']);
    load(MRI_voxel_file);
    
    if exist('model_version','var')==0
        model_version=1;
        do_sinus=0;
    end
    
    % change some setting according to model
    if do_sinus==1
        sim_set.num_layer=6;
        sim_set.to_output_layer=1:6;
        sim_set.n=[n n n n n 1];
        sim_set.g=[g g g g g 1];
    else
        sim_set.num_layer=5;
        sim_set.to_output_layer=1:5;
        sim_set.n=ones(sim_set.num_layer,1)*n;
        sim_set.g=ones(sim_set.num_layer,1)*g;
    end
    
    %% save the setting
%     save(fullfile(target_folder,'layer_mus.mat'),'layer_mus');
    
    %% save the settings
    copyfile(fullfile(model_folder,[target_name '_probe_pos.txt']),fullfile(target_folder,[target_name '_probe_pos.txt']));
    copyfile(fullfile(model_folder,[target_name '_probe_dir.txt']),fullfile(target_folder,[target_name '_probe_dir.txt']));
    save(fullfile(target_folder,'mus_table.txt'),'mus_table','-ascii','-tabs');
    save(fullfile(target_folder,'mu_table.txt'),'mu_table','-ascii','-tabs');
    save(fullfile(target_folder,'sim_set.mat'),'sim_set');
    
    % backup this script
    copyfile([mfilename '.m'],fullfile(target_folder,[mfilename '.m']));
    
    %% final
    fprintf('Done!  There will be %d simulation.\n',size(mus_table,1));
end