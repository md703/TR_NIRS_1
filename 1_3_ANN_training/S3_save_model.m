%{
Save the models into a folder

Benjamin Kao
Last update: 2020/12/23

Ting-Yi Kuo
Last edit: 2023/10/23
%}

clc;clear;close all;

%% param
type=1; % 0:CW, 1:TR
output_dir='model_arrange';

%% main
mkdir(output_dir)

% load('model_dir_2.mat');
model_dir{1,1} = 'CT';
model_dir{1,2} = 'CT_2024-04-22-20-12-15';

for i=1:size(model_dir,1)
    if type==0
        model=load(fullfile(model_dir{i,2},'ANN_model.mat'));
        cw_net=model.net;
        cw_param_range=load(fullfile(model_dir{i,2},'param_range.txt'));
        save(fullfile(output_dir,[model_dir{i,1} '_cw_model.mat']),'cw_net','cw_param_range');  
    elseif type==1
        model=load(fullfile(model_dir{i,2},'ANN_model.mat'));
        tr_net=model.net;
        tr_param_range=load(fullfile(model_dir{i,2},'param_range.txt'));
        save(fullfile(output_dir,[model_dir{i,1} '_tr_model.mat']),'tr_net','tr_param_range');
    end
    
end

disp('Done!');