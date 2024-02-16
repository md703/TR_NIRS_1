%{
Preprocess the output of SPM, delete the noise outside the scalp

Benjamin Kao
Last update: 2020/08/10
%}

clc;clear;close all; clear global all_dir_arr;

%% param
MRI_folder='MRI_raw_datas';
min_probability=51; % =20%, because the value is uint8, 1~256

%% init
% find the folders to process
dir_list=find_nested_dir_list(MRI_folder);
to_process_model_dir_list={};
for i=1:length(dir_list)
    temp_file=dir((fullfile(dir_list{i},'c*.nii')));
    if length(temp_file)==5
        to_process_model_dir_list{end+1,1}=dir_list{i};
    end
end

fprintf('There are %d folders to process\n\n',length(to_process_model_dir_list));

%% main
% for i=1:length(to_process_model_dir_list)
for i=4:5
    fprintf('====================================\nProcessing %d/%d folder\n',i,length(to_process_model_dir_list));
%     if exist(fullfile(to_process_model_dir_list{i},'preprocess_maxIndex.mat'),'file')
%         continue;
%     end
    
    clear seg;
    
    file=dir((fullfile(to_process_model_dir_list{i},'c*.nii')));
    seg(:,:,:,4) = niftiread(fullfile(to_process_model_dir_list{i},file(1).name)); % grey matter
    seg(:,:,:,5) = niftiread(fullfile(to_process_model_dir_list{i},file(2).name)); % white matter
    seg(:,:,:,3) = niftiread(fullfile(to_process_model_dir_list{i},file(3).name)); % CSF
    seg(:,:,:,2) = niftiread(fullfile(to_process_model_dir_list{i},file(4).name)); % skull
    seg(:,:,:,1) = niftiread(fullfile(to_process_model_dir_list{i},file(5).name)); % scalp
    
    seg_line=reshape(seg,[],5);
    seg_line=seg_line';
    [max_val,max_index]=max(seg_line);
    max_val=reshape(max_val,size(seg,1),size(seg,2),size(seg,3));
    max_index=reshape(max_index,size(seg,1),size(seg,2),size(seg,3));
    
    max_val=single(max_val);
    
    % If the probability is too low, set it to tissue 0 (air)
    max_index(max_val<=min_probability) = 0;
    
    % skip the all 1 slice
    to_resize_z=1;
    while to_resize_z<size(max_index,3)
        if (length(find(max_index(:,:,to_resize_z)==1))/(size(max_index,1)*size(max_index,2)))>0.98
            to_resize_z=to_resize_z+1;
        else
            break;
        end
    end
    
    % Delete the other type of tissue outside scalp
    parfor z=to_resize_z:size(max_index,3)
        fprintf('L %d\n',z);
        temp_slice=max_index(:,:,z);
        index_map=fun_image_seg(temp_slice==1);
        head_mask=imfill(double(index_map==1));
        temp_slice(head_mask~=1)=0;
        max_index(:,:,z)=temp_slice;
    end
    save(fullfile(to_process_model_dir_list{i},'preprocess_maxIndex.mat'),'max_index');
end

disp('Done!');

%% functions
function dir_list=find_nested_dir_list(root_dir)
global all_dir_arr;
if length(all_dir_arr)==0
    all_dir_arr{1,1}=root_dir;
else
    all_dir_arr{end+1,1}=root_dir;
end
temp_dir_arr=dir(root_dir);
for i=1:length(temp_dir_arr)
    if temp_dir_arr(i).isdir && strcmp(temp_dir_arr(i).name,'.')==0 && strcmp(temp_dir_arr(i).name,'..')==0
        find_nested_dir_list(fullfile(root_dir,temp_dir_arr(i).name));
    end
end
dir_list=all_dir_arr;
end