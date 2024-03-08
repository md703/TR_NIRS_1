%{
Rename the files from folder to 'XX.mat' 

Benjamin Kao
Last update: 2020/11/12
%}

clc;clear;close all;

%% param
input_dir='20201117_test_2';
% fileName_arr={'bg_1','bg_2','bg_3','bg_4','p1_1','p1_2','p1_3','p1_4','p1_5','p1_6','p1_7','p1_8','p2_1','p2_2','p2_3','p3_1','p3_2','p3_3','p4_1','p4_2','p4_3','p5_1','p5_2','p5_3','p6_1','p6_2','p6_3','WW_1','WW_2','WW_3','WW_4'};
fileName_arr={'bg_1','bg_2','bg_3','bg_4','bg_5','bg_6'};

%% main
for i=1:length(fileName_arr)
    copyfile(fullfile(input_dir,fileName_arr{i},'SDS_spec_arr.mat'),fullfile(input_dir,['SDS_spec_arr_' fileName_arr{i} '.mat']));
end

disp('Done!');