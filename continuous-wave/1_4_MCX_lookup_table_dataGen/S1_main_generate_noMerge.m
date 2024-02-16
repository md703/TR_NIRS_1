%{
Use the mcx lookup table to generate training data for ANN
Not use the merged lookup table, but use the original simulated folders

Benjamin Kao
Last update: 2021/01/04
%}

clc;clear;close all;

%% param
lookup_table_arr='/home/md703/Documents/TY/TR-NIRS/continuous-wave/1_3_MCX_lookup_table_CW'; % the dir containing the unmerged lookup table
% ratio_model_dir=fullfile('..','20200328_MCX_invivo_reflectance_simulation','sim_2E10_n1457_diffNA_16','AIO_model_stepwise_9'); % the dir containing the highNA/lowNA regression model
subject_name_arr={'KB'}; % the name of the subjects

num_layer=4; % number of layer to random
setting_r=0.2; % the radius of true detector, in mm

% about parameters
mua_ub=[0.6 0.45 0.1   0.5]; % 1/cm
mua_lb=[0.1 0.05 0.015 0.05]; % 1/cm
mus_ub=[350 350 37 350]; % 1/cm
mus_lb=[50 50 10 50]; % 1/cm

% mua_ub=[0.6 0.45 0.1   0.7]; % 1/cm
% mua_lb=[0.03 0.01 0.015 0.02]; % 1/cm
% mus_ub=[350 350 37 410]; % 1/cm
% mus_lb=[50 50 10 50]; % 1/cm

% about random
num_random=3000; % how many nuber to random, for mua.  For mus, it's this number + number of original lookup table set
normal_cutoff=2; % if the random value is not in [-a a], than re-generate a random number

max_mua_sameTime=500; % how many mua set to calculate at the same time, use smaller value for smaller memory consumption

test_mode=0; % =0 to generate the whole training data; =1 or more to generate the result of lookup table using the testing parameters


for sbj_i=1:length(subject_name_arr)
    clearvars -except max_mua_sameTime num_random normal_cutoff mua_ub mua_lb mus_ub mus_lb num_layer setting_r test_mode lookup_table_arr ratio_model_dir sbj_i subject_name_arr;
    
    subject_name=subject_name_arr{sbj_i};

    %% init
    lkt_dir=fullfile(lookup_table_arr,subject_name); % the dir containing the unmerged lookup table
    
    % make the output dir name
    if test_mode==0
        output_dir=[subject_name '_' datestr(datetime('now'),'yyyy-mm-dd-HH-MM-ss')];
    else
        output_dir=[subject_name '_test' num2str(test_mode) '_' datestr(datetime('now'),'yyyy-mm-dd-HH-MM-ss')];
    end
    mkdir(output_dir);

    % load lookup table information
    lkt_sim_set=load(fullfile(lkt_dir,'sim_set.mat'));
    lkt_sim_set=lkt_sim_set.sim_set;
    lkt_layer_mus=load(fullfile(lkt_dir,'layer_mus.mat'));
    lkt_layer_mus=lkt_layer_mus.layer_mus;
    lkt_mus_table=load(fullfile(lkt_dir,'mus_table.txt'));

    % load ratio regression model
%     temp_model=load(fullfile(ratio_model_dir,'regression_model.mat'));
% %     temp_model=load(fullfile(ratio_model_dir,'reflectance_ratio.mat'));
%     regression_model=temp_model.regression_model;

    % save the bound
    param_ub=[mua_ub mus_ub];
    param_lb=[mua_lb mus_lb];
    to_save=[param_ub; param_lb];
    save(fullfile(output_dir,'param_range.txt'),'to_save','-ascii','-tabs');

    if test_mode==0
        %% random generate the mua array
        random_index_arr=normrnd(0,1,num_random,num_layer);
        while sum(random_index_arr(:)>normal_cutoff)~=0 && sum(random_index_arr(:)<-normal_cutoff)~=0
            random_index_arr(random_index_arr>normal_cutoff)=normrnd(0,1,length(find(random_index_arr>normal_cutoff)),1);
            random_index_arr(random_index_arr<-normal_cutoff)=normrnd(0,1,length(find(random_index_arr<-normal_cutoff)),1);
        end

        mua_param_arr=zeros(size(random_index_arr));
        for L=1:num_layer
            mua_param_arr(:,L)=(random_index_arr(:,L)+normal_cutoff)/(2*normal_cutoff)*(mua_ub(L)-mua_lb(L))+mua_lb(L);
        end

        %% random generate the mus array, and combine with the original lookup table mus
        random_index_arr=normrnd(0,1,num_random,num_layer);
        while sum(random_index_arr(:)>normal_cutoff)~=0 && sum(random_index_arr(:)<-normal_cutoff)~=0
            random_index_arr(random_index_arr>normal_cutoff)=normrnd(0,1,length(find(random_index_arr>normal_cutoff)),1);
            random_index_arr(random_index_arr<-normal_cutoff)=normrnd(0,1,length(find(random_index_arr<-normal_cutoff)),1);
        end

        mus_param_arr=zeros(size(random_index_arr));
        for L=1:num_layer
            mus_param_arr(:,L)=(random_index_arr(:,L)+normal_cutoff)/(2*normal_cutoff)*(mus_ub(L)-mus_lb(L))+mus_lb(L);
        end
        mus_param_arr(end+1:end+size(lkt_mus_table,1),:)=lkt_mus_table(:,1:num_layer); % add the known correct mus points
    end

    %% test
    if test_mode==1
        op=load('OPs_to_sim_6/toSim_OP_1.txt');
        mus_param_arr=op(:,2:2:8);
        mua_param_arr=op(:,1:2:8);
    elseif test_mode==2
        op=load('OPs_to_sim_11/toSim_OP_65.txt');
        mus_param_arr=op(:,2:2:8);
        mua_param_arr=op(:,1:2:8);
    elseif test_mode==3
        op=load('OPs_to_sim_11/toSim_OP_66.txt');
        mus_param_arr=op(:,2:2:8);
        mua_param_arr=op(:,1:2:8);
    end

    %% find the index in the lookup table, which is a 4-D array, which dimention is the mus for one layer, and each value is the corresponding index in a 1-D array
    in_place_arr=zeros(length(lkt_layer_mus{1}),length(lkt_layer_mus{2}),length(lkt_layer_mus{3}),length(lkt_layer_mus{4}));
    for L1=1:length(lkt_layer_mus{1})
        for L2=1:length(lkt_layer_mus{2})
            for L3=1:length(lkt_layer_mus{3})
                for L4=1:length(lkt_layer_mus{4})
                    lkt_index=find(lkt_mus_table(:,1)==lkt_layer_mus{1}(L1) & lkt_mus_table(:,2)==lkt_layer_mus{2}(L2) & lkt_mus_table(:,3)==lkt_layer_mus{3}(L3) & lkt_mus_table(:,4)==lkt_layer_mus{4}(L4));
                    in_place_arr(L1,L2,L3,L4)=lkt_index;
                end
            end
        end
    end


    %% find the lookup table value for every mus set of the given mua
    temp_mua_param_arr=mua_param_arr; % make the array another shape for better array multiply performance
    temp_mua_param_arr(:,5)=mua_param_arr(:,4)*0.5;
    temp_mua_param_arr=temp_mua_param_arr';
    % divide the mua array into many subarray if it's too large
    num_mua_set=ceil(size(temp_mua_param_arr,2)/max_mua_sameTime); % how many mua subarray
    in_array_mua_param_arr=cell(1,num_mua_set);
    for mua_set_i=1:num_mua_set
        if mua_set_i*max_mua_sameTime<size(temp_mua_param_arr,2)
            this_temp_mua_set=temp_mua_param_arr(:,(mua_set_i-1)*max_mua_sameTime+1:mua_set_i*max_mua_sameTime);
        else
            this_temp_mua_set=temp_mua_param_arr(:,(mua_set_i-1)*max_mua_sameTime+1:end);
        end
        in_array_mua_param_arr{mua_set_i}=reshape(this_temp_mua_set,1,5,size(this_temp_mua_set,2));
    end
    lkt_ref_value_arr=zeros(size(lkt_mus_table,1),size(mua_param_arr,1),lkt_sim_set.num_SDS); % the the lookup table reflectance value
    
    num_SDS=lkt_sim_set.num_SDS;
    
    lkt_process_timer=tic;
    
    for lkt_index=1:size(lkt_mus_table,1)
        fprintf('Processing lookup mus set %d/%d, SDS: ',lkt_index,size(lkt_mus_table,1));
        temp_PL=load(fullfile(lkt_dir,['sim_' num2str(lkt_index)],'PL_1.mat'));
        for s=1:num_SDS
            fprintf(' %d',s);
            temp_lkt_ref_value=zeros(size(mua_param_arr,1),1);
            for mua_set_i=1:num_mua_set
                temp_detpt_weight=squeeze(exp(-1*sum(temp_PL.SDS_detpt_arr{s}(:,1:5).*in_array_mua_param_arr{mua_set_i},2))); % the weight of each photon, not normalized yet
                % temp_PL_arr=reshape(temp_detpt_weight,size(temp_detpt_weight,1),1,size(temp_detpt_weight,2)).*temp_PL.SDS_detpt_arr{s}(:,1:5); % the multiply of each photon's weight and the PL in each layer
                % temp_PL_arr=transpose(squeeze(sum(temp_PL_arr,1))./sum(temp_detpt_weight,1)); % the average PL
                temp_detpt_weight=transpose(sum(temp_detpt_weight,1)/temp_PL.each_photon_weight_arr(s));
                temp_lkt_ref_value(max_mua_sameTime*(mua_set_i-1)+1:max_mua_sameTime*(mua_set_i-1)+length(temp_detpt_weight),1)=temp_detpt_weight; % the reflectance of high NA detector
            end
%             lkt_detpt=size(temp_PL.SDS_detpt_arr{s},1)/temp_PL.each_photon_weight_arr(s); % the number of detected photons
            % temp_param=[log10(temp_lkt_ref_value) log10(ones(size(temp_lkt_ref_value)).*lkt_detpt) ones(size(temp_lkt_ref_value,1),1).*lkt_mus_table(lkt_index,1:3) mua_param_arr(:,1:4) temp_PL_arr];
%             temp_param=[log10(temp_lkt_ref_value) log10(ones(size(temp_lkt_ref_value)).*lkt_detpt) ones(size(temp_lkt_ref_value,1),1).*lkt_mus_table(lkt_index,1:2) mua_param_arr(:,1:2)];
%             temp_ratio=predict(regression_model{s},temp_param); % use the regression model to find the reflectance ratio
%             temp_lkt_ref_value=temp_lkt_ref_value;
            lkt_ref_value_arr(lkt_index,:,s)=temp_lkt_ref_value;
        end
        fprintf('\n');
    end
    
    lkt_process_timer=toc(lkt_process_timer);
    save(fullfile(output_dir,'lit_process_time.txt'),'lkt_process_timer','-ascii','-tabs');

    %% interpolate the lookup table
    if test_mode==0
        all_param_arr=zeros(size(mua_param_arr,1)*size(mus_param_arr,1),2*num_layer+lkt_sim_set.num_SDS);
    elseif test_mode>=1
        all_param_arr=zeros(size(mua_param_arr,1),2*num_layer+lkt_sim_set.num_SDS);
    end

    for mua_i=1:size(mua_param_arr,1)
        fprintf('Calculating mua set %d/%d, SDS ',mua_i,size(mua_param_arr,1));
        for s=1:lkt_sim_set.num_SDS
            fprintf('%d ',s);
            lkt_value=lkt_ref_value_arr(:,mua_i,s);
            lkt_points_ref=lkt_value(in_place_arr);
            if test_mode==0
                all_param_arr((mua_i-1)*size(mus_param_arr,1)+1:mua_i*size(mus_param_arr,1),2*num_layer+s)=interpn(lkt_layer_mus{1},lkt_layer_mus{2},lkt_layer_mus{3},lkt_layer_mus{4},lkt_points_ref,mus_param_arr(:,1),mus_param_arr(:,2),mus_param_arr(:,3),mus_param_arr(:,4),'spline');
                all_param_arr((mua_i-1)*size(mus_param_arr,1)+1:mua_i*size(mus_param_arr,1),1:num_layer)=ones(size(mus_param_arr,1),1).*mua_param_arr(mua_i,:);
                all_param_arr((mua_i-1)*size(mus_param_arr,1)+1:mua_i*size(mus_param_arr,1),num_layer+1:2*num_layer)=mus_param_arr;
            elseif test_mode>=1
                all_param_arr(mua_i,2*num_layer+s)=interpn(lkt_layer_mus{1},lkt_layer_mus{2},lkt_layer_mus{3},lkt_layer_mus{4},lkt_points_ref,mus_param_arr(mua_i,1),mus_param_arr(mua_i,2),mus_param_arr(mua_i,3),mus_param_arr(mua_i,4),'spline');
                all_param_arr(mua_i,1:2*num_layer)=[mua_param_arr(mua_i,1:num_layer) mus_param_arr(mua_i,1:num_layer)];
            end
        end
        fprintf('\n');
    end
    all_param_arr(:,2*num_layer+1:end)=all_param_arr(:,2*num_layer+1:end).*(setting_r./lkt_sim_set.detector_r').^2;
    save(fullfile(output_dir,'all_param_arr.mat'),'all_param_arr','-v7.3');

    if test_mode>=1
        to_save=all_param_arr(:,9:end);
        save(fullfile(output_dir,'lkt_smooth_forward.txt'),'to_save','-ascii','-tabs');
    end
end

disp('Done!');