%{
Find the CV of simulated reflectance, and reduce the detected photon number if the CV is small enough and detected photon is large enough.
run 'S1_MCML_sim_lkt.m' before this code

Benjamin Kao
Last update: 2020/10/15
%}

clc;clear;close all;

%% param
input_dir='MCML_sim_lkt'; % the simulated lookup table folder
num_SDS=7;
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
        PL_arr=cell(1,num_SDS);
        group_CV_arr=cell(1,num_SDS);
        for s=1:num_SDS
            fprintf('%d ',s)
            group_CV_arr{s}=[];
            temp_PL=fun_load_binary_pathlength_output(sum_file,s,fullfile(input_dir,folder_list{i},['pathlength_SDS_' num2str(s) '.bin']));
            assert(size(temp_PL,1)==sim_sum.SDS_detected_number(s));
            if size(temp_PL,1)/2>=min_detpt
                each_photon_detected_weight=temp_PL(:,1).*exp(-1*sum(temp_PL(:,2:num_layer+1).*layer_mua,2));
                to_divide_group=2;
                divide_group_okey=1;
                to_break_flag=0;
                while size(temp_PL,1)/to_divide_group>=min_detpt
                    photon_in_subGroup=ones(1,to_divide_group)*floor(size(temp_PL,1)/to_divide_group);
                    photon_in_subGroup(1:rem(size(temp_PL,1),to_divide_group))=photon_in_subGroup(1:rem(size(temp_PL,1),to_divide_group))+1;
                    assert(sum(photon_in_subGroup)==size(temp_PL,1));
                    photon_in_subGroup=cumsum([0 photon_in_subGroup]);
                    CV_ref_subGroup=zeros(num_shuffle_time,to_divide_group);
                    for sh=1:num_shuffle_time
                        shuffled_index=randperm(size(temp_PL,1));
                        for sg=1:to_divide_group
                            CV_ref_subGroup(sh,sg)=sum(each_photon_detected_weight(shuffled_index(photon_in_subGroup(sg)+1:photon_in_subGroup(sg+1))));
                        end
                    end
                    CV_ref_subGroup=mean(CV_ref_subGroup,1);
                    temp_CV=std(CV_ref_subGroup)/mean(CV_ref_subGroup);
                    group_CV_arr{s}(end+1,:)=[to_divide_group temp_CV];
                    if temp_CV<=max_CV
                        divide_group_okey=to_divide_group;
                        to_divide_group=ceil(to_divide_group*1.2);
                        if size(temp_PL,1)/to_divide_group<min_detpt
                            to_break_flag=1;
                        end
                    else
                        to_break_flag=1;
                    end
                    if to_break_flag==1
                        to_divide_group=divide_group_okey;
                        each_photon_weight_arr(s)=sim_sum.each_photon_weight/to_divide_group;
                        divide_times_arr(s)=to_divide_group;
                        PL_arr{s}=temp_PL(shuffled_index(1:floor(size(temp_PL,1)/to_divide_group)),:);
                        break;
                    end
                end
            else
                each_photon_weight_arr(s)=sim_sum.each_photon_weight;
                divide_times_arr(s)=1;
                PL_arr{s}=temp_PL;
                group_CV_arr{s}=[1 0];
            end
        end
        save(fullfile(input_dir,folder_list{i},'sim_PL_merge.mat'),'PL_arr','each_photon_weight_arr','divide_times_arr');
        save(fullfile(input_dir,folder_list{i},'group_CV_arr.mat'),'group_CV_arr');
        for s=1:num_SDS
            delete(fullfile(input_dir,folder_list{i},['pathlength_SDS_' num2str(s) '.bin']));
        end
        movefile(fullfile(input_dir,folder_list{i},'summary.json'),fullfile(input_dir,folder_list{i},'old_summary.json'))
        fprintf('\n');
    end
end