%{
Fill the holes in the model.

Benjamin Kao
Last update: 2020/06/01
%}

clear;clc;close all;

%% param
subject='YH';

%% main
load(fullfile('model',['headModel' subject '_EEG.mat']));

% sliceViewer(vol);
% keyboard;

new_vol=fillholes3d(vol,2);

temp_vol=vol>0;
temp_new_vol=new_vol>0;
temp_temp_vol=new_vol;
temp_temp_vol((temp_new_vol-temp_vol)>0)=10;
% sliceViewer((temp_new_vol-temp_vol)*7+vol);
sliceViewer(temp_temp_vol);
fprintf('There are %d voxels changed index.\n',length(find(new_vol-vol)));
fprintf('There are %d voxels changed from 0 to tissue.\n',length(find(temp_new_vol-temp_vol)));
keyboard;

new_new_vol=fillholes3d(new_vol,2);
temp_new_new_vol=new_new_vol>0;
fprintf('There are %d voxels changed.\n',length(find(new_new_vol-new_new_vol)));
keyboard;

%% save
vol=new_new_vol;
save(fullfile('model',['headModel' subject '_EEG.mat']),'vol','EEG','center','do_sinus','headsurf','model_version','pialsurf','subject','voxel_size');
disp('Done!');