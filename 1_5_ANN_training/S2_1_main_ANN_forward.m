%{
Use the trained ANN to generate spec, in order to compare with the simulated spectrum or lut spectrum

Benjamin Kao
Last update: 2020/12/23
%}

clc;clear;close all;

%% param
model_dir={'KB_2023-10-11-20-35-47','WH_2023-11-14-21-59-44','ZJ_2023-11-01-14-22-50'}; % the model train folder
% model_dir_arr=load('model_dir.mat'); % the model train folder

num_SDS=5;
num_gate=10;

for i=1:length(model_dir) %)size(model_dir_arr.model_dir,1)
%     clearvars -except i model_dir_arr
    
%     model_dir=model_dir_arr.model_dir{i,2};
    
    %% test
    fun_ANN_init(model_dir{i});
    
    %% test 1
    op=[0.2750  162.5000  0.2000  125.0000  0.0420  23.0000  0.2500  150.0000];
    spec=fun_ANN_forward(op);
    
    figure;
    tiledlayout('flow');
    for s=1:num_SDS
        nexttile;
        plot(1:1:10,spec(1+(s-1)*num_gate:s*num_gate),'Linewidth',2);
        set(gca,'YScale','log');
    end
 
    print(fullfile(model_dir{i},'ANN_forward_test1.png'),'-dpng','-r200');
    
    
    %% test 1
%     op=load('OPs_to_sim_6/toSim_OP_1.txt');
%     op=op(:,1:8);
%     spec=fun_ANN_forward(op);
%     save(fullfile(model_dir,['ANN_forward_test1.txt']),'spec','-ascii','-tabs');
    
    %% test 2
%     op=load('OPs_to_sim_11/toSim_OP_65.txt');
%     op=op(:,1:8);
%     spec=fun_ANN_forward(op);
%     save(fullfile(model_dir,['ANN_forward_test2.txt']),'spec','-ascii','-tabs');
    
    %% test 3
%     op=load('OPs_to_sim_11/toSim_OP_66.txt');
%     op=op(:,1:8);
%     spec=fun_ANN_forward(op);
%     save(fullfile(model_dir,['ANN_forward_test3.txt']),'spec','-ascii','-tabs');
end

disp('Done!');