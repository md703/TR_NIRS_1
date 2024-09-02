%{
Test the best degree of polynominal function that fits simulation data the
most.

Ting-Yi Kuo
Last update: 2023/09/04
%}

clc;clear;close all;

%% param
lookup_table_arr='../1_1_MCX_lookup_table'; % the dir containing the unmerged lookup table
subject_name_arr={'CT'}; % the name of the subjects


num_layer=4; % number of layer to random
setting_r=0.2; % the radius of true detector, in mm

% about parameters
mua_ub=[0.5 0.35 0.042 0.5]; % 1/cm
mua_lb=[0.1 0.05 0.042 0.05]; % 1/cm

mus_ub=[250 225 23 275]; % 1/cm
mus_lb=[75 25 23 25]; % 1/cm

mua_param_arr=mua_ub;

num_SDS=5;
num_gate=10;
num_total=num_SDS*num_gate;

max_mua_sameTime=10; % how many mua set to calculate at the same time, use smaller value for smaller memory consumption
linewidth=1.25;
fontSize=24;
markersize=28;

for sbj_i=1:length(subject_name_arr)
    
    subject_name=subject_name_arr{sbj_i};

    %% init
    lkt_dir=fullfile(lookup_table_arr,subject_name); % the dir containing the unmerged lookup table
    output_dir=fullfile('Test',subject_name);
    mkdir(output_dir);

    % load lookup table information
    lkt_sim_set=load(fullfile(lkt_dir,'sim_set.mat'));
    lkt_sim_set=lkt_sim_set.sim_set;
    lkt_layer_mus=load(fullfile(lkt_dir,'layer_mus.mat'));
    lkt_layer_mus=lkt_layer_mus.layer_mus;
    lkt_mus_table=load(fullfile(lkt_dir,'mus_table.txt'));

    % save the bound
    param_ub=[mua_ub mus_ub];
    param_lb=[mua_lb mus_lb];
    to_save=[param_ub; param_lb];

%     mua_param_arr=[0.6 0.45 0.1 0.5 0.25];

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
    lkt_ref_value_arr=zeros(size(lkt_mus_table,1),size(mua_param_arr,1),num_total); % the lookup table reflectance value

    if exist(fullfile(output_dir,'lkt_ref_value_arr.mat'),'file')
        lkt_ref_value_arr=load(fullfile(output_dir,'lkt_ref_value_arr.mat'));
        lkt_ref_value_arr=lkt_ref_value_arr.lkt_ref_value_arr;
    else
        for lkt_index=1:size(lkt_mus_table,1)
            fprintf('Processing lookup mus set %d/%d',lkt_index,size(lkt_mus_table,1)); %, Gate: 
            temp_PL=load(fullfile(lkt_dir,['sim_' num2str(lkt_index)],'PL_1.mat'));
            for s=1:num_SDS
                SDS_detpt_arr_2(num_gate*(s-1)+1:num_gate*s)=temp_PL.SDS_detpt_arr(:,s)';
            end

            for s=1:num_total
%                 fprintf(' %d',s);
                temp_lkt_ref_value=zeros(size(mua_param_arr,1),1);
                for mua_set_i=1:num_mua_set
                    temp_detpt_weight=squeeze(exp(-1*sum(SDS_detpt_arr_2{s}(:,1:5).*in_array_mua_param_arr{mua_set_i},2))); % the weight of each photon, not normalized yet
                    if size(SDS_detpt_arr_2{s},1)==1
                        temp_detpt_weight=transpose(temp_detpt_weight/temp_PL.each_photon_weight_arr(ceil(s/num_gate)));
                    else
                        temp_detpt_weight=transpose(sum(temp_detpt_weight,1)/temp_PL.each_photon_weight_arr(ceil(s/num_gate)));
                    end
                    temp_lkt_ref_value(max_mua_sameTime*(mua_set_i-1)+1:max_mua_sameTime*(mua_set_i-1)+length(temp_detpt_weight),1)=temp_detpt_weight; % the reflectance of high NA detector
                end

                lkt_ref_value_arr(lkt_index,:,s)=temp_lkt_ref_value;
            end
            fprintf('\n');
        end
        save(fullfile(output_dir,'lkt_ref_value_arr.mat'),'lkt_ref_value_arr');
    end
    
   
    %% test
    close all;
    % Define smoothing parameters
    num_iterations=1;  % Adjust as needed
    mus_array={'\mu_{s,scalp}','\mu_{s,skull}','\mu_{s,CSF}','\mu_{s,GM}'};
    mua_array={'\mu_{a,scalp}','\mu_{a,skull}','\mu_{a,CSF}','\mu_{a,GM}'};
    tissue_arr={'scalp','skull','CSF','GM'};
    SDS_array=[1.5 2.2 2.9 3.6 4.3];
    subplot_arr=[1 4 2 5 3 6];
    
    hs_or_ls=0;
    
    % load true answer
    dtof_arrange=[];
    mus_table = load(fullfile(subject_name,'mus_table.txt'));
    for sim = 1:size(mus_table,1)
        dtof=load(fullfile(subject_name,['DTOF_' num2str(sim) '.mat']));
        dtof_arrange(end+1,:)=dtof.to_save;
    end
    
    if hs_or_ls==0
        dtof_arrange_gm=dtof_arrange(12:22,:);
    elseif hs_or_ls==1
        dtof_arrange_gm=dtof_arrange(1:11,:);
    end
    
    linewidth=1.25;
    
    %% For changing mus, fixed mua 
    close all;
    lkt_points_ref_arrange=[];
    lkt_points_ref_smooth=[];
    lkt_points_ref_smooth_1=[];
    lkt_points_ref_smooth_2=[];
    lkt_points_ref_smooth_3=[];
    mean_RMSE=zeros(5,num_SDS+1);
    
    % for polyfitn
    [x, y, z] = meshgrid(mus_lb(2):25:mus_ub(2),mus_lb(1):25:mus_ub(1), mus_lb(4):25:mus_ub(4));
    x=x(:);
    y=y(:);
    z=z(:);
    
    fig=figure(1); fig.Units='pixels'; fig.Position=[0 0 1920 1080];
    ti=tiledlayout('flow','Padding','none');
    set(fig,'visible','off');
    sub_num=1;
    for mua_i=size(mua_param_arr,1) % choose which mua to fix
        for s=1:num_total
            now_SDS=ceil(s/num_gate);
            lkt_value=lkt_ref_value_arr(:,mua_i,s);
            lkt_points_ref=lkt_value(in_place_arr);
            lkt_points_ref_arrange(end+1,:,:,:,:)=lkt_points_ref;

            % smooth method ('polyfitn' function)
            
            temp_lkt_points_ref=squeeze(lkt_points_ref);
           
            [m, n, p]=size(temp_lkt_points_ref);
            temp_data_1d=(reshape(temp_lkt_points_ref, [], 1));
            data_1d=-log10(temp_data_1d);
            data_1d(data_1d==inf)=NaN;
            
%             if sum(isnan(data_1d))>=length(data_1d)-396   %sum(isnan(data_1d))>=length(data_1d)-80
%                 fitted_values=temp_data_1d;
%                 fitted_surface=reshape(fitted_values, [m, n, p]);
%                 smoothed_data(:,:,1,:)=fitted_surface;
%                 smoothed_data_1(:,:,1,:)=fitted_surface;
%                 smoothed_data_2(:,:,1,:)=fitted_surface;
%                 smoothed_data_3(:,:,1,:)=fitted_surface;
%             else
                degree=2;
                coefficients=polyfitn([x, y, z], data_1d, degree);
                fitted_values=polyvaln(coefficients, [x, y, z]);
                fitted_values=power(10,-fitted_values);

                fitted_surface=reshape(fitted_values, [m, n, p]);
                smoothed_data(:,:,1,:)=fitted_surface;

                degree=4;
                coefficients=polyfitn([x, y, z], data_1d, degree);
                fitted_values=polyvaln(coefficients, [x, y, z]);
                fitted_values=power(10,-fitted_values);

                fitted_surface=reshape(fitted_values, [m, n, p]);
                smoothed_data_1(:,:,1,:)=fitted_surface;

                degree=6;
                coefficients=polyfitn([x, y, z], data_1d, degree);
                fitted_values=polyvaln(coefficients, [x, y, z]);
                fitted_values=power(10,-fitted_values);

                fitted_surface=reshape(fitted_values, [m, n, p]);
                smoothed_data_2(:,:,1,:)=fitted_surface;

                degree=8;
                coefficients=polyfitn([x, y, z], data_1d, degree);
                fitted_values=polyvaln(coefficients, [x, y, z]);
                fitted_values=power(10,-fitted_values);

                fitted_surface=reshape(fitted_values, [m, n, p]);
                smoothed_data_3(:,:,1,:)=fitted_surface;
%             end
            
            
%             % Plot as heatmap before and after smooth
%             figure('Units','pixels','position',[0 0 1920 1080]);
%             subplot(2,3,1);
%             cm = [1 0 0;1 1 1; 0 0 1];
%             cmi = interp1([-100; 0; 100], cm, (-100:100));
% %             h=heatmap(log10(squeeze(lkt_points_ref(:,:,1,1))),'XData',mus_lb(2):25:mus_ub(2),'YData',mus_lb(1):25:mus_ub(1),'Colormap',cmi ,'CellLabelColor','none','GridVisible','off');
%             h=heatmap(log10(squeeze(lkt_points_ref(:,:,1,1))),'XData',mus_lb(2):25:mus_ub(2),'YData',mus_lb(1):25:mus_ub(1) ,'CellLabelColor','none','GridVisible','off');
%             h.NodeChildren(3).YDir='normal';
%             xlabel('scalp');
%             ylabel('skull');
%             title('Reflectance');
%             
%             subplot(2,3,2);
%             h=heatmap(log10(squeeze(lkt_points_ref(:,1,1,:))),'XData',mus_lb(4):25:mus_ub(4),'YData',mus_lb(1):25:mus_ub(1),'CellLabelColor','none','GridVisible','off');
%             h.NodeChildren(3).YDir='normal';
%             xlabel('GM');
%             ylabel('scalp');
%             title('Reflectance');
%             
%             subplot(2,3,3);
%             h=heatmap(log10(squeeze(lkt_points_ref(1,:,1,:))),'XData',mus_lb(4):25:mus_ub(4),'YData',mus_lb(2):25:mus_ub(2),'CellLabelColor','none','GridVisible','off');
%             h.NodeChildren(3).YDir='normal';
%             xlabel('GM');
%             ylabel('skull');
%             title('Reflectance');
%             
%             subplot(2,3,4);
%             h=heatmap(log10(squeeze(smoothed_data_1(:,:,1,1))),'XData',mus_lb(2):25:mus_ub(2),'YData',mus_lb(1):25:mus_ub(1) ,'CellLabelColor','none','GridVisible','off');
%             h.NodeChildren(3).YDir='normal';
%             xlabel('scalp');
%             ylabel('skull');
%             title('Reflectance');
%             
%             subplot(2,3,5);
%             h=heatmap(log10(squeeze(smoothed_data_1(:,1,1,:))),'XData',mus_lb(4):25:mus_ub(4),'YData',mus_lb(1):25:mus_ub(1),'CellLabelColor','none','GridVisible','off');
%             h.NodeChildren(3).YDir='normal';
%             xlabel('GM');
%             ylabel('scalp');
%             title('Reflectance');
%             
%             subplot(2,3,6);
%             h=heatmap(log10(squeeze(smoothed_data_1(1,:,1,:))),'XData',mus_lb(4):25:mus_ub(4),'YData',mus_lb(2):25:mus_ub(2),'CellLabelColor','none','GridVisible','off');
%             h.NodeChildren(3).YDir='normal';
%             xlabel('GM');
%             ylabel('skull');
%             title('Reflectance');
%             
%             sgtitle(['SDS ' num2str(SDS_array(now_SDS)) ' cm, Gate ' num2str(s-num_gate*(now_SDS-1))]);
%             if ~exist(fullfile('results','gif'),'file')
%                 mkdir(fullfile('results','gif'));
%             end
%             print(fullfile('results','gif',['compare_SDS' num2str(SDS_array(now_SDS)) 'cm_Gate ' num2str(s-num_gate*(now_SDS-1)) '.png']),'-dpng','-r200');
%             
%             % Plot without original
%             fig=figure('Units','pixels','position',[0 0 1920 540]);
%             set(fig,'visible','off');
%             subplot(1,3,1);
%             h=heatmap(log10(squeeze(smoothed_data_1(:,:,1,1))),'XData',mus_lb(2):25:mus_ub(2),'YData',mus_lb(1):25:mus_ub(1) ,'CellLabelColor','none','GridVisible','off');
%             h.NodeChildren(3).YDir='normal';
%             xlabel('scalp');
%             ylabel('skull');
%             title('Reflectance');
%             
%             subplot(1,3,2);
%             h=heatmap(log10(squeeze(smoothed_data_1(:,1,1,:))),'XData',mus_lb(4):25:mus_ub(4),'YData',mus_lb(1):25:mus_ub(1),'CellLabelColor','none','GridVisible','off');
%             h.NodeChildren(3).YDir='normal';
%             xlabel('GM');
%             ylabel('scalp');
%             title('Reflectance');
%             
%             subplot(1,3,3);
%             h=heatmap(log10(squeeze(smoothed_data_1(1,:,1,:))),'XData',mus_lb(4):25:mus_ub(4),'YData',mus_lb(2):25:mus_ub(2),'CellLabelColor','none','GridVisible','off');
%             h.NodeChildren(3).YDir='normal';
%             xlabel('GM');
%             ylabel('skull');
%             title('Reflectance');
%             
%             sgtitle(['SDS ' num2str(SDS_array(now_SDS)) ' cm, Gate ' num2str(s-num_gate*(now_SDS-1))]);
%             
%             print(fullfile('results','gif',['SDS' num2str(SDS_array(now_SDS)) 'cm_Gate ' num2str(s-num_gate*(now_SDS-1)) '.png']),'-dpng','-r200');



%             % Plot as 3d for different SDS and gate
%             f=figure('Units','pixels','position',[0 0 1920 540]);
%             set(f,'visible','off');
%             t=tiledlayout(1,3);
%             nexttile;
%             [X,Y] = meshgrid(mus_lb(1):25:mus_ub(1),mus_lb(2):25:mus_ub(2));
%             surf(X,Y,squeeze(smoothed_data_1(:,:,1,2))','EdgeColor','None');
%             xlabel('scalp');
%             ylabel('skull');
%             zlabel('Reflectance');
%             
%             nexttile;
%             [X,Y] = meshgrid(mus_lb(1):25:mus_ub(1),mus_lb(4):25:mus_ub(4));
%             surf(X,Y,squeeze(smoothed_data_1(:,2,1,:))','EdgeColor','None');
%             xlabel('scalp');
%             ylabel('gray matter');
%             zlabel('Reflectance');
%             
%             nexttile;
%             [X,Y] = meshgrid(mus_lb(2):25:mus_ub(2),mus_lb(4):25:mus_ub(4));
%             surf(X,Y,squeeze(smoothed_data_1(2,:,1,:))','EdgeColor','None');
%             xlabel('skull');
%             ylabel('gray matter');
%             zlabel('Reflectance');
%             
%             title(t,['SDS ' num2str(SDS_array(now_SDS)) ' cm, Gate ' num2str(s-num_gate*(now_SDS-1))]);
%             print(fullfile('results',['SDS' num2str(SDS_array(now_SDS)) 'cm_Gate ' num2str(s-num_gate*(now_SDS-1)) '.png']),'-dpng','-r200');
            
            
%             % Plot as 3d for specific SDS and gate (please choose one 's' to plot, or you will get many figures for each 's')
%             % before smoothing
%             [X,Y] = meshgrid(mus_lb(1):25:mus_ub(1),mus_lb(2):25:mus_ub(2));
%             zmax=max(lkt_points_ref(:));
%             zmin=min(lkt_points_ref(:));
%             for i=1:size(lkt_points_ref,4)
%                 f=figure('Units','pixels','position',[0 0 640 540]);
%                 surf(X,Y,squeeze(lkt_points_ref(:,:,1,i))','EdgeColor','None');
%                 title(['GM = ' num2str(mus_lb(4)+25*(i-1)) ' cm^{-1}']);
%                 xlabel('scalp');
%                 ylabel('skull');
%                 zlabel('Reflectance');
%                 zlim([zmin zmax]);
%                 print(fullfile('results',['b_fixed_GM_' num2str(i) '_SDS' num2str(SDS_array(now_SDS)) 'cm_Gate ' num2str(s-num_gate*(now_SDS-1)) '.png']),'-dpng','-r200');
%             end
%             
%             [X,Y] = meshgrid(mus_lb(1):25:mus_ub(1),mus_lb(4):25:mus_ub(4));
%             for i=1:size(lkt_points_ref,2)
%                 f=figure('Units','pixels','position',[0 0 640 540]);
%                 surf(X,Y,squeeze(lkt_points_ref(:,i,1,:))','EdgeColor','None');
%                 title(['skull = ' num2str(mus_lb(2)+25*(i-1)) ' cm^{-1}']);
%                 xlabel('scalp');
%                 ylabel('gray matter');
%                 zlabel('Reflectance');
%                 zlim([zmin zmax]);
%                 print(fullfile('results',['b_fixed_skull_' num2str(i) '_SDS' num2str(SDS_array(now_SDS)) 'cm_Gate ' num2str(s-num_gate*(now_SDS-1)) '.png']),'-dpng','-r200');
%             end
%             
%             [X,Y] = meshgrid(mus_lb(2):25:mus_ub(2),mus_lb(4):25:mus_ub(4));
%             for i=1:size(lkt_points_ref,1)
%                 f=figure('Units','pixels','position',[0 0 640 540]);
%                 surf(X,Y,squeeze(lkt_points_ref(i,:,1,:))','EdgeColor','None');
%                 title(['scalp = ' num2str(mus_lb(1)+25*(i-1)) ' cm^{-1}']);
%                 xlabel('skull');
%                 ylabel('gray matter');
%                 zlabel('Reflectance');
%                 zlim([zmin zmax]);
%                 print(fullfile('results',['b_fixed_scalp_' num2str(i) '_SDS' num2str(SDS_array(now_SDS)) 'cm_Gate ' num2str(s-num_gate*(now_SDS-1)) '.png']),'-dpng','-r200');
%             end
%             
%             % after smoothing
%             [X,Y] = meshgrid(mus_lb(1):25:mus_ub(1),mus_lb(2):25:mus_ub(2));
%             zmax=max(smoothed_data_1(:));
%             zmin=min(smoothed_data_1(:));
%             for i=1:size(smoothed_data_1,4)
%                 f=figure('Units','pixels','position',[0 0 640 540]);
%                 surf(X,Y,squeeze(smoothed_data_1(:,:,1,i))','EdgeColor','None');
%                 title(['GM = ' num2str(mus_lb(4)+25*(i-1)) ' cm^{-1}']);
%                 xlabel('scalp');
%                 ylabel('skull');
%                 zlabel('Reflectance');
%                 zlim([zmin zmax]);
%                 print(fullfile('results',['fixed_GM_' num2str(i) '_SDS' num2str(SDS_array(now_SDS)) 'cm_Gate ' num2str(s-num_gate*(now_SDS-1)) '.png']),'-dpng','-r200');
%             end
%             
%             [X,Y] = meshgrid(mus_lb(1):25:mus_ub(1),mus_lb(4):25:mus_ub(4));
%             for i=1:size(smoothed_data_1,2)
%                 f=figure('Units','pixels','position',[0 0 640 540]);
%                 surf(X,Y,squeeze(smoothed_data_1(:,i,1,:))','EdgeColor','None');
%                 title(['skull = ' num2str(mus_lb(2)+25*(i-1)) ' cm^{-1}']);
%                 xlabel('scalp');
%                 ylabel('gray matter');
%                 zlabel('Reflectance');
%                 zlim([zmin zmax]);
%                 print(fullfile('results',['fixed_skull_' num2str(i) '_SDS' num2str(SDS_array(now_SDS)) 'cm_Gate ' num2str(s-num_gate*(now_SDS-1)) '.png']),'-dpng','-r200');
%             end
%             
%             [X,Y] = meshgrid(mus_lb(2):25:mus_ub(2),mus_lb(4):25:mus_ub(4));
%             for i=1:size(smoothed_data_1,1)
%                 f=figure('Units','pixels','position',[0 0 640 540]);
%                 surf(X,Y,squeeze(smoothed_data_1(i,:,1,:))','EdgeColor','None');
%                 title(['scalp = ' num2str(mus_lb(1)+25*(i-1)) ' cm^{-1}']);
%                 xlabel('skull');
%                 ylabel('gray matter');
%                 zlabel('Reflectance');
%                 zlim([zmin zmax]);
%                 print(fullfile('results',['fixed_scalp_' num2str(i) '_SDS' num2str(SDS_array(now_SDS)) 'cm_Gate ' num2str(s-num_gate*(now_SDS-1)) '.png']),'-dpng','-r200');
%             end
            
            

            
            % Prepare to plot
            lkt_points_ref_smooth(end+1,:,:,:,:)=smoothed_data;
            lkt_points_ref_smooth_1(end+1,:,:,:,:)=smoothed_data_1;
            lkt_points_ref_smooth_2(end+1,:,:,:,:)=smoothed_data_2;
            lkt_points_ref_smooth_3(end+1,:,:,:,:)=smoothed_data_3;
            
            if rem(s,num_gate)==0
                now_SDS=ceil(s/num_gate);

                for mus=4 %[1 2 4]
                    if mus==1
                        if hs_or_ls==0
                            to_plot_orig=squeeze(lkt_points_ref_arrange(:,:,8,1,10))';
                            to_plot_smooth=squeeze(lkt_points_ref_smooth(:,:,8,1,10))';
                            to_plot_smooth_1=squeeze(lkt_points_ref_smooth_1(:,:,8,1,10))';
                            to_plot_smooth_2=squeeze(lkt_points_ref_smooth_2(:,:,8,1,10))';
                            to_plot_smooth_3=squeeze(lkt_points_ref_smooth_3(:,:,8,1,10))';
                        elseif hs_or_ls==1
                            to_plot_orig=squeeze(lkt_points_ref_arrange(:,:,2,1,2))';
                            to_plot_smooth=squeeze(lkt_points_ref_smooth(:,:,2,1,2))';
                            to_plot_smooth_1=squeeze(lkt_points_ref_smooth_1(:,:,2,1,2))';
                            to_plot_smooth_2=squeeze(lkt_points_ref_smooth_2(:,:,2,1,2))';
                            to_plot_smooth_3=squeeze(lkt_points_ref_smooth_3(:,:,2,1,2))';
                        end
                    elseif mus==2
                        if hs_or_ls==0
                            to_plot_orig=squeeze(lkt_points_ref_arrange(:,7,:,1,10))';
                            to_plot_smooth=squeeze(lkt_points_ref_smooth(:,7,:,1,10))';
                            to_plot_smooth_1=squeeze(lkt_points_ref_smooth_1(:,7,:,1,10))';
                            to_plot_smooth_2=squeeze(lkt_points_ref_smooth_2(:,7,:,1,10))';
                            to_plot_smooth_3=squeeze(lkt_points_ref_smooth_3(:,7,:,1,10))';
%                             to_plot_true_sk=dtof_arrange_sk(:,9+(now_SDS-1)*num_gate:8+now_SDS*num_gate);
                        elseif hs_or_ls==1
                            to_plot_orig=squeeze(lkt_points_ref_arrange(:,2,:,1,2))';
                            to_plot_smooth=squeeze(lkt_points_ref_smooth(:,2,:,1,2))';
                            to_plot_smooth_1=squeeze(lkt_points_ref_smooth_1(:,2,:,1,2))';
                            to_plot_smooth_2=squeeze(lkt_points_ref_smooth_2(:,2,:,1,2))';
                            to_plot_smooth_3=squeeze(lkt_points_ref_smooth_3(:,2,:,1,2))';
%                             to_plot_true_sk=dtof_arrange_sk(:,9+(now_SDS-1)*num_gate:8+now_SDS*num_gate);
                        end
                    elseif mus==4
                        if hs_or_ls==0
                            to_plot_orig=squeeze(lkt_points_ref_arrange(:,7,8,1,:))';
                            to_plot_smooth=squeeze(lkt_points_ref_smooth(:,7,8,1,:))';
                            to_plot_smooth_1=squeeze(lkt_points_ref_smooth_1(:,7,8,1,:))';
                            to_plot_smooth_2=squeeze(lkt_points_ref_smooth_2(:,7,8,1,:))';
                            to_plot_smooth_3=squeeze(lkt_points_ref_smooth_3(:,7,8,1,:))';
                            to_plot_true_gm=dtof_arrange_gm(:,9+(now_SDS-1)*num_gate:8+now_SDS*num_gate);
                        elseif hs_or_ls==1
                            to_plot_orig=squeeze(lkt_points_ref_arrange(:,2,2,1,:))';
                            to_plot_smooth=squeeze(lkt_points_ref_smooth(:,2,2,1,:))';
                            to_plot_smooth_1=squeeze(lkt_points_ref_smooth_1(:,2,2,1,:))';
                            to_plot_smooth_2=squeeze(lkt_points_ref_smooth_2(:,2,2,1,:))';
                            to_plot_smooth_3=squeeze(lkt_points_ref_smooth_3(:,2,2,1,:))';
                            to_plot_true_gm=dtof_arrange_gm(:,9+(now_SDS-1)*num_gate:8+now_SDS*num_gate);
                        end
                    end
                    
                    % Plot comparison of original and smooth data in each SDS and gate
                    if mus==4
                        fig2=figure('Units','pixels','position',[0 0 1920 1080]);
    %                     set(fig2,'visible','off');
                        ti=tiledlayout(2,5);
                    end

                    for g=1:10
                        nexttile;
                        plot(mus_lb(mus):25:mus_ub(mus),to_plot_orig(:,g),'--o','Linewidth',linewidth);
                        hold on
%                         plot(mus_lb(mus):25:mus_ub(mus),to_plot_smooth(:,g),'-o','Linewidth',linewidth);
                        hold on
                        plot(mus_lb(mus):25:mus_ub(mus),to_plot_smooth_1(:,g),'-o');
%                         hold on
                        if mus==4
                            plot(mus_lb(mus):25:mus_ub(mus),to_plot_true_gm(:,g),'-o','Linewidth',linewidth);
                            hold on
                        elseif mus==2
%                             plot(mus_lb(mus):25:mus_ub(mus),to_plot_true_sk(:,g),'-o','Linewidth',linewidth);
%                             hold on
                        end
                        x1=mus_lb(mus)+25;
                        x2=mus_ub(mus)-25;
                        yLimits = ylim;
                        xPatch = [x1, x2, x2, x1];
                        yPatch = [min(ylim), min(ylim),max(ylim), max(ylim)];
                        p=patch(xPatch, yPatch, [0.69, 0.93, 0.93],'FaceAlpha',0.3,'EdgeColor','none');
                        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
                        uistack(p,"bottom");    
                        xlabel(mus_array{mus});
                        ylabel('reflectance');
                        ylim(yLimits);
                        title(['Gate ' num2str(g)]);
                        set(gca,'FontSize',fontSize,'Fontname','Times New Roman');
%                         if mus==4
%                             legend('1E10','poly','2E11','Location','northwest');
%                         else
%                             legend('1E10','poly','Location','northwest');
%                         end
                    end
                    
                    if mus==4
                        title(ti,['SDS ' num2str(SDS_array(now_SDS)) ' cm']);
                        lgd=legend('1E10','poly','2E11','Orientation','horizontal','FontSize',fontSize,'Fontname','Times New Roman');
                        lgd.Layout.Tile = 'south';
                        if hs_or_ls==0
                            print(fig2,fullfile(output_dir,['hs_SDS ' num2str(SDS_array(now_SDS)) 'cm_smooth_result.png']),'-dpng','-r300');
                        elseif hs_or_ls==1
                            print(fig2,fullfile(output_dir,['ls_SDS ' num2str(SDS_array(now_SDS)) 'cm_smooth_result.png']),'-dpng','-r300');
                        end
                    end
                    % Evaluate smoothing effect by calculating error with true and plot
                    if mus==4 %mus==2 || mus==4
                        if mus==2
                            orig_error=sqrt(mean((to_plot_orig(2:size(to_plot_orig,1)-1,:)./to_plot_true_sk(2:size(to_plot_orig,1)-1,:)-1).^2,1));
                            smooth_error_sk=sqrt(mean((to_plot_smooth(2:size(to_plot_orig,1)-1,:)./to_plot_true_sk(2:size(to_plot_orig,1)-1,:)-1).^2,1));
                            smooth_error_sk_1=sqrt(mean((to_plot_smooth_1(2:size(to_plot_orig,1)-1,:)./to_plot_true_sk(2:size(to_plot_orig,1)-1,:)-1).^2,1));
%                             smooth_error_sk_2=sqrt(mean((to_plot_smooth_2(2:size(to_plot_orig,1)-1,:)./to_plot_true_sk(2:size(to_plot_orig,1)-1,:)-1).^2,1));
                        elseif mus==4
                            orig_error=sqrt(mean((to_plot_orig(2:size(to_plot_orig,1)-1,:)./to_plot_true_gm(2:size(to_plot_orig,1)-1,:)-1).^2,1));
                            smooth_error_gm=sqrt(mean((to_plot_smooth(2:size(to_plot_orig,1)-1,:)./to_plot_true_gm(2:size(to_plot_orig,1)-1,:)-1).^2,1));
                            smooth_error_gm_1=sqrt(mean((to_plot_smooth_1(2:size(to_plot_orig,1)-1,:)./to_plot_true_gm(2:size(to_plot_orig,1)-1,:)-1).^2,1));
                            smooth_error_gm_2=sqrt(mean((to_plot_smooth_2(2:size(to_plot_orig,1)-1,:)./to_plot_true_gm(2:size(to_plot_orig,1)-1,:)-1).^2,1));
                            smooth_error_gm_3=sqrt(mean((to_plot_smooth_3(2:size(to_plot_orig,1)-1,:)./to_plot_true_gm(2:size(to_plot_orig,1)-1,:)-1).^2,1));
                        end
                        
                        figure(1);
                        to_plot_gate=1:10;
                        nexttile;
                        plot(to_plot_gate,100*orig_error(to_plot_gate),'.','MarkerSize',markersize);
                        hold on
                        if mus==2
%                             plot(1:1:num_gate,100*smooth_error_sk,'o','LineWidth',linewidth);
%                             hold on
%                             plot(1:1:num_gate,100*smooth_error_sk_1,'o','LineWidth',linewidth);
%                             hold on
% %                             plot(1:1:num_gate,100*smooth_error_sk_2,'o','LineWidth',linewidth);
% %                             hold on
                        elseif mus==4
                            plot(to_plot_gate,100*smooth_error_gm(to_plot_gate),'.','MarkerSize',markersize);
                            hold on
                            plot(to_plot_gate,100*smooth_error_gm_1(to_plot_gate),'.','MarkerSize',markersize);
                            plot(to_plot_gate,100*smooth_error_gm_2(to_plot_gate),'.','MarkerSize',markersize);
                            plot(1:1:num_gate,100*smooth_error_gm_3,'.','MarkerSize',markersize);
                        end
%                         plot(1:1:num_gate,ones(1,10)*10,'--','LineWidth',1);
                        title(['SDS ' num2str(SDS_array(now_SDS)) ' cm']);
                        xlabel('Time gate');
%                         xlim([1 10]);
                        ylabel(['RMSPE (%)']);
                        ylim([0 50]);
                        sub_num=sub_num+1;
                        legend('1E10','n=2','n=4','n=6','n=8','Location','northwest'); %,'gaussian'
                        set(gca,'FontSize',fontSize,'Fontname','Times New Roman');
                        
                        mean_RMSE(1,now_SDS)=mean(orig_error(isfinite(orig_error)));
                        mean_RMSE(2,now_SDS)=mean(smooth_error_gm(isfinite(smooth_error_gm)));
                        mean_RMSE(3,now_SDS)=mean(smooth_error_gm_1(isfinite(smooth_error_gm_1)));
                        mean_RMSE(4,now_SDS)=mean(smooth_error_gm_2(isfinite(smooth_error_gm_2)));
                        mean_RMSE(5,now_SDS)=mean(smooth_error_gm_3(isfinite(smooth_error_gm_3)));
                    end
                end
                lkt_points_ref_arrange=[];
                lkt_points_ref_smooth=[];
                lkt_points_ref_smooth_1=[];
                lkt_points_ref_smooth_2=[];
                lkt_points_ref_smooth_3=[];
            end
        end
        if hs_or_ls==0
            print(fig,fullfile(output_dir,['hs_mus_smooth_result_compare_to_true.png']),'-dpng','-r300');
        elseif hs_or_ls==1
            print(fig,fullfile(output_dir,['ls_mus_smooth_result_compare_to_true.png']),'-dpng','-r300');
        end
        mean_RMSE(:,end)=mean(mean_RMSE(:,1:end-1),2);
    end
    
    %% truth for changing mua, fixed mus
%     true_dir=fullfile(lookup_table_arr,'KB_high_scattering');
%     for lkt_index=11 %size(lkt_mus_table,1)
%         fprintf('Processing lookup mus set %d/%d, Gate: ',lkt_index,size(lkt_mus_table,1));
%         temp_PL=load(fullfile(true_dir,['sim_' num2str(lkt_index)],'PL_1.mat'));
%         for s=1:num_SDS
%             SDS_detpt_arr_2(num_gate*(s-1)+1:num_gate*s)=temp_PL.SDS_detpt_arr(:,s)';
%         end
% 
%         for s=1:num_total
%             fprintf(' %d',s);
%             temp_lkt_ref_value=zeros(size(mua_param_arr,1),1);
%             for mua_set_i=1:num_mua_set
%                 temp_detpt_weight=squeeze(exp(-1*sum(SDS_detpt_arr_2{s}(:,1:5).*in_array_mua_param_arr{mua_set_i},2))); % the weight of each photon, not normalized yet
%                 temp_detpt_weight=transpose(sum(temp_detpt_weight,1)/temp_PL.each_photon_weight_arr(ceil(s/10)));
%                 temp_lkt_ref_value(max_mua_sameTime*(mua_set_i-1)+1:max_mua_sameTime*(mua_set_i-1)+length(temp_detpt_weight),1)=temp_detpt_weight; % the reflectance of high NA detector
%             end
%             temp_lkt_ref_value=temp_lkt_ref_value(in_place_arr_mua);
%             lkt_ref_value_true_changing_mua(s,:,:,:,:)=temp_lkt_ref_value;
%         end
%         
%         fprintf('\n');
%     end
    
    %% For changing mua, fixed mus
%     close all;
%     
%     lkt_points_ref_arrange=[];
%     lkt_points_ref_smooth=[];
%     lkt_points_ref_smooth_1=[];
%     lkt_points_ref_smooth_2=[];
%     
%     orig=[];
%     smooth=[];
%     smooth_1=[];
%     
%     % for polyfitn
%     [x, y, z] = meshgrid(mus_lb(2):25:mus_ub(2),mus_lb(1):25:mus_ub(1), mus_lb(4):25:mus_ub(4));
%     x=x(:);
%     y=y(:);
%     z=z(:);
%     
%     for s=21:50 %21:50 %1:num_total
%         for mua_i=1:size(mua_param_arr,1)
%             lkt_value=lkt_ref_value_arr(:,mua_i,s);
%             lkt_points_ref=lkt_value(in_place_arr);
%             orig(end+1)=lkt_points_ref(7,8,1,10); % choose which mus to fix
%             
%             % smooth
%             temp_lkt_points_ref=squeeze(lkt_points_ref);
%            
%             [m, n, p]=size(temp_lkt_points_ref);
%             data_1d=(reshape(temp_lkt_points_ref, [], 1));
%             data_1d=-log10(data_1d);
%             data_1d(data_1d==inf)=NaN;
%             
%             degree=4;
%             coefficients=polyfitn([x, y, z], data_1d, degree);
%             fitted_values=polyvaln(coefficients, [x, y, z]);
%             fitted_values=power(10,-fitted_values);
%             
%             fitted_surface=reshape(fitted_values, [m, n, p]);
%             smoothed_data(:,:,1,:)=fitted_surface;
%             
% %             degree=6;
% %             coefficients=polyfitn([x, y, z], data_1d, degree);
% %             fitted_values=polyvaln(coefficients, [x, y, z]);
% %             fitted_values=power(10,-fitted_values);
% %             
% %             fitted_surface=reshape(fitted_values, [m, n, p]);
% %             smoothed_data_1(:,:,1,:)=fitted_surface;
%             
%             
%             smooth(end+1)=smoothed_data(7,8,1,10);
% %             smooth_1(end+1)=smoothed_data_1(7,8,1,10);
% 
%         end
%         
%         lkt_points_ref_arrange(end+1,:,:,:,:)=orig(in_place_arr_mua);
%         lkt_points_ref_smooth(end+1,:,:,:,:)=smooth(in_place_arr_mua);
% %         lkt_points_ref_smooth_1(end+1,:,:,:,:)=smooth_1(in_place_arr_mua);
%         
%         orig=[];
%         smooth=[];
%         smooth_1=[];
%         
%         if rem(s,10)==0
%             now_SDS=s/num_gate;
%             for mua=[1 2 4]
%                 figure('Units','pixels','position',[0 0 1920 1080]);
%                 ti=tiledlayout(2,5);
%                 % smallest mus
%                 if mua==1
%                     to_plot_orig=squeeze(lkt_points_ref_arrange(:,:,1,1,1))';
%                     to_plot_smooth=squeeze(lkt_points_ref_smooth(:,:,1,1,1))';
%                     to_plot_true=squeeze(lkt_ref_value_true_changing_mua(s-9:s,:,1,1,1))';
%                 elseif mua==2
%                     to_plot_orig=squeeze(lkt_points_ref_arrange(:,1,:,1,1))';
%                     to_plot_smooth=squeeze(lkt_points_ref_smooth(:,1,:,1,1))';
%                     to_plot_true=squeeze(lkt_ref_value_true_changing_mua(s-9:s,1,:,1,1))';
%                 elseif mua==4
%                     to_plot_orig=squeeze(lkt_points_ref_arrange(:,1,1,1,:))';
%                     to_plot_smooth=squeeze(lkt_points_ref_smooth(:,1,1,1,:))';
%     %                 to_plot_smooth_1=squeeze(lkt_points_ref_smooth_1(:,1,1,1,:))';
%     %                 to_plot_smooth_2=squeeze(lkt_points_ref_smooth_2(:,1,1,1,:))';
%                     to_plot_true=squeeze(lkt_ref_value_true_changing_mua(s-9:s,1,1,1,:))';
%                 end
% 
%                 % Plot comparison of original and smooth data in each SDS and gate
%                 for g=1:num_gate
%                     nexttile;
%                     plot(mua_lb(mua):0.05:mua_ub(mua),to_plot_orig(:,g),'--o','LineWidth',linewidth);
%                     hold on
%                     plot(mua_lb(mua):0.05:mua_ub(mua),to_plot_smooth(:,g),'-o','LineWidth',linewidth);
%                     hold on 
%                     plot(mua_lb(mua):0.05:mua_ub(mua),to_plot_true(:,g),'-o','LineWidth',linewidth);
%                     
% %                     xLimits=xlim;
% %                     yLimits=ylim;
% %                     xPatch=[mua_lb(mua), mua_ub(mua), mua_ub(mua), mua_lb(mua)];
% %                     yPatch=[min(ylim), min(ylim),max(ylim), max(ylim)];
% %                     p=patch(xPatch, yPatch, [0.69, 0.93, 0.93],'FaceAlpha',0.3,'EdgeColor','none');
% %                     p.Annotation.LegendInformation.IconDisplayStyle = 'off';
% %                     uistack(p,"bottom");
%                     
%                     xlabel(mua_array{mua});
%                     ylabel('reflectance');
%                     title(['Gate' num2str(g)]);
% %                     xlim(xLimits);
% %                     ylim(yLimits);
%                     legend('1E10','degree=4','2E11','Location','northwest');
%                 end
%                 title(ti,['SDS ' num2str(SDS_array(now_SDS)) ' cm']);
%                 print(fullfile('results',['hs_mua_' num2str(mua) '_SDS ' num2str(SDS_array(now_SDS)) 'cm_smooth_result.png']),'-dpng','-r200');
%             end
%             lkt_points_ref_arrange=[];
%             lkt_points_ref_smooth=[];
%             lkt_points_ref_smooth_1=[];
%             lkt_points_ref_smooth_2=[];
%         end
%     end
end

disp('Done!');

