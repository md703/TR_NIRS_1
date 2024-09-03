%{
Collect simulation results in 'sim_PL_merge.mat'.
Run 'S1_MCML_sim_lkt.m' before this code.

Benjamin Kao
Last update: 2020/10/15

Ting-Yi Kuo
Last edit: 2024/3/15
%}

clc;clear;close all;

%% param
input_dir='MCML_sim_lkt'; % the simulated lookup table folder
num_SDS=5;
num_gate=200;
cfg.tstep=0.025E-9;
% cfg.tstep=5E-10;
cfg.tend=5E-9;

num_layer=1;
max_CV=0.005; % the max cv of each group
min_detpt=10000; % the min number of detected photon
layer_mua=[0.5]; % 1/cm
num_shuffle_time=10;

%% init
dir_list=dir(input_dir);

folder_list={};
for i=1:length(dir_list)
    if dir_list(i).isdir==1 && strcmp(dir_list(i).name,'.')==0 && strcmp(dir_list(i).name,'..')==0
        folder_list{end+1}=dir_list(i).name;
    end
end

%% main
for i=1:length(folder_list)
    sum_file=fullfile(input_dir,folder_list{i},'summary.json');
    if exist(sum_file,'file')
        fprintf('Processing folder: %s , SDS ',folder_list{i});
        sim_sum=jsondecode(fileread(sum_file));
        each_photon_weight_arr=zeros(1,num_SDS);
        divide_times_arr=zeros(1,num_SDS);
        PL_arr=cell(num_gate,num_SDS);
        group_CV_arr=cell(1,num_SDS);
        for s=1:num_SDS
            fprintf('%d ',s)
            group_CV_arr{s}=[];
            temp_PL=fun_load_binary_pathlength_output(sum_file,s,fullfile(input_dir,folder_list{i},['pathlength_SDS_' num2str(s) '.bin']));
            assert(size(temp_PL,1)==sim_sum.SDS_detected_number(s));
            
            detpt_PL_arr=fun_MCX_det_time(temp_PL,cfg,num_gate);
            PL_arr(:,s)=detpt_PL_arr;
            
            each_photon_weight_arr(s)=sim_sum.each_photon_weight;
            divide_times_arr(s)=1;
            group_CV_arr{s}=[1 0];
            
        end
        
        
        detPL_state=whos('PL_arr');
        if detPL_state.bytes/1024^2>500 % if the file will be too large
            save(fullfile(input_dir,folder_list{i},'sim_PL_merge.mat'),'PL_arr','each_photon_weight_arr','divide_times_arr','-v7.3');
        else
            save(fullfile(input_dir,folder_list{i},'sim_PL_merge.mat'),'PL_arr','each_photon_weight_arr','divide_times_arr');
        end
        save(fullfile(input_dir,folder_list{i},'group_CV_arr.mat'),'group_CV_arr');
%         for s=1:num_SDS
%             delete(fullfile(input_dir,folder_list{i},['pathlength_SDS_' num2str(s) '.bin']));
%         end
        movefile(fullfile(input_dir,folder_list{i},'summary.json'),fullfile(input_dir,folder_list{i},'old_summary.json'))
        fprintf('\n');
    end
end

%% 
% for i=1:length(folder_list)
%     movefile(fullfile(input_dir,folder_list{i},'old_summary.json'),fullfile(input_dir,folder_list{i},'summary.json')) 
% end