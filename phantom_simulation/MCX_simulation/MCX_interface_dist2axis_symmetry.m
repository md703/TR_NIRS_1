% simulate the phantom spectrum using MCX
% for a curve phantom
% using a larger detector to detect photon, and calculate the distance
% betweeen the photon and the axis of detector

clc;clear;close all;

%% param
% about instrument
num_true_SDS=6;
num_SDS=18;
detector_r=2; %mm
detector_larger_r=4; %mm, use the larger detector to find the detected photon, and calculate the distance of photon to the center of detector
SDS_x_arr=[1.5 1.5 3 3 4.5 4.5]; % the SDS x displacement (cm)
SDS_z_arr=[0 1.5 0 1.5 0 1.5]; % the SDS z displacement (cm)
detector_NA=0.12;

% about phantom
num_phantom=6;
phantom_thickness=45; %mm
phantom_d=133; %mm
g=0;
n=1.4;
outer_n=1.4;

% about sumulation
sim_wl=650:10:900;
output_folder='MCX_sim_1E10_r2nmm_symmetric_startfrom0_dist2axis_fixNA';
% num_photon=10000000000;
% photon_per_simulation=500000000; % howmany photon to run each time, so not cost too much memory simultaneously
num_photon=50000000;
photon_per_simulation=50000000; % howmany photon to run each time, so not cost too much memory simultaneously

% save_mode='txt';
save_mode='mat';


%% init

SDS_x_arr=SDS_x_arr*10;
SDS_z_arr=SDS_z_arr*10;

SDS_displacement_x=[]; % the location change along x axis of detector from source
SDS_displacement_y=[];
SDS_displacement_z=SDS_z_arr;

SDS_normal_vector=[]; % the normal vectors for the detector
SDS_multiply=zeros(1,num_true_SDS); % because using symmetric to add more probe, the reflectance should be divided by the number
add_mcx_sds_counter=1;
for s=1:num_true_SDS
    alpha=SDS_x_arr(s)/(2*pi*phantom_d/2)*2*pi; % the angle of detector and source
    SDS_displacement_x(s)=phantom_d/2*(1-cos(alpha));
    SDS_displacement_y(s)=phantom_d/2*sin(alpha);
    SDS_normal_vector(add_mcx_sds_counter,:)=[-cos(alpha) sin(alpha) 0];
    SDS_multiply(s)=SDS_multiply(s)+1;
    add_mcx_sds_counter=add_mcx_sds_counter+1;
    SDS_normal_vector(add_mcx_sds_counter,:)=[-cos(alpha) -sin(alpha) 0];
    SDS_multiply(s)=SDS_multiply(s)+1;
    add_mcx_sds_counter=add_mcx_sds_counter+1;
end
% add for z!=0 SDS
for s=1:num_true_SDS
    if SDS_displacement_z(s)~=0
        alpha=SDS_x_arr(s)/(2*pi*phantom_d/2)*2*pi; % the angle of detector and source
        SDS_normal_vector(add_mcx_sds_counter,:)=[-cos(alpha) sin(alpha) 0];
        SDS_multiply(s)=SDS_multiply(s)+1;
        add_mcx_sds_counter=add_mcx_sds_counter+1;
        SDS_normal_vector(add_mcx_sds_counter,:)=[-cos(alpha) -sin(alpha) 0];
        SDS_multiply(s)=SDS_multiply(s)+1;
        add_mcx_sds_counter=add_mcx_sds_counter+1;
    end
end

%% ckeck
assert(length(SDS_x_arr)==length(SDS_z_arr),'SDS information ERROR!');
assert(length(SDS_x_arr)==num_true_SDS,'SDS information ERROR!');

%%
mua_arr=load('mua_cm.txt');
musp_arr=load('musp_cm.txt');
assert(size(mua_arr,2)==size(musp_arr,2),'mua or mus file ERROR!');
assert(size(mua_arr,2)==num_phantom+1,'mua or mus file ERROR!');

mua_arr(:,2:end)=mua_arr(:,2:end)./10; % turn 1/cm into 1/mm
musp_arr(:,2:end)=musp_arr(:,2:end)./10;

mus_arr=musp_arr;
mus_arr(:,2:end)=mus_arr(:,2:end)./(1-g);

wl_range(1)=max(min(mua_arr(:,1)),min(mus_arr(:,1)));
wl_range(2)=min(max(mua_arr(:,1)),max(mus_arr(:,1)));
assert(wl_range(1)<=min(sim_wl),'wl range ERROR!');
assert(wl_range(2)>=max(sim_wl),'wl range ERROR!');

mua_arr=interp1(mua_arr(:,1),mua_arr(:,:),sim_wl);
mus_arr=interp1(mus_arr(:,1),mus_arr(:,:),sim_wl);

%% 
mkdir(output_folder);

reflectance_arr=cell(1,num_phantom);

for i=[5]
    ph_folder=fullfile(output_folder,['phantom_' num2str(i)]);
    mkdir(ph_folder);
    for wl=1:length(sim_wl)
%     for wl=7:length(sim_wl)
        %% start timer
        timer_sim=tic;

        %% param
        grid_pixel=1; % how many grid in 1 mm
        x_axis=phantom_d; % how many mm of x (and y) axis to simulate
        z_axis=phantom_thickness; % how many mm of z axis to simulate

        sim_summary.each_photon_weight=num_photon; % howmany weight the photon should be divided while post process
        photon_per_simulation=500000000; % howmany photon to run each time, so not cost too much memory simultaneously
%         photon_per_simulation=50000000; % howmany photon to run each time, so not cost too much memory simultaneously
        num_need_to_run=ceil(num_photon/photon_per_simulation); % how many times should run
        cfg.nphoton=photon_per_simulation;                     % define total simulated photon number

        %% source
        cfg.srcpos=[0 x_axis/2*grid_pixel z_axis/2*grid_pixel];                % source position in voxel unit (may be different from mm)
        cfg.srcdir=[1 0 0];                  % unitary vector defining the initial incident direction of photons

        %% setting each layer
        cfg.vol=uint8(zeros(x_axis*grid_pixel,x_axis*grid_pixel,z_axis*grid_pixel));       % define the volume
%         cfg.vol(1,:,:)=0;
        for x=1:x_axis*grid_pixel
            for y=1:x_axis*grid_pixel
                if sqrt((x-x_axis/2*grid_pixel)^2+(y-x_axis/2*grid_pixel)^2)<=x_axis/2*grid_pixel
                    cfg.vol(x,y,:)=1;
                end
            end
        end
        % define optical properties [mua (1/mm),mus (1/mm), g and n] for each tissue type; first one reserved for background/air, i.e. label 0
        cfg.prop=[0 0 1 outer_n;
            mua_arr(wl,i+1) mus_arr(wl,i+1) g n];

        %% each row specifying a detector: [x,y,z,radius]
        cfg.detpos=[];
        detector_mapping_arr=cell(1,num_true_SDS);
        add_mcx_sds_counter=1;
        for s=1:num_true_SDS
            cfg.detpos=[cfg.detpos; cfg.srcpos(1)+SDS_displacement_x(s)*grid_pixel cfg.srcpos(2)+SDS_displacement_y(s)*grid_pixel cfg.srcpos(3)+SDS_displacement_z(s)*grid_pixel detector_larger_r*grid_pixel;
                                    cfg.srcpos(1)+SDS_displacement_x(s)*grid_pixel cfg.srcpos(2)-SDS_displacement_y(s)*grid_pixel cfg.srcpos(3)+SDS_displacement_z(s)*grid_pixel detector_larger_r*grid_pixel];
%             cfg.detpos=[cfg.detpos; cfg.srcpos(1)+SDS_displacement_x(s)*grid_pixel cfg.srcpos(2)+SDS_displacement_y(s)*grid_pixel cfg.srcpos(3)+SDS_displacement_z(s)*grid_pixel detector_r*grid_pixel;
%                                     cfg.srcpos(1)+SDS_displacement_x(s)*grid_pixel cfg.srcpos(2)-SDS_displacement_y(s)*grid_pixel cfg.srcpos(3)+SDS_displacement_z(s)*grid_pixel detector_r*grid_pixel];
            detector_mapping_arr{s}(end+1)=add_mcx_sds_counter;
            add_mcx_sds_counter=add_mcx_sds_counter+1;
            detector_mapping_arr{s}(end+1)=add_mcx_sds_counter;
            add_mcx_sds_counter=add_mcx_sds_counter+1;
        end
        for s=1:num_true_SDS
            if SDS_displacement_z(s)~=0
                cfg.detpos=[cfg.detpos; cfg.srcpos(1)+SDS_displacement_x(s)*grid_pixel cfg.srcpos(2)+SDS_displacement_y(s)*grid_pixel cfg.srcpos(3)-SDS_displacement_z(s)*grid_pixel detector_larger_r*grid_pixel;
                                        cfg.srcpos(1)+SDS_displacement_x(s)*grid_pixel cfg.srcpos(2)-SDS_displacement_y(s)*grid_pixel cfg.srcpos(3)-SDS_displacement_z(s)*grid_pixel detector_larger_r*grid_pixel];
%                 cfg.detpos=[cfg.detpos; cfg.srcpos(1)+SDS_displacement_x(s)*grid_pixel cfg.srcpos(2)+SDS_displacement_y(s)*grid_pixel cfg.srcpos(3)-SDS_displacement_z(s)*grid_pixel detector_r*grid_pixel;
%                                         cfg.srcpos(1)+SDS_displacement_x(s)*grid_pixel cfg.srcpos(2)-SDS_displacement_y(s)*grid_pixel cfg.srcpos(3)-SDS_displacement_z(s)*grid_pixel detector_r*grid_pixel];
                detector_mapping_arr{s}(end+1)=add_mcx_sds_counter;
                add_mcx_sds_counter=add_mcx_sds_counter+1;
                detector_mapping_arr{s}(end+1)=add_mcx_sds_counter;
                add_mcx_sds_counter=add_mcx_sds_counter+1;
            end
        end
        
        % make a reference point on the axis of detector
        reference_point_arr=zeros(size(cfg.detpos,1),3);
        for s=1:size(cfg.detpos,1)
            reference_point_arr(s,:)=cfg.detpos(s,1:3)-SDS_normal_vector(s,:).*detector_larger_r;
        end

        %% other setting
        cfg.tstart=0;                        % start of the simulation time window (in second)
        cfg.tend=5e-9;                       % end of the simulation time window (in second)
        cfg.tstep=5e-9;                     % time gate width (in second), here we asks mcxlab to a "videos" at 50 time gates
        cfg.isnormalized=1; % normalize the output fluence to unitary source
        cfg.isspecular=1; % calculate specular reflection if source is outside
        cfg.unitinmm=1.0/grid_pixel; % the length unit for a grid edge length
        cfg.srctype='pencil'; % source type

        % cfg.savedetflag='dspxvw';
        cfg.savedetflag='dpxv';
        % 1 d  output detector ID (1)
        % 2 s  output partial scat. even counts (#media)
        % 4 p  output partial path-lengths (#media)
        % 8 m  output momentum transfer (#media)
        % 16 x  output exit position (3)
        % 32 v  output exit direction (3)
        % 64 w  output initial weight (1)
        cfg.outputtype='flux'; % fluence integrated over each time gate
        %cfg.maxdetphoton=photon_per_simulation; % maximum number of photons saved by the detectors
        cfg.maxdetphoton=15000000; % maximum number of photons saved by the detectors
        cfg.gpuid=1; % cfg.gpuid='11';       % =1 use the first GPU, =2, use the 2nd, ='11' use both GPUs together
        cfg.autopilot=1;                     % let mcxlab to automatically decide the threads/blocks
        cfg.issrcfrom0=1; % first voxel is [0 0 0]
        cfg.issaveexit=1; % save the exiting photons
        cfg.isreflect=0; % consider index mismatch reflect

        %% init
        rng('shuffle');

        % store the detected photon from each detector
        seed_arr=cell(1,num_true_SDS);
        detpt_arr=cell(1,num_true_SDS);
        for d=1:num_true_SDS
            detpt_arr{d}.data=[];
        end

        %% run first time to get the random seed for detected photon
        run_index=0;
        while run_index<num_need_to_run
            cfg.seed=randi([1,1000000]);
            [~,detpt,~,seeds]=mcxlab(cfg);
            timer_process=tic;
            for s=1:num_true_SDS
                for d=detector_mapping_arr{s}
                    SDS_detect_index=find(detpt.detid==d);
                    %% find the photon in the true detector r
                    dist2reference_square=sum((detpt.p(SDS_detect_index,:)-reference_point_arr(d,:)).^2,2); % the distance of Photon and Reference
                    dot_RP_RD=sum((detpt.p(SDS_detect_index,:)-reference_point_arr(d,:)).*SDS_normal_vector(d,:),2); % the cosine value of RP X RD (D for Detector). RD is equal to the normal vetector * dist(RD)
                    % because the length of normal vector is 1, so the dot value is equal to the RP * cos(theta)
                    dist2axis_square=dist2reference_square-dot_RP_RD.^2;
                    in_dist_detpt=find(dist2axis_square<=detector_r^2);
                    SDS_detect_index=SDS_detect_index(in_dist_detpt);
             %% find the photon in the NA       
                    det_vector=detpt.v(SDS_detect_index,:);
                    dot_value=sum(SDS_normal_vector(d,:).*det_vector,2);
                    dot_value(dot_value>1)=1;
                    det_angle=acos(dot_value);
                    in_NA_index=SDS_detect_index(dot_value>0 & sin(det_angle)<=(detector_NA/outer_n));
                    seed_arr{s}=[seed_arr{s} seeds.data(:,in_NA_index)];
                    detpt_arr{s}.data=[detpt_arr{s}.data detpt.data(:,in_NA_index)];
                end
            end
            timer_process=toc(timer_process);
            clear detpt seeds;
            run_index=run_index+1;
        end

        %% stop timer and start replay timer
        sim_summary.sim_time=toc(timer_sim);
        timer_replay=tic;

        %% init 
        jacobian_arr=cell(1,num_true_SDS);
        SDS_detpt_arr=cell(1,num_true_SDS);
        sim_summary.SDS_detected_number=[];

        %% replay
        for d=1:num_true_SDS
            if size(seed_arr{d},2)>0
                newcfg=cfg;
                newcfg.seed=seed_arr{d};
                newcfg.outputtype='jacobian';
                newcfg.detphotons=detpt_arr{d}.data;
                [new_fluencerate,new_detpt,~,~]=mcxlab(newcfg);
                jacobian_arr{d}=new_fluencerate.data;

                sim_summary.SDS_detected_number=[sim_summary.SDS_detected_number size(seed_arr{d},2)];

                SDS_detpt_arr{d}=[new_detpt.ppath./grid_pixel./10]; % turn mm into cm
            else
                sim_summary.SDS_detected_number=[sim_summary.SDS_detected_number size(seed_arr{d},2)];
                jacobian_arr{d}=0;
                SDS_detpt_arr{d}=[];
            end

            %% save output file
            if strcmp(save_mode,'txt')
                to_save=double(SDS_detpt_arr{d});
                save(fullfile(ph_folder,['PL_' num2str(wl) '_SDS_' num2str(d) '.txt']),'to_save','-ascii','-tabs');
                
                to_save=double(reshape(jacobian_arr{d},size(jacobian_arr{d},1),[]));
                save(fullfile(ph_folder,['jacobian_' num2str(wl) '_SDS_' num2str(d) '.txt']),'to_save','-ascii','-tabs');
            end
        end
        %% save output file
        if strcmp(save_mode,'mat')
            save(fullfile(ph_folder,['PL_' num2str(wl) '.mat']),'SDS_detpt_arr');
            save(fullfile(ph_folder,['jacobian_' num2str(wl) '.mat']),'jacobian_arr');
        end

        %% calculate reflectance
        sim_summary.replay_time=toc(timer_replay);
        for s=1:num_true_SDS
            reflectance_arr{i}(wl,s)=1/num_photon*sum(exp(-double(SDS_detpt_arr{s}).*mua_arr(wl,i+1).*10)); % change the mua back to 1/cm from 1/mm
        end
        reflectance_arr{i}(wl,:)=reflectance_arr{i}(wl,:)./SDS_multiply; % divide by the number of copy SDS to get the true reflectance
        to_save=reflectance_arr{i};
        save(fullfile(ph_folder,'reflectance.txt'),'to_save','-ascii','-tabs');
        
        %% save sim summary
        fid=fopen(fullfile(ph_folder,['sim_summary_' num2str(wl) '.json']),'w');
        fprintf(fid,jsonencode(sim_summary));
        fclose(fid);
    end
end

disp('Done!');
