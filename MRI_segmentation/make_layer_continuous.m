%{
Make each layer continuous, that is, the outer layer enclosure the inner
layer

Benjamin Kao
Last update: 2020/06/01
%}

clear;clc;close all;

%% param
subject='WH';

%% main
load(fullfile('model',['headModel' subject '_EEG.mat']));

new_vol=vol;

dilate_kernel=strel('sphere',1);
skull_dilate_kernel=strel('sphere',2);

% do for sinus
temp_tissue_vol=new_vol==6;
temp_tissue_dil=imdilate(temp_tissue_vol,dilate_kernel);
tissue_boundary=temp_tissue_dil-temp_tissue_vol;

new_vol(new_vol<=2 & tissue_boundary==1)=2; % sinus should be enclosured by scalp

temp_temp_vol=vol;
temp_temp_vol((new_vol-vol)>0)=10;
% sliceViewer(temp_temp_vol);
% keyboard;

for L=5:-1:2
    before_vol=new_vol;
    temp_tissue_vol=new_vol==L;
    if L==3
        temp_tissue_dil=imdilate(temp_tissue_vol,skull_dilate_kernel);
    else
        temp_tissue_dil=imdilate(temp_tissue_vol,dilate_kernel);
    end
    tissue_boundary=temp_tissue_dil-temp_tissue_vol;
    
    new_vol(new_vol<=L-1 & tissue_boundary==1)=L-1;
    
    temp_temp_vol=vol;
    temp_temp_vol((new_vol-before_vol)>0)=10;
%     sliceViewer(temp_temp_vol);
%     keyboard;
    
end

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
temp_temp_vol=vol;
temp_temp_vol((new_new_vol-vol)>0)=10;
sliceViewer(temp_temp_vol);
fprintf('There are %d voxels changed.\n',length(find(new_new_vol-new_vol)));
keyboard;

%% save
vol=new_new_vol;
save(fullfile('model',['headModel' subject '_EEG.mat']),'vol','EEG','center','do_sinus','headsurf','model_version','pialsurf','subject','voxel_size');
disp('Done!');